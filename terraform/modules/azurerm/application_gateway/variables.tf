variable "name" {
  description = "Name of the Application Gateway"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for Application Gateway"
  type        = string
}

variable "backend_fqdns" {
  description = "Backend FQDNs"
  type        = list(string)
  default     = []
}

variable "backend_ip_addresses" {
  description = "Backend IP Addresses"
  type        = list(string)
  default     = []
}

variable "sku_name" {
  description = "SKU name"
  type        = string
}

variable "sku_tier" {
  description = "SKU tier"
  type        = string
}

variable "capacity" {
  description = "Capacity (instance count)"
  type        = number
}

variable "ssl_certificate_data" {
  description = "Base64 encoded SSL certificate data (PFX format)"
  type        = string
  sensitive   = true
}

variable "ssl_certificate_password" {
  description = "Password for the SSL certificate"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to the resource"
  type        = map(string)
  default     = {}
}
