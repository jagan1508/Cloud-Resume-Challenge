variable "rg_name" {}
variable "location" {}

variable "sa_name" {}

variable "cosmosdb_account_name" {}
variable "tables" {}

locals {
  files = {
    "index.html" = "text/html"
    "style.css"  = "text/css"
    "script.js"  = "application/javascript"
  }
}

