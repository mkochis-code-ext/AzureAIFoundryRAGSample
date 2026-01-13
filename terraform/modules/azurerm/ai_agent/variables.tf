variable "name" {
  type        = string
  description = "The name of the AI Agent."
}

variable "subscription_id" {
  description = "The Azure Subscription ID"
  type        = string
}

variable "resource_group_name" { 
  description = "The Azure Resource Group Name"
  type        = string
}

variable "foundry_name" {
  description = "The name of the AI Foundry Cognitive Services Account."
  type        = string
}

variable "cognitive_account_id" {
  type        = string
  description = "The ID of the Cognitive Services Account."
}

variable "model_deployment_name" {
  type        = string
  description = "The name of the model deployment (e.g. gpt-4o)."
}

variable "search_endpoint" {
  type        = string
  description = "The endpoint of the Azure AI Search service."
}

variable "search_index_name" {
  type        = string
  description = "The name of the search index."
}

variable "search_key_names" {
  type        = list(string)
  default     = []
  description = "(Optional) If we need keys, usually we use RBAC now."
}

variable "project_id" {
  type        = string
  description = "The ID of the AI Foundry Project."
}

variable "project_endpoints" {
  type        = map(string)
  default     = {}
}

variable "search_service_name" {
  type        = string
  description = "The name of the Azure AI Search service."
}

variable "search_service_id" {
  type        = string
  description = "The ID of the Azure AI Search service."
}

variable "knowledge_base_name" {
  type        = string
  description = "The name of the knowledge base (search index)."
}

variable "instructions" {
  type        = string
  default     = "You are a helpful AI assistant tasked with answering questions based on the provided knowledge base."
  description = "The instructions for the AI Agent."
}

variable "search_api_key" {
  type = string
  description = "The Search Resource api key"
}

variable "search_index_connection_id" {
  type = string
  description = "The Search Resource index id"
}