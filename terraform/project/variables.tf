variable "subscription_id" {
  description = "The Azure Subscription ID"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "environment_prefix" {
  description = "Environment prefix"
  type        = string
}

variable "suffix" {
  description = "Random suffix for uniqueness"
  type        = string
}

variable "data_location" {
  description = "Azure region for data resources"
  type        = string
}

variable "workload" {
  description = "Workload name"
  type        = string
}

variable "apim_publisher_name" {
  description = "The name of publisher/company for APIM"
  type        = string
  default     = "Contoso"
}

variable "apim_publisher_email" {
  description = "The email of publisher/company for APIM"
  type        = string
  default     = "admin@contoso.com"
}

variable "apim_sku" {
  description = "The SKU name of the API Management Service"
  type        = string
  default     = "Developer"
}

variable "apim_sku_count" {
  description = "The number of units of the SKU"
  type        = number
  default     = 1
}

variable "openai_deployment_name" {
  description = "Name of the OpenAI deployment"
  type        = string
  default     = "gpt-4"
}

variable "openai_model_name" {
  description = "Name of the OpenAI model"
  type        = string
  default     = "gpt-4"
}

variable "openai_model_version" {
  description = "Version of the OpenAI model"
  type        = string
  default     = "1106-Preview"
}

variable "openai_model_sku_name" {
  description = "The SKU Name for the model deployment"
  type = string
}

variable "openai_model_sku_capacity" {
  description = "The SKU Capacity for the model deployment"
  type = number
}
