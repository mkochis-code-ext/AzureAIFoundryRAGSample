terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    azapi = {
      source = "Azure/azapi"
    }
  }
}

locals {
  resource_group_name = "rg-${var.workload}-${var.environment_prefix}-${var.suffix}"
  actual_data_location = var.data_location != "" ? var.data_location : var.location
}

data "azurerm_client_config" "current" {}

module "resource_group" {
  source = "../modules/azurerm/resource_group"

  name     = local.resource_group_name
  location = var.location
  tags     = var.tags
}

module "vnet" {
  source = "../modules/azurerm/virtual_network"

  name                = "vnet-${var.workload}-${var.environment_prefix}-${var.suffix}"
  location            = var.location
  resource_group_name = module.resource_group.name
  tags                = var.tags
}

module "subnet_apim" {
  source = "../modules/azurerm/subnet"

  name                 = "snet-apim"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

module "subnet_pe" {
  source = "../modules/azurerm/subnet"

  name                 = "snet-pe"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

module "network_security_group" {
  source = "../modules/azurerm/network_security_group"

  name                = "nsg-apim"
  location            = var.location
  resource_group_name = module.resource_group.name
  tags                = var.tags

  security_rules = [
    {
      name                       = "AllowApimManagement"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3443"
      source_address_prefix      = "ApiManagement"
      destination_address_prefix = "VirtualNetwork"
    },
    {
      name                       = "AllowClientAccess"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "VirtualNetwork"
    },
    {
      name                       = "AllowAzureLoadBalancer"
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "6390"
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "VirtualNetwork"
    }
  ]
}

module "nsg_association" {
  source = "../modules/azurerm/nsg_association"

  subnet_id                 = module.subnet_apim.id
  network_security_group_id = module.network_security_group.id
}

module "api_management" {
  source = "../modules/azurerm/api_management"

  name                = "apim-${var.workload}-${var.environment_prefix}-${var.suffix}"
  location            = var.location
  resource_group_name = module.resource_group.name
  publisher_name      = var.apim_publisher_name
  publisher_email     = var.apim_publisher_email
  sku                 = var.apim_sku
  sku_count           = var.apim_sku_count
  tags                = var.tags

  subnet_id            = module.subnet_apim.id
  virtual_network_type = "External"
}

module "api_management_backend" {
  source = "../modules/azurerm/api_management_backend"

  name                = "openai-backend"
  resource_group_name = module.resource_group.name
  api_management_name = module.api_management.name
  protocol            = "http"
  # Use the Azure AI Foundry project endpoint with the project path included
  # Format: https://<account>.services.ai.azure.com/api/projects/<project-name>
  url                 = "${trimsuffix(lookup(module.cognitive_project.endpoints, "inference", module.cognitive.endpoint), "/")}/api/projects/${module.cognitive_project.name}"

  depends_on = [module.cognitive_project]
}

module "api_management_api" {
  source = "../modules/azurerm/api_management_api"

  name                  = "agent-api"
  resource_group_name   = module.resource_group.name
  api_management_name   = module.api_management.name
  revision              = "1"
  display_name          = "AI Agent API"
  path                  = "agent"
  protocols             = ["https"]
  service_url           = module.cognitive.endpoint
  subscription_required = false
}

module "api_management_api_policy" {
  source = "../modules/azurerm/api_management_api_policy"

  api_name            = module.api_management_api.name
  api_management_name = module.api_management.name
  resource_group_name = module.resource_group.name

  xml_content = <<XML
<policies>
  <inbound>
    <!-- 1. Handle Preflight OPTIONS requests immediately -->
    <choose>
      <when condition="@(context.Request.Method == "OPTIONS")">
        <return-response>
          <set-status code="200" reason="OK" />
          <set-header name="Access-Control-Allow-Origin" exists-action="override">
            <value>@(context.Request.Headers.GetValueOrDefault("Origin","*"))</value>
          </set-header>
          <set-header name="Access-Control-Allow-Methods" exists-action="override">
            <value>GET, POST, PUT, PATCH, DELETE, OPTIONS</value>
          </set-header>
          <set-header name="Access-Control-Allow-Headers" exists-action="override">
            <value>@(context.Request.Headers.GetValueOrDefault("Access-Control-Request-Headers","*"))</value>
          </set-header>
          <set-header name="Access-Control-Allow-Credentials" exists-action="override">
            <value>true</value>
          </set-header>
        </return-response>
      </when>
    </choose>
    
    <base />
    <set-backend-service backend-id="${module.api_management_backend.name}" />
  </inbound>
  
  <backend>
    <base />
  </backend>
  
  <outbound>
    <base />
    <!-- 2. Add CORS headers to all successful responses -->
    <set-header name="Access-Control-Allow-Origin" exists-action="override">
      <value>@(context.Request.Headers.GetValueOrDefault("Origin","*"))</value>
    </set-header>
    <set-header name="Access-Control-Allow-Credentials" exists-action="override">
      <value>true</value>
    </set-header>
  </outbound>
  
  <on-error>
    <base />
    <!-- 3. Add CORS headers to error responses (404, 500, etc) -->
    <set-header name="Access-Control-Allow-Origin" exists-action="override">
      <value>@(context.Request.Headers.GetValueOrDefault("Origin","*"))</value>
    </set-header>
    <set-header name="Access-Control-Allow-Credentials" exists-action="override">
      <value>true</value>
    </set-header>
  </on-error>
</policies>
XML
}

module "op_create_thread_run" {
  source = "../modules/azurerm/api_management_api_operation"

  operation_id        = "create-thread-run"
  api_name            = module.api_management_api.name
  api_management_name = module.api_management.name
  resource_group_name = module.resource_group.name
  display_name        = "Create Thread and Run"
  method              = "POST"
  url_template        = "/threads/runs"
  description         = "Create a thread and run it."
}

module "op_get_run" {
  source = "../modules/azurerm/api_management_api_operation"

  operation_id        = "get-run"
  api_name            = module.api_management_api.name
  api_management_name = module.api_management.name
  resource_group_name = module.resource_group.name
  display_name        = "Get Run"
  method              = "GET"
  url_template        = "/threads/{threadId}/runs/{runId}"
  description         = "Get the status of a run."

  template_parameters = [
    {
      name     = "threadId"
      type     = "string"
      required = true
    },
    {
      name     = "runId"
      type     = "string"
      required = true
    }
  ]
}

module "op_list_messages" {
  source = "../modules/azurerm/api_management_api_operation"

  operation_id        = "list-messages"
  api_name            = module.api_management_api.name
  api_management_name = module.api_management.name
  resource_group_name = module.resource_group.name
  display_name        = "List Messages"
  method              = "GET"
  url_template        = "/threads/{threadId}/messages"
  description         = "List messages in a thread."

  template_parameters = [
    {
      name     = "threadId"
      type     = "string"
      required = true
    }
  ]
}

# Catch-all operation to handle OPTIONS/Preflight requests for any path
module "op_options" {
  source = "../modules/azurerm/api_management_api_operation"

  operation_id        = "options-catchall"
  api_name            = module.api_management_api.name
  api_management_name = module.api_management.name
  resource_group_name = module.resource_group.name
  display_name        = "CORS Preflight"
  method              = "OPTIONS"
  url_template        = "/*"
  description         = "Handles CORS preflight requests for all endpoints."
}

module "storage_account" {
  source = "../modules/azurerm/storage_account"

  name                = "st${var.workload}${var.environment_prefix}${var.suffix}"
  location            = var.location
  resource_group_name = module.resource_group.name
  containers = { "test" = { access_type = "private" } }
  tags                = var.tags
}

module "key_vault" {
  source = "../modules/azurerm/key_vault"

  name                = "kv-${var.workload}-${var.environment_prefix}-${var.suffix}"
  location            = var.location
  resource_group_name = module.resource_group.name
  tags                = var.tags
}

module "log_analytics" {
  source = "../modules/azurerm/log_analytics"

  name                = "log-${var.workload}-${var.environment_prefix}-${var.suffix}"
  location            = var.location
  resource_group_name = module.resource_group.name
  tags                = var.tags
}

module "application_insights" {
  source = "../modules/azurerm/application_insights"

  name                = "appi-${var.workload}-${var.environment_prefix}-${var.suffix}"
  location            = var.location
  resource_group_name = module.resource_group.name
  workspace_id        = module.log_analytics.id
  tags                = var.tags
}

module "search_service" {
  source = "../modules/azurerm/search_service"

  name                = "srch-${var.workload}-${var.environment_prefix}-${var.suffix}"
  location            = var.location
  resource_group_name = module.resource_group.name
  tags                = var.tags

  # Semantic search typically requires Standard SKU.
  sku             = "standard"
  replica_count   = 1
  partition_count = 1

  # Keep public for Agent access.
  public_network_access_enabled = true
  # Prefer Entra ID over admin keys.
  local_authentication_enabled = false
}

module "search_service_index" {
  source = "../modules/azurerm/search_service_index/"

  resource_group_name    = module.resource_group.name
  location               = var.location
  search_service_name    = module.search_service.name
  storage_connection_string = module.storage_account.primary_connection_string
  storage_account_name   = module.storage_account.name
  blob_container_name    = "test"

  datasource_name = "doc-datasource"
  index_name      = "ragdocs"
  skillset_name   = "doc-skillset"
  indexer_name    = "doc-indexer"
  
}

resource "azurerm_role_assignment" "apim_search_reader" {
  scope                = module.search_service.id
  role_definition_name = "Search Index Data Reader"
  principal_id         = module.api_management.principal_id

  depends_on = [module.api_management]
}

resource "azurerm_role_assignment" "cognitive_search_reader" {
  scope                = module.search_service.id
  role_definition_name = "Search Index Data Reader"
  principal_id         = module.cognitive.identity_principal_id
}

resource "azurerm_role_assignment" "current_user_search_contributor" {
  scope                = module.search_service.id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "cognitive_project_search_reader" {
  scope                = module.search_service.id
  role_definition_name = "Search Index Data Reader"
  principal_id         = module.cognitive_project.identity_principal_id
}

resource "azurerm_role_assignment" "current_user_search_project_contributor" {
  scope                = module.search_service.id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = module.cognitive_project.identity_principal_id
}

resource "azurerm_role_assignment" "current_search_project_contributor" {
  scope                = module.search_service.id
  role_definition_name = "Search Service Contributor"
  principal_id         = module.cognitive_project.identity_principal_id
}

resource "azurerm_role_assignment" "search_storage_reader" {
  scope                = module.storage_account.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = module.search_service.principal_id
}

# The AI Agent is hosted in the Cognitive Account. 
# APIM needs permission to invoke the Agent (Cognitive Services OpenAI User).
resource "azurerm_role_assignment" "apim_cognitive_user" {
  scope                = module.cognitive.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = module.api_management.principal_id

  depends_on = [module.api_management]
}

module "cognitive" {
  source = "../modules/azurerm/cognitive/"

  name                    = "${var.workload}-${var.environment_prefix}-${var.suffix}"
  location                = var.location
  resource_group_name     = module.resource_group.name
  storage_account_id      = module.storage_account.id
  key_vault_id            = module.key_vault.id
  application_insights_id = module.application_insights.id
  tags                    = var.tags

  enable_private_networking = false
}

module "cognitive_private_dns_zone" {
  source = "../modules/azurerm/private_dns_zone"

  name                = "privatelink.cognitiveservices.azure.com"
  resource_group_name = module.resource_group.name
  tags                = var.tags
}

module "azureml_private_dns_zone" {
  source = "../modules/azurerm/private_dns_zone"

  name                = "privatelink.api.azureml.ms"
  resource_group_name = module.resource_group.name
  tags                = var.tags
}

module "cognitive_private_endpoint" {
  source = "../modules/azurerm/private_endpoint"

  name                           = "${var.workload}-${var.environment_prefix}-${var.suffix}"
  location                       = var.location
  resource_group_name            = module.resource_group.name
  subnet_id                      = module.subnet_pe.id
  private_connection_resource_id = module.cognitive.id
  subresource_names              = ["account"]
  private_dns_zone_ids           = [module.cognitive_private_dns_zone.id]
  tags                           = var.tags
}

module "cognitive_private_dns_zone_virtual_network_link" {
  source = "../modules/azurerm/private_dns_zone_virtual_network_link"

  name                  = "pdznl-${var.workload}-${var.environment_prefix}-${var.suffix}"
  resource_group_name   = module.resource_group.name
  private_dns_zone_name = module.cognitive_private_dns_zone.name
  virtual_network_id    = module.vnet.vnet_id
}

module "azureml_private_dns_zone_virtual_network_link" {
  source = "../modules/azurerm/private_dns_zone_virtual_network_link"

  name                  = "pdznl-azureml-${var.workload}-${var.environment_prefix}-${var.suffix}"
  resource_group_name   = module.resource_group.name
  private_dns_zone_name = module.azureml_private_dns_zone.name
  virtual_network_id    = module.vnet.vnet_id
}

module "cognitive_project" {
  source = "../modules/azurerm/cognitive_project"

  name                 = "${var.workload}-${var.environment_prefix}-${var.suffix}"
  location             = var.location
  cognitive_account_id = module.cognitive.id
  tags                 = var.tags
}

module "cognitive_deployment" {
  source = "../modules/azurerm/cognitive_deployment"

  deployment_name      = var.openai_deployment_name
  cognitive_account_id = module.cognitive.id
  model_name           = var.openai_model_name
  model_version        = var.openai_model_version
  model_sku_name       = var.openai_model_sku_name
  model_sku_capacity   = var.openai_model_sku_capacity

  depends_on = [ module.cognitive_project ]
}

module "ai_agent" {
  source = "../modules/azurerm/ai_agent"

  name                  = "agent-${var.workload}-${var.environment_prefix}-${var.suffix}"
  cognitive_account_id  = module.cognitive.id
  model_deployment_name = var.openai_deployment_name
  search_endpoint       = module.search_service.endpoint
  search_index_name     = "ragdocs"
  
  project_id            = module.cognitive_project.id
  project_endpoints     = module.cognitive_project.endpoints
  search_service_name   = module.search_service.name
  knowledge_base_name   = "ragdocs"
  search_api_key        = module.search_service.apiKey
  search_service_id     = module.search_service.id
  search_index_connection_id = module.search_service.id
  subscription_id       = var.subscription_id
  resource_group_name        = module.resource_group.name
  foundry_name          = module.cognitive.name

  depends_on = [ module.cognitive_deployment, module.search_service_index ]
}

