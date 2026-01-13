variable "name" {
  description = "The name of the Private DNS Zone Virtual Network Link."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group."
  type        = string
}

variable "private_dns_zone_name" {
  description = "The name of the Private DNS Zone."
  type        = string
}

variable "virtual_network_id" {
  description = "The ID of the Virtual Network."
  type        = string
}
