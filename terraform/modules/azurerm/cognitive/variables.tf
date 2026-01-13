variable "name" {
  description = "Base name for resources (will be used to generate names for Hub, Project, Storage, etc.)"
  type        = string
}

variable "location" {
  description = "The Azure location where the resources should exist"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "storage_account_id" {
  description = "The ID of the Storage Account"
  type        = string
}

variable "key_vault_id" {
  description = "The ID of the Key Vault"
  type        = string
}

variable "application_insights_id" {
  description = "The ID of the Application Insights"
  type        = string
}

variable "enable_private_networking" {
  description = "Whether to enable private networking"
  type        = bool
  default     = false
}

