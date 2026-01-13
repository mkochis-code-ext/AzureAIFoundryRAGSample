variable "name" {
  description = "The name of the API"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group"
  type        = string
}

variable "api_management_name" {
  description = "The name of the API Management Service"
  type        = string
}

variable "revision" {
  description = "The revision of the API"
  type        = string
}

variable "display_name" {
  description = "The display name of the API"
  type        = string
}

variable "path" {
  description = "The path for the API"
  type        = string
}

variable "protocols" {
  description = "The protocols supported by the API"
  type        = list(string)
}

variable "service_url" {
  description = "The service URL for the API"
  type        = string
}

variable "subscription_required" {
  description = "Whether subscription is required"
  type        = bool
}

variable "content_format" {
  description = "The format of the content to import"
  type        = string
  default     = null
}

variable "content_value" {
  description = "The value of the content to import"
  type        = string
  default     = null
}
