from fastapi import FastAPI
from dotenv import dotenv_values
from fastapi.concurrency import asynccontextmanager
config = dotenv_values(".env")

from contextlib import asynccontextmanager
from azure.data.tables.aio import TableServiceClient
    


count =0
config = {
    "URI": config.get("URI"),
    "KEY": config.get("KEY")
}

@asynccontextmanager
async def lifespan(app: FastAPI):
    conn_str = f"DefaultEndpointsProtocol=https;AccountName=azurecdbarc;AccountKey={config['KEY']};TableEndpoint={config['URI']};"
    app.table_client = TableServiceClient.from_connection_string(conn_str)
    
    # Connection check
    try:
        app.visitors_table = app.table_client.get_table_client("Visitors")
        print("✅ Connected to Table API")
    except Exception as e:
        print(f"❌ Connection failed: {e}")
    
    yield
    await app.table_client.close()

    
app= FastAPI(lifespan=lifespan)



@app.get("/")
def home():
    return {"message": "Welcome to the Cloud Resume Challenge!"}

@app.get("/visitors-count")
def visitors_count():
    global count
    count += 1
    return {"visitors_count": count}