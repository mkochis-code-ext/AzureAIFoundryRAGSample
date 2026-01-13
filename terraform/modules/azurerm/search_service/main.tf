resource "azurerm_search_service" "search" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku            = var.sku
  replica_count  = var.replica_count
  partition_count = var.partition_count

  public_network_access_enabled = var.public_network_access_enabled

  # Prefer Entra ID (AAD) auth over admin keys.
  # Note: this argument is supported in newer azurerm versions.
  local_authentication_enabled = var.local_authentication_enabled

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
