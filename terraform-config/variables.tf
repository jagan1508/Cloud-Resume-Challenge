variable "rg_name" {
  default = "myTFResourceGroup"
}
variable "location" {
  default = "westus2"
}

variable "sa_name" {
  default = "tfarcstorage"

}

locals {
  files = {
    "index.html" = "text/html"
    "style.css" = "text/css"
    "script.js"     = "application/javascript"
  }
}