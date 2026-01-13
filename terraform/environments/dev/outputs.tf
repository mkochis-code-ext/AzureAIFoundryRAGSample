output "resource_group_id" {
  description = "The ID of the resource group"
  value       = module.project.resource_group_id
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.project.resource_group_name
}

output "resource_group_location" {
  description = "The location of the resource group"
  value       = module.project.resource_group_location
}

output "search_service_id" {
  description = "The ID of the Azure AI Search service"
  value       = module.project.search_service_id
}

output "cognitive_service_endpoint" {
    value = module.project.cognitive_service_endpoint
}

# output "apim_gateway_url" {
#     value = module.project.apim_gateway_url
# }

output "search_service_name" {
  description = "The name of the Azure AI Search service"
  value       = module.project.search_service_name
}

output "search_service_endpoint" {
  description = "The endpoint of the Azure AI Search service"
  value       = module.project.search_service_endpoint
}
