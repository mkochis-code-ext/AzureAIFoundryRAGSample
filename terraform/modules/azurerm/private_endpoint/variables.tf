variable "name" {
  description = "The name suffix for the resources"
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

variable "subnet_id" {
  description = "The ID of the Subnet where the Private Endpoint should be created"
  type        = string
}

variable "private_connection_resource_id" {
  description = "The ID of the Private Link Enabled Remote Resource"
  type        = string
}

variable "subresource_names" {
  description = "A list of subresource names which the Private Endpoint is able to connect to"
  type        = list(string)
}

variable "private_dns_zone_ids" {
  description = "The IDs of the Private DNS Zones"
  type        = list(string)
}



variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
