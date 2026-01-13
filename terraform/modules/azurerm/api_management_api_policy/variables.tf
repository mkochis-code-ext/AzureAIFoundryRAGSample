variable "api_name" {
  description = "The name of the API"
  type        = string
}

variable "api_management_name" {
  description = "The name of the API Management Service"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group"
  type        = string
}

variable "xml_content" {
  description = "The XML content for the policy"
  type        = string
}

variable "xml_link" {
  description = "The link to the XML content for the policy"
  type        = string
  default     = null
}
