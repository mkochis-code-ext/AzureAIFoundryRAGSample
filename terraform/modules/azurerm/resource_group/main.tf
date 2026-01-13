resource "azurerm_resource_group" "group" {
  name     = var.name
  location = var.location
  tags     = var.tags
}
