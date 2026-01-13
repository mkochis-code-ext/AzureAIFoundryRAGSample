variable "deployment_name" {
  description = "The name of the model deployment"
  type        = string
}

variable "cognitive_account_id" {
  description = "The ID of the Cognitive Account"
  type        = string
}

variable "model_name" {
  description = "The name of the model to deploy (e.g. gpt-4)"
  type        = string
}

variable "model_version" {
  description = "The version of the model to deploy"
  type        = string
}

variable "model_sku_name" {
  description = "The SKU Name for the model deployment"
  type        = string
}

variable "model_sku_capacity" {
  description = "The SKU Capacity for the model deployment"
  type        = number
}
