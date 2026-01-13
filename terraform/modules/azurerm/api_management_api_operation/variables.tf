variable "operation_id" {
  type = string
}

variable "api_name" {
  type = string
}

variable "api_management_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "display_name" {
  type = string
}

variable "method" {
  type = string
}

variable "url_template" {
  type = string
}

variable "description" {
  type    = string
  default = ""
}

variable "template_parameters" {
  description = "List of template parameters for the URL template"
  type = list(object({
    name        = string
    type        = string
    required    = bool
    description = optional(string) 
    values      = optional(list(string))
  }))
  default = []
}
