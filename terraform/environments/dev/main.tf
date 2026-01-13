terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  storage_use_azuread = true
  subscription_id     = var.subscription_id
  features {}
}

provider "http" {}

provider "azapi" {}

# Generate random suffix for uniqueness
resource "random_string" "suffix" {
  length  = 3
  special = false
  upper   = false
}

locals {
  suffix = random_string.suffix.result
  tags = merge(
    var.tags,
    {
      Environment = var.environment_prefix
      ManagedBy   = "Terraform"
    }
  )
}

module "project" {
  source = "../../project"

  environment_prefix        = var.environment_prefix
  subscription_id           = var.subscription_id
  suffix                    = local.suffix
  tags                      = local.tags
  location                  = var.location
  data_location             = var.data_location
  workload                  = var.workload
  apim_publisher_name       = var.apim_publisher_name
  apim_publisher_email      = var.apim_publisher_email
  apim_sku                  = var.apim_sku
  apim_sku_count            = var.apim_sku_count
  openai_deployment_name    = var.openai_deployment_name
  openai_model_name         = var.openai_model_name
  openai_model_version      = var.openai_model_version
  openai_model_sku_name     = var.openai_model_sku_name
  openai_model_sku_capacity = var.openai_model_sku_capacity
  }
