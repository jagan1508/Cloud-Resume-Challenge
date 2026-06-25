from fastapi import FastAPI
from dotenv import dotenv_values
from fastapi.concurrency import asynccontextmanager
from fastapi.middleware.cors import CORSMiddleware
from azure.core.exceptions import ResourceNotFoundError
from azure.data.tables import UpdateMode



config = dotenv_values(".env")

from contextlib import asynccontextmanager
from azure.data.tables.aio import TableServiceClient
    

import os
from dotenv import load_dotenv

load_dotenv() 

config = {
    "CONNECTION_STRING": os.environ.get("CONNECTION_STRING")
}

@asynccontextmanager
async def lifespan(app: FastAPI):
    conn_str = config.get("CONNECTION_STRING")
    app.state.visitor_count = getattr(app.state, "visitor_count", 0)
    app.state.table_client = None
    app.state.visitors_table = None

    if not conn_str:
        print("No CONNECTION_STRING provided; using in-memory visitor count")
        yield
        return

    try:
        app.state.table_client = TableServiceClient.from_connection_string(conn_str)
        app.state.visitors_table = app.state.table_client.get_table_client("VisitorCounter")
        print("Connected to Table API")
    except Exception as e:
        print(f"Connection failed: {e}")

    yield
    if app.state.table_client is not None:
        await app.state.table_client.close()

    
api= FastAPI(lifespan=lifespan)

api.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)



@api.get("/")
def home():
    return {"message": "Welcome to the Cloud Resume Challenge!"}

@api.get("/visitors-count")
async def visitors_count():
    if getattr(api.state, "visitors_table", None) is None:
        api.state.visitor_count = getattr(api.state, "visitor_count", 0) + 1
        return {"visitors_count": api.state.visitor_count}

    partition_key = "Visitors"
    row_key = "Count"
    try:
        entity = await api.state.visitors_table.get_entity(partition_key, row_key)
        cur_val = entity["Count"] + 1
        entity["Count"] = cur_val
        await api.state.visitors_table.update_entity(entity, mode=UpdateMode.MERGE)
        return {"visitors_count": entity["Count"]}

    except ResourceNotFoundError:
        entity = {"PartitionKey": partition_key, "RowKey": row_key, "Count": 1}
        await api.state.visitors_table.create_entity(entity)
        return {"visitors_count": entity["Count"]}