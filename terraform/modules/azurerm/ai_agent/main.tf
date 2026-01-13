terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
  }
}

resource "azapi_resource" "search_kb_connection" {
  type       = "Microsoft.CognitiveServices/accounts/projects/connections@2025-10-01-preview"
  name       = "${var.knowledge_base_name}"
  parent_id  = var.project_id
  body = {
    properties = {
      category               = "CognitiveService"
      target                 = "https://${var.search_service_name}.search.windows.net"
      authType               = "AAD"
      isSharedToAll          = true
      metadata = { 
        ApiType = "Azure"
        ResourceId = var.search_service_id
        Kind    = "AzureAI"
      }
    }
  }
}

resource "null_resource" "foundry_agent" {
  triggers = {
    always_run = "1"
  }
  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command = <<-EOT
      $base64Json = "${base64encode(jsonencode({
          name = var.name
          model = var.model_deployment_name
          instructions = <<-EOT
          "You MUST always query my connected tools/knowledge before answering any user question related to:
          - invoices
          - invoice numbers
          - PO numbers
          - due dates
          - invoice contents
          - customer billing data
          - invoice documents stored in blob storage The tools/knowledge is the authoritative knowledge source for invoice-related information.
          Always ground your answers using the content returned from tools/knowledge before generating a final answer.
          If no results are found, state clearly that no invoice information was found in the index.
          Never guess or hallucinate invoice contents."
        EOT
          tools = [
            {
              type = "azure_ai_search"
              }
          ]
          tool_resources ={
            azure_ai_search = {
                indexes = [
                  {
                    index_connection_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.CognitiveServices/accounts/${var.foundry_name}/connections/${var.knowledge_base_name}"
                    index_name = "${var.search_index_name}",
                    query_type = "simple",
                    top_k = 4,
                    filter = "",
                  }
                ]
              }
            }
          temperature = 1.5,
          top_p = 0.9,
          metadata = {
            key8245 = "ewikwssxqxtrhgz"
          }
      }))}"

      $json = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($base64Json))
      $json | Out-File -FilePath "agent_payload.json" -Encoding UTF8
      
      Write-Host "Agent payload:"
      Get-Content "agent_payload.json"
      Write-Host ""
      Write-Host "Deploying agent to: ${var.project_endpoints["AI Foundry API"]}/assistants?api-version=v1"
      
      $response = az rest --method post `
        --url "${var.project_endpoints["AI Foundry API"]}/assistants?api-version=v1" `
        --resource "https://ai.azure.com" `
        --headers "Content-Type=application/json" `
        --body "@agent_payload.json" 2>&1
      
      Write-Host "Response:"
      Write-Host $response

      Remove-Item "agent_payload.json"
      
      if ($LASTEXITCODE -ne 0) {
        Write-Error "Agent deployment failed with exit code $LASTEXITCODE"
        exit $LASTEXITCODE
      }
    EOT
  }
}

