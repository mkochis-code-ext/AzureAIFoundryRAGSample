
locals {
  endpoint = "https://${var.search_service_name}.search.windows.net"
  api_ver  = var.search_api_version
}

data "azurerm_client_config" "current" {}

# 1) Data Source
resource "null_resource" "datasource" {
    triggers = {
        always_run = "1"
    }
  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command = <<EOT
        $base64Json = "${
            base64encode(
                jsonencode(
                    {
                        name = "${var.datasource_name}"
                        type = "azureblob"
                        credentials = {
                            connectionString = "ResourceId=/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Storage/storageAccounts/${var.storage_account_name};"
                        }
                        container = { 
                            name = "${var.blob_container_name}"
                        }
                    }
                )
            )
        }"

        $json = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($base64Json))
        
        Write-Host "Datasource payload:"
        Write-Host $json
        Write-Host ""
        Write-Host "Deploying datasource to: ${local.endpoint}/datasources?api-version=${local.api_ver}"
        
        # Get Azure AD token for Azure Search
        $token = az account get-access-token --resource "https://search.azure.com" --query accessToken -o tsv
        
        $headers = @{
            "Content-Type" = "application/json"
            "Authorization" = "Bearer $token"
        }
        
        try {
            $response = Invoke-RestMethod -Method Post `
                -Uri "${local.endpoint}/datasources?api-version=${local.api_ver}" `
                -Headers $headers `
                -Body $json `
                -ErrorAction Stop
            
            Write-Host "Response:"
            Write-Host ($response | ConvertTo-Json -Depth 10)
            Write-Host "Datasource created successfully"
        } catch {
            Write-Host "Error: $($_.Exception.Message)"
            if ($_.ErrorDetails.Message) {
                Write-Host "Details: $($_.ErrorDetails.Message)"
            }
            exit 1
        }
    EOT
  }
}

# 2) Index
resource "null_resource" "index" {
    triggers = {
        always_run = "1"
    }
    provisioner "local-exec" {
        interpreter = ["PowerShell", "-Command"]
        command = <<EOT
            $base64Json = "${base64encode(jsonencode(
                {
                    name = "${var.index_name}"
                    fields = [
                                { 
                                    name = "id"
                                    type = "Edm.String"
                                    key = true
                                    filterable = true 
                                    searchable = true
                                    analyzer = "keyword"
                                },
                                {
                                    name = "parent_id"
                                    type = "Edm.String"
                                    key = false
                                    filterable = true
                                    searchable = true
                                    analyzer = "keyword"
                                },
                                { 
                                    name = "content"
                                    type = "Edm.String"
                                    searchable = true
                                    analyzer = "en.lucene" 
                                },
                                {
                                    name = "blob_url"
                                    type = "Edm.String"
                                    searchable = false
                                    filterable = true
                                    retrievable = true
                                    stored = true
                                    sortable = true
                                    facetable = false
                                    key = false
                                    synonymMaps = []
                                },
                                {
                                    name = "metadata_storage_path"
                                    type = "Edm.String"
                                    searchable = true
                                    filterable = true
                                    retrievable = true
                                    stored = true
                                    sortable = true
                                    facetable = false
                                    key = false
                                    analyzer = "standard.lucene"
                                    synonymMaps = []
                                },
                                {
                                    name = "metadata_storage_name"
                                    type = "Edm.String"
                                    searchable = true
                                    filterable = true
                                    retrievable = true
                                    stored = true
                                    sortable = true
                                    facetable = false
                                    key = false
                                    analyzer = "keyword"
                                    synonymMaps = []
                                },
                                {
                                    name = "metadata_storage_last_modified"
                                    type = "Edm.DateTimeOffset"
                                    searchable = false
                                    filterable = true
                                    retrievable = true
                                    stored = true
                                    sortable = true
                                    facetable = false
                                    key = false
                                    synonymMaps = []
                                },
                                {
                                    name = "metadata_storage_size"
                                    type = "Edm.Int64"
                                    searchable = false
                                    filterable = true
                                    retrievable = true
                                    stored = true
                                    sortable = true
                                    facetable = false
                                    key = false
                                    synonymMaps = []
                                },
                                {
                                    name = "invoiceNo"
                                    type = "Edm.String"
                                    searchable = true
                                    filterable = true
                                    retrievable = true
                                    stored = true
                                    sortable = false
                                    facetable = true
                                    key = false
                                    analyzer = "standard.lucene"
                                    synonymMaps = []
                                },
                                {
                                    name = "customerId"
                                    type = "Edm.String"
                                    searchable = true
                                    filterable = true
                                    retrievable = true
                                    stored = true
                                    sortable = false
                                    facetable = true
                                    key = false
                                    analyzer = "standard.lucene"
                                    synonymMaps = []
                                }
                    ],
                    suggesters = [
                        { 
                            name = "sg"
                            searchMode = "analyzingInfixMatching"
                            sourceFields = [ 
                                "content"
                            ] 
                        }
                    ]
                }
            ))}"

            $json = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($base64Json))
            
            Write-Host "Index payload:"
            Write-Host $json
            Write-Host ""
            Write-Host "Deploying index to: ${local.endpoint}/indexes?api-version=${local.api_ver}"
            
            # Get Azure AD token for Azure Search
            $token = az account get-access-token --resource "https://search.azure.com" --query accessToken -o tsv
            
            $headers = @{
                "Content-Type" = "application/json"
                "Authorization" = "Bearer $token"
            }
            
            try {
                $response = Invoke-RestMethod -Method Post `
                    -Uri "${local.endpoint}/indexes?api-version=${local.api_ver}" `
                    -Headers $headers `
                    -Body $json `
                    -ErrorAction Stop
                
                Write-Host "Response:"
                Write-Host ($response | ConvertTo-Json -Depth 10)
                Write-Host "Index created successfully"
            } catch {
                Write-Host "Error: $($_.Exception.Message)"
                if ($_.ErrorDetails.Message) {
                    Write-Host "Details: $($_.ErrorDetails.Message)"
                }
                exit 1
            }
        EOT
    }
    depends_on = [
        null_resource.datasource
    ]
}

# 3) Skillset with Knowledge store
resource "null_resource" "skillset" {
    triggers = {
        always_run = "1"
    }
    provisioner "local-exec" {
        interpreter = ["PowerShell", "-Command"]
        command = <<EOT
            $base64Json = "${base64encode(jsonencode(
                {
                    name = "${var.skillset_name}"
                    skills = [
                        {
                            "@odata.type" = "#Microsoft.Skills.Text.KeyPhraseExtractionSkill"
                            inputs = [ { name = "text", source = "/document/content" } ]
                            outputs = [ { name = "keyPhrases", targetName = "pages" } ]
                        }
                    ]
                    indexProjections = {
                        selectors = [
                        {
                            targetIndexName = "${var.index_name}",
                            parentKeyFieldName = "parent_id",
                            sourceContext = "/document/pages/*",
                            mappings = [
                            {
                                name = "content",
                                source = "/document/pages/*",
                                inputs = []
                            },
                            {
                                name = "blob_url",
                                source = "/document/metadata_storage_path",
                                inputs = []
                            },
                            {
                                name = "metadata_storage_name",
                                source = "/document/metadata_storage_name",
                                inputs = []
                            }
                            ]
                        }
                        ],
                        parameters = {
                            projectionMode = "skipIndexingParentDocuments"
                        }
                    }
                }
            ))}"

            $json = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($base64Json))
            
            Write-Host "Skillset payload:"
            Write-Host $json
            Write-Host ""
            Write-Host "Deploying skillset to: ${local.endpoint}/skillsets?api-version=${local.api_ver}"
            
            # Get Azure AD token for Azure Search
            $token = az account get-access-token --resource "https://search.azure.com" --query accessToken -o tsv
            
            $headers = @{
                "Content-Type" = "application/json"
                "Authorization" = "Bearer $token"
            }
            
            try {
                $response = Invoke-RestMethod -Method Post `
                    -Uri "${local.endpoint}/skillsets?api-version=${local.api_ver}" `
                    -Headers $headers `
                    -Body $json `
                    -ErrorAction Stop
                
                Write-Host "Response:"
                Write-Host ($response | ConvertTo-Json -Depth 10)
                Write-Host "Skillset created successfully"
            } catch {
                Write-Host "Error: $($_.Exception.Message)"
                if ($_.ErrorDetails.Message) {
                    Write-Host "Details: $($_.ErrorDetails.Message)"
                }
                exit 1
            }
        EOT
    }
    depends_on = [
        null_resource.datasource,
        null_resource.index
    ]
}

# 4) Indexer
resource "null_resource" "indexer" {
    triggers = {
        always_run = "1"
    }
    provisioner "local-exec" {
        interpreter = ["PowerShell", "-Command"]
        command = <<EOT
            $base64Json = "${base64encode(jsonencode(
            {
                name = "${var.indexer_name}"
                dataSourceName = "${var.datasource_name}"
                targetIndexName = "${var.index_name}"
                schedule = { interval = "P1D" }
                parameters = { configuration = { dataToExtract = "contentAndMetadata" } }
                fieldMappings = [
                {
                    sourceFieldName = "metadata_storage_path",
                    targetFieldName = "blob_url",
                    mappingFunction = null
                }
            ],
            }
            ))}"

            $json = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($base64Json))
            
            Write-Host "Indexer payload:"
            Write-Host $json
            Write-Host ""
            Write-Host "Deploying indexer to: ${local.endpoint}/indexers?api-version=${local.api_ver}"
            
            # Get Azure AD token for Azure Search
            $token = az account get-access-token --resource "https://search.azure.com" --query accessToken -o tsv
            
            $headers = @{
                "Content-Type" = "application/json"
                "Authorization" = "Bearer $token"
            }
            
            try {
                $response = Invoke-RestMethod -Method Post `
                    -Uri "${local.endpoint}/indexers?api-version=${local.api_ver}" `
                    -Headers $headers `
                    -Body $json `
                    -ErrorAction Stop
                
                Write-Host "Response:"
                Write-Host ($response | ConvertTo-Json -Depth 10)
                Write-Host "Indexer created successfully"
            } catch {
                Write-Host "Error: $($_.Exception.Message)"
                if ($_.ErrorDetails.Message) {
                    Write-Host "Details: $($_.ErrorDetails.Message)"
                }
                exit 1
            }
        EOT
    }
    depends_on = [
        null_resource.datasource,
        null_resource.index,
        null_resource.skillset
    ]
}