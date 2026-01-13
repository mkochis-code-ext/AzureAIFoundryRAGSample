variable "name" {
  description = "The name of the Storage Account"
  type        = string
}

variable "location" {
  description = "The Azure location where the resource should exist"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "containers" {
  description = "Map of container names to their configuration"
  type = map(object({
    access_type = string  # "private", "blob", or "container"
  }))
  default = {}
}