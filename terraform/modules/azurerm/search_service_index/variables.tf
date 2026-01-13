
variable "resource_group_name" { 
    type = string 
}
variable "location" { 
    type = string 
}
variable "search_service_name" { 
    type = string 
}

variable "storage_connection_string" { 
    type = string 
}
variable "storage_account_name" {
    type = string
}
variable "blob_container_name" { 
    type = string 
}

# Logical names
variable "datasource_name" { 
    type = string 
}
variable "index_name" { 
    type = string 
}
variable "skillset_name" { 
    type = string 
}
variable "indexer_name" { 
    type = string 
}

# API version (keep current)
variable "search_api_version" {
  type    = string
  default = "2024-07-01"
}
