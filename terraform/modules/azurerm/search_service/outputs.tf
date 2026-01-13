output "id" {
  description = "The ID of the Search service"
  value       = azurerm_search_service.search.id
}

output "name" {
  description = "The name of the Search service"
  value       = azurerm_search_service.search.name
}

output "endpoint" {
  description = "The endpoint of the Search service"
  value       = "https://${azurerm_search_service.search.name}.search.windows.net"
}

output "apiKey" {
  description = "The API key of the Search service"
  value = azurerm_search_service.search.primary_key
}

output "principal_id" {
  description = "The principal ID of the Search service's system-assigned managed identity"
  value       = azurerm_search_service.search.identity[0].principal_id
}
