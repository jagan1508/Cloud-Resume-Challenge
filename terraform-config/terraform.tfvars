tables = {
  visitor_counter = {
    table_name           = "VisitorCounter"
    table_throughput     = 400
    table_max_throughput = null
  }
}

cosmosdb_account_name = "tfarc-cosmosdb"
sa_name               = "tfarcstorage"
location              = "westus2"
rg_name               = "myTFResourceGroup"