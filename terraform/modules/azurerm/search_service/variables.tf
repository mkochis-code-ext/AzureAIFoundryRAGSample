variable "name" {
  description = "The name of the Azure AI Search service"
  type        = string
}

variable "location" {
  description = "The Azure location where the Search service should exist"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group in which the Search service should exist"
  type        = string
}

variable "sku" {
  description = "Search SKU (semantic typically requires Standard)"
  type        = string
  default     = "standard"
}

variable "replica_count" {
  description = "Replica count"
  type        = number
  default     = 1
}

variable "partition_count" {
  description = "Partition count"
  type        = number
  default     = 1
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled"
  type        = bool
  default     = true
}

variable "local_authentication_enabled" {
  description = "Whether admin key auth is enabled (set false to prefer AAD)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
