# Azure AI Foundry RAG Sample with Azure AI Search

This repository demonstrates how to build a complete Retrieval-Augmented Generation (RAG) solution using Azure AI Foundry. The solution connects an AI Agent to document data stored in Azure Blob Storage through Azure AI Search, with secure access via Azure API Management (APIM).

## Architecture Overview

The solution deploys the following resources:

*   **Azure OpenAI Service:** Hosts the GPT model and AI Agent.
*   **Azure AI Foundry Project:** Manages the AI Agent configuration.
*   **Azure AI Search:** Indexes documents from blob storage and provides semantic search capabilities for RAG.
*   **Azure Storage Account:** Stores source documents (invoice .txt files) in a blob container named `test`.
*   **Azure API Management:** Acts as the secure gateway and entry point for all client requests.
*   **Virtual Network (VNet):** Provides a secure network boundary.
*   **Private Endpoint:** Connects the VNet securely to the Azure OpenAI service.
*   **Private DNS Zone:** Ensures proper DNS resolution for the private endpoint.
*   **Supporting Services:** Key Vault, Application Insights, and Log Analytics for observability.

## How RAG Works in This Solution

1.  **Document Storage:** Invoice documents (`.txt` files) are uploaded to the Storage Account's `test` container by the user.
2.  **Indexing Pipeline:** An Azure AI Search indexer automatically:
    *   Connects to the blob container via a datasource (configured with managed identity)
    *   Extracts content and metadata from documents using a skillset
    *   Applies AI skills including key phrase extraction
    *   Populates the search index (`ragdocs`) with indexed content
3.  **Agent Query:** When a user asks a question through the AI Agent:
    *   The agent uses Azure AI Search to find relevant document chunks from the indexed invoices
    *   Retrieved context is combined with the user's question
    *   The GPT model generates a grounded response based on the indexed documents
4.  **Secure Access:** All agent interactions flow through APIM, which enforces authentication and routing policies.

## Security Posture

This architecture prioritizes security by minimizing public exposure and using identity-based authentication.

### Network Security
*   **Private Backend:** Public network access to the Azure OpenAI service is **disabled**. It can only be accessed via its Private Endpoint.
*   **VNet Integration:**
    *   **APIM:** Deployed in "External" mode within a dedicated subnet (`snet-apim`). This allows it to accept public traffic while having direct access to private resources in the VNet.
    *   **OpenAI:** Connected to the VNet via a Private Endpoint in a dedicated subnet (`snet-pe`).
*   **Traffic Flow:** All traffic between APIM and OpenAI travels over the Microsoft Azure backbone network, never traversing the public internet.

### Authentication & Authorization
*   **Identity-Based Access:** The solution is configured to use Azure Active Directory (Entra ID) tokens.
*   **Token Pass-through:** API Management is configured to pass the client's `Authorization` header (Bearer token) directly to the OpenAI backend.
*   **No Static Keys:** The APIM configuration does not store or inject static API keys for the backend connection, reducing the risk of credential leakage.

### API Policy
*   **CORS:** A Cross-Origin Resource Sharing (CORS) policy is applied to allow safe cross-origin requests from web clients.
*   **Token Limiting:** An `llm-token-limit` policy is configured to manage consumption, limiting usage to 5,000 tokens per minute and 50,000 tokens per hour per IP address.

## Data Path

1.  **Client Request:** A user or application sends an HTTPS request to the public API Management endpoint.
    *   URL: `https://apim-<workload>-<env>-<suffix>.azure-api.net/agent/...`
    *   Header: `Authorization: Bearer <valid-azure-ad-token>`
2.  **Gateway Entry:** The request hits the APIM Gateway.
3.  **DNS Resolution:** APIM, running inside the VNet, queries the `privatelink.cognitiveservices.azure.com` Private DNS Zone to resolve the OpenAI/Foundry hostname.
4.  **Private Routing:** The DNS zone returns the **Private IP** address of the backend service.
5.  **Backend Access:** APIM forwards the request securely through the VNet to the Private Endpoint of the Azure AI Foundry Project.
6.  **Response:** The model processes the request and returns the response via the same secure path.

## Deployment

### Prerequisites
*   Azure CLI (`az`)
*   Terraform (>= 1.0)
*   PowerShell
*   An active Azure Subscription with sufficient permissions to create resources and assign RBAC roles

### Step 1: Deploy Infrastructure

1.  Navigate to the `terraform/environments/dev` directory:
    ```bash
    cd terraform/environments/dev
    ```

2.  Copy the example variables file:
    ```bash
    cp terraform.tfvars.example terraform.tfvars
    ```

3.  Update `terraform.tfvars` with your specific values (e.g., `subscription_id`, `workload`, `apim_publisher_email`).

4.  Initialize Terraform:
    ```bash
    terraform init
    ```

5.  **First Apply** - Deploy the infrastructure:
    ```bash
    terraform apply
    ```
    
    **Note:** The first apply may encounter issues with role assignments that depend on managed identities being created first. This is expected.

6.  **Second Apply** - Complete role assignments:
    ```bash
    terraform apply
    ```
    
    Run the apply a second time to ensure all role assignments (RBAC) are properly configured after the managed identities have been created and propagated.

7.  **Capture Outputs:** Note the following Terraform outputs for later steps:
    *   `resource_group_name`
    *   `search_service_name`
    *   `cognitive_service_endpoint`
    *   `search_service_endpoint`

### Step 2: Grant Your User Storage Access

Before uploading documents, grant your Entra ID account `Storage Blob Data Contributor` access on the storage account

**Wait 2-5 minutes** for the role assignment to propagate before proceeding to the next step.

### Step 3: Upload Invoice Documents

Upload your invoice `.txt` files to the `test` container in the storage account. This solution is designed to work with generic invoice data in plain text format.

**Example Invoice Format (.txt):**
```
Invoice Number: INV-2024-001
Customer ID: CUST-12345
Date: 2024-01-15
Amount: $1,250.00
Description: Professional Services
...
```

### Step 4: Run the Search Indexer

After uploading documents, trigger the indexer to process and index the documents:

**Verify Indexing:**
*   Check the indexer status in the Azure Portal: Navigate to your Search Service → **Indexers** → `doc-indexer`
*   Wait for the indexer to complete (status should show "Success")
*   Verify documents are indexed: Check the document count in the search index (`ragdocs`)

### Step 5: Test the Agent

#### Option A: Azure AI Foundry Studio (Recommended)

1.  Navigate to [Azure AI Foundry Studio](https://ai.azure.com)
2.  Sign in with your Azure account
3.  Open your AI project (format: `<workload>-<env>-<suffix>`)
4.  Go to **Agents** in the left navigation
5.  Select your agent: `agent-<workload>-<env>-<suffix>`
6.  Use the **Playground** to test queries:
    *   "What invoices do we have?"
    *   "Show me details for invoice INV-2024-001"
    *   "What's the total amount for customer CUST-12345?"
    *   "List all invoices from January 2024"

The agent should retrieve relevant information from your indexed invoice documents.

## Usage

### Web Application
1.  Open `app/index.html` in your browser.
2.  Fill in the configuration:
    *   **Agent API Base URL:** Enter the `apim_gateway_url` output with the `/agent` suffix (e.g., `https://apim-....azure-api.net/agent`).
    *   **Agent Name/ID:** Enter the Agent ID from the Foundry Studio (e.g., `asst_...`).
    *   **API Version:** Default is `v1` (for Foundry Agents) or `2024-05-01-preview` (for Azure OpenAI).
    *   **Access Token:** Generate a token using:
        ```bash
        az account get-access-token --resource https://ai.azure.com --query accessToken -o tsv
        ```
3.  Start chatting!

## Search Index Schema

The Azure AI Search index (`ragdocs`) includes the following fields designed for invoice data:

*   `id` - Unique identifier (key)
*   `parent_id` - Parent document reference
*   `content` - Full text content
*   `blob_url` - Source blob URL
*   `metadata_storage_path` - Storage path
*   `metadata_storage_name` - File name
*   `metadata_storage_last_modified` - Last modified timestamp
*   `metadata_storage_size` - File size
*   `invoiceNo` - Invoice number (searchable, filterable, facetable)
*   `customerId` - Customer identifier (searchable, filterable, facetable)

The indexer uses a skillset with key phrase extraction to enhance search quality.

## Troubleshooting

### Indexer Fails to Run
*   Verify the Search service has `Storage Blob Data Reader` role on the Storage Account
*   Check that documents exist in the `test` container
*   Review indexer execution history in Azure Portal

### Agent Returns Generic Responses
*   Verify documents are indexed: Check document count in Search service
*   Ensure the agent is connected to the correct search index (`ragdocs`)
*   Test search directly in the Azure Portal Search Explorer

### RBAC Permission Errors
*   Wait 2-5 minutes after role assignments for propagation
*   Run `terraform apply` a second time to resolve timing issues
*   Verify you're logged in with `az account show`

### Token Expired
*   Access tokens expire after 1 hour
*   Regenerate with: `az account get-access-token --resource https://ai.azure.com --query accessToken -o tsv`
