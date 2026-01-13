output "id" {
  value = azurerm_cognitive_account_project.project.id
}

output "endpoints" {
  value = azurerm_cognitive_account_project.project.endpoints
}

output "identity_principal_id" {
  value = azurerm_cognitive_account_project.project.identity[0].principal_id
}

output "name" {
  value = azurerm_cognitive_account_project.project.name
}