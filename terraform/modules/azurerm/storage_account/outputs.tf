output "id" {
  description = "The ID of the Storage Account"
  value       = azurerm_storage_account.storage.id
}

output "name" {
  description = "The name of the Storage Account"
  value       = azurerm_storage_account.storage.name
}

output "primary_connection_string" {
  description = "The primary connction string of the storage account"
  value = azurerm_storage_account.storage.primary_connection_string
}