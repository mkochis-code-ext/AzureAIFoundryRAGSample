variable "name" {
  description = "The name of the API Management Backend."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group where the API Management Backend exists."
  type        = string
}

variable "api_management_name" {
  description = "The name of the API Management Service."
  type        = string
}

variable "protocol" {
  description = "The protocol used by the Backend."
  type        = string
  default     = "http"
}

variable "url" {
  description = "The URL of the Backend."
  type        = string
}
