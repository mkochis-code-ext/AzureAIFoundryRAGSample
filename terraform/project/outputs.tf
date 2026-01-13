output "resource_group_id" {
  description = "The ID of the resource group"
  value       = module.resource_group.id
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.resource_group.name
}

output "resource_group_location" {
  description = "The location of the resource group"
  value       = module.resource_group.location
}

output "search_service_id" {
  description = "The ID of the Azure AI Search service"
  value       = module.search_service.id
}

output "search_service_name" {
  description = "The name of the Azure AI Search service"
  value       = module.search_service.name
}

output "search_service_endpoint" {
  description = "The endpoint of the Azure AI Search service"
  value       = module.search_service.endpoint
}

output "cognitive_service_endpoint" {
  description = "The endpoint of the Cognitive Services Account"
  value       = module.cognitive.endpoint
}

output "project_endpoints" {
  description = "The endpoints of the Azure AI Foundry Project"
  value       = module.cognitive_project.endpoints
}

output "apim_gateway_url" {
  description = "The URL of the API Management Gateway"
  value       = "https://${module.api_management.name}.azure-api.net"
}
