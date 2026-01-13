output "id" {
  description = "The ID of the API Management Service"
  value       = azurerm_api_management.apim.id
}

output "name" {
  description = "The name of the API Management Service"
  value       = azurerm_api_management.apim.name
}

output "private_ip_addresses" {
  description = "The Private IP addresses of the API Management Service"
  value       = azurerm_api_management.apim.private_ip_addresses
}

output "principal_id" {
  description = "The principal id of the APIM system-assigned managed identity"
  value       = azurerm_api_management.apim.identity[0].principal_id
}

output "gateway_url" {
  description = "The URL of the API Management Gateway"
  value       = azurerm_api_management.apim.gateway_url
}

