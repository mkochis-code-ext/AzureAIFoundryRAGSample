resource "azurerm_cognitive_account_project" "project" {
  name                 = "cog-proj-${var.name}"
  cognitive_account_id = var.cognitive_account_id
  location             = var.location
  description          = "Example cognitive services project"
  display_name         = "Example Project"

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
