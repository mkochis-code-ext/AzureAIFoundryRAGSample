variable "name" {
  description = "The name of the API Management Service"
  type        = string
}

variable "location" {
  description = "The Azure location where the API Management Service should exist"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group in which the API Management Service should exist"
  type        = string
}

variable "publisher_name" {
  description = "The name of publisher/company"
  type        = string
}

variable "publisher_email" {
  description = "The email of publisher/company"
  type        = string
}

variable "sku" {
  description = "The SKU name of the API Management Service"
  type        = string
  default     = "Developer"
}

variable "sku_count" {
  description = "The number of units of the SKU"
  type        = number
  default     = 1
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "subnet_id" {
  description = "The ID of the subnet to deploy APIM into"
  type        = string
  default     = null
}

variable "virtual_network_type" {
  description = "The type of virtual network configuration"
  type        = string
  default     = "None"
}

