from fastapi import FastAPI
from dotenv import dotenv_values
from fastapi.concurrency import asynccontextmanager
from fastapi.middleware.cors import CORSMiddleware
from azure.core.exceptions import ResourceNotFoundError


config = dotenv_values(".env")

from contextlib import asynccontextmanager
from azure.data.tables.aio import TableServiceClient
    


count =0
config = {
    "CONNECTION_STRING": config.get("CONNECTION_STRING")
}



@asynccontextmanager
async def lifespan(app: FastAPI):
    conn_str = config.get("CONNECTION_STRING")
    app.table_client = TableServiceClient.from_connection_string(conn_str)
    
    # Connection check
    try:
        app.visitors_table = app.table_client.get_table_client("VisitorCounter")
        print("✅ Connected to Table API")
    except Exception as e:
        print(f"❌ Connection failed: {e}")
    
    yield
    await app.table_client.close()

    
app= FastAPI(lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)



@app.get("/")
def home():
    return {"message": "Welcome to the Cloud Resume Challenge!"}

@app.get("/visitors-count")
async def visitors_count():
    partition_key = "Visitors"
    row_key = "Count"
    try:
        entity = await app.visitors_table.get_entity(partition_key, row_key)
        cur_val=entity["Count"]+1
        entity["Count"] = cur_val

    except ResourceNotFoundError    :
        entity = {"PartitionKey": partition_key, "RowKey": row_key, "Count": 1}

    #print(f"Current count: {entity['Count'].value}")
    await app.visitors_table.upsert_entity(entity)
    return {"visitors_count": entity["Count"]}