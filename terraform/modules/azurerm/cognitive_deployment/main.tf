resource "azurerm_cognitive_deployment" "deployment" {
  name                 = var.deployment_name
  cognitive_account_id = var.cognitive_account_id
  
  model {
    format  = "OpenAI"
    name    = var.model_name
    version = var.model_version
  }

  sku {
    name     = var.model_sku_name
    capacity = var.model_sku_capacity
  }
  
  # optional but common:
  version_upgrade_option = "OnceNewDefaultVersionAvailable"
  rai_policy_name        = "Microsoft.Default"
}
