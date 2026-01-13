resource "azurerm_cognitive_account" "account" {
  name                          = "cog-${var.name}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  kind                          = "AIServices"
  project_management_enabled    = true
  custom_subdomain_name         = "cog-${var.name}"
  public_network_access_enabled = true # We control access via network_acls now
  local_auth_enabled            = false

  network_acls {
    default_action = var.enable_private_networking ? "Deny" : "Allow"
    bypass         = "AzureServices"
  }

  sku_name = "S0"

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
