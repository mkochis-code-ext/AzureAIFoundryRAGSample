variable "name" {
  description = "The name suffix for the project"
  type        = string
}

variable "location" {
  description = "The Azure location where the resources should exist"
  type        = string
}

variable "cognitive_account_id" {
  description = "The ID of the Cognitive Account"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
