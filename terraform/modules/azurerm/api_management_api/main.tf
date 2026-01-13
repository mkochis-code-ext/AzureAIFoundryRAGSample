resource "azurerm_api_management_api" "api" {
  name                  = var.name
  resource_group_name   = var.resource_group_name
  api_management_name   = var.api_management_name
  revision              = var.revision
  display_name          = var.display_name
  path                  = var.path
  protocols             = var.protocols
  service_url           = var.service_url
  subscription_required = var.subscription_required
  
  dynamic "import" {
    for_each = var.content_format != null ? [1] : []
    content {
      content_format = var.content_format
      content_value  = var.content_value
    }
  }
}
