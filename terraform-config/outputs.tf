output "website_url" {
  value = azurerm_storage_account.storage.primary_web_endpoint
}

output "function_app_url" {
  value       = "https://${azurerm_linux_function_app.funapp.default_hostname}"
  description = "The root URL of your FastAPI Function App."
}