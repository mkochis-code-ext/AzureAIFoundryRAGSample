output "id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.group.id
}

output "name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.group.name
}

output "location" {
  description = "The location of the resource group"
  value       = azurerm_resource_group.group.location
}
