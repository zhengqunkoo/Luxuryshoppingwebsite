# Cloud Architecture (Azure)

This document outlines the target cloud architecture for the AI-assisted Online Shopping for Luxury Products (OSLP) platform, based on the Project Proposal Final Report.

## Architecture Diagram (Mermaid)

The following diagram represents the **Phase 2 Target State** (Kubernetes Microservices), optimized for security and high availability.

![Cloud Architecture](cloud_architecture.png)

```mermaid
graph TD
    %% External Actors
    subgraph External ["External"]
        Users[Users]
        Internet((Internet))
        Users --> Internet
    end

    %% Azure Cloud Boundary
    subgraph Azure ["Azure Cloud"]
        style Azure fill:#fff,stroke:#0072C6,stroke-width:2px

        %% Edge Services
        FD["Azure Front Door"]
        style FD fill:#0072C6,color:#fff
        Internet -- https --> FD

        %% External Management Services
        subgraph Management ["Management & Identity"]
            ADB2C["Azure Active Directory B2C<br/>- Customer Auth<br/>- MFA / SSO"]
            Monitor["Azure Monitor & App Insights<br/>- Logs<br/>- Metrics<br/>- Alerts"]
        end
        
        %% CI/CD
        Github["Github Actions<br/>CI/CD Pipeline"]

        %% VNET
        subgraph VNet ["vnet-main"]
            style VNet fill:#fffbf0,stroke:#f66,stroke-dasharray: 5 5

            %% Subnet 1: Ingress (Dedicated Subnet required for App Gateway)
            subgraph Subnet_Ingress ["Ingress Subnet"]
                style Subnet_Ingress fill:#e6e6e6,stroke:#666,stroke-dasharray: 5 5
                AGW["Application Gateway (WAF)"]
            end

            %% Subnet 2: Compute
            subgraph Subnet_Compute ["Compute Subnet (AKS)"]
                style Subnet_Compute fill:#e6e6e6,stroke:#666,stroke-dasharray: 5 5

                %% AKS Cluster
                subgraph AKS ["Azure Kubernetes Service Cluster"]
                    style AKS fill:#e0f7fa,stroke:#00acc1

                    %% Microservices
                    Web_Svc["Frontend Service<br/>(Storefront & Admin)"]
                    AI_Svc["AI Assistance Service<br/>API Orchestrator"]
                    Product_Svc["Product Catalog Service<br/>Product & Pricing API"]
                    Order_Svc["Order & Inventory Service<br/>Order Management API"]
                    
                    HPA["Horizontal Pod Autoscaler (HPA)"]

                    %% Service Communication
                    Web_Svc --> AI_Svc
                    Web_Svc --> Product_Svc
                    Web_Svc --> Order_Svc
                    
                    %% Orchestrator Logic
                    AI_Svc --> Order_Svc
                    
                    %% HPA Scaling Relationships
                    HPA -.-> Web_Svc
                    HPA -.-> AI_Svc
                    HPA -.-> Product_Svc
                    HPA -.-> Order_Svc
                end
            end

            %% Container Registry (Connected via Private Endpoint)
            ACR["Azure Container Registry"]

            %% Subnet 3: Private Link / PaaS Services
            subgraph Subnet_PaaS ["Private Link Subnet"]
                style Subnet_PaaS fill:#e6e6e6,stroke:#666,stroke-dasharray: 5 5
                
                %% Data Services
                subgraph Data_Box ["Data Services"]
                    style Data_Box fill:#e0f7fa,stroke:#00acc1,stroke-dasharray: 5 5
                    Blob["Azure Blob Storage"]
                    SQL["Azure SQL Database"]
                    Redis["Azure Cache for Redis"]
                end

                %% AI & Security PaaS (Moved out of AKS)
                KV["Azure Key Vault"]
            end
            
            %% Traffic Flow
            FD -- https --> AGW
            AGW --> Web_Svc

            %% Correct Data Access Paths (Pods -> Private Link)
            Product_Svc -->|Private Endpoint| SQL
            Order_Svc -->|Private Endpoint| SQL
            
            Product_Svc -->|Private Endpoint| Redis
            Order_Svc -->|Private Endpoint| Redis
            AI_Svc -->|Private Endpoint| Redis

            Product_Svc -->|Private Endpoint| Blob
            Web_Svc -->|Private Endpoint| Blob

            %% Secrets Access
            AKS -->|Private Endpoint / CSI| KV
            Data_Box -.->|Encryption Keys| KV

        end
    end

    %% CI/CD Flow
    Github -->|Build & Push| ACR
    Github -->|"Deploy (Manifests)"| AKS
    ACR -.->|Pull Images| AKS
    
    %% Management Connections
    Web_Svc --> ADB2C
    
    %% Monitoring
    Monitor -.-> AKS
    Monitor -.-> SQL
    Monitor -.-> FD
    Monitor -.-> AGW
```

## Component Breakdown

### 1. Edge & Entry
- **Azure Front Door**: Global load balancer with CDN capabilities to ensure low latency and high availability.
- **Application Gateway (WAF)**: Regional load balancer deployed in a dedicated `Ingress Subnet`. Protects the AKS cluster from web vulnerabilities (OWASP Top 10).

### 2. Compute (AKS)
- **Azure Kubernetes Service (AKS)**: Hosted in the `Compute Subnet`.
- **Microservices**:
    - `Frontend`: Storefront and Admin UI.
    - `Product`: Catalog and Pricing API.
    - `Order`: Inventory and Order Management.
    - `AI Orchestrator`: Manages interaction with Azure OpenAI.
- **Scaling**: Horizontal Pod Autoscaler (HPA) adjusts replica counts based on demand.

### 3. Networking & Security
- **VNet Structure**:
    - `Ingress Subnet`: Dedicated for Application Gateway.
    - `Compute Subnet`: Dedicated for AKS Nodes.
    - `Private Link Subnet`: Hosting Private Endpoints for PaaS resources.
- **Private Link**: Ensures traffic between AKS and Data/AI services travels over the Microsoft backbone network, never the public internet.
- **Azure AD B2C**: Handles customer identity.
- **Azure Key Vault**: Stores secrets, accessed via CSI Driver or Private Link.

### 4. Data & AI (PaaS)
- **Azure SQL Database**: Relational store.
- **Azure Cache for Redis**: High-performance caching.
- **Azure Blob Storage**: Media assets.
- **Note**: *Azure OpenAI Service* is currently omitted in favor of direct API usage but is planned for future phases to enhance security and compliance.

## Infrastructure as Code (Terraform)

The infrastructure is defined using Terraform in the `infrastructure/terraform` directory.

### Prerequisites
- Terraform >= 1.0
- Azure CLI
- Active Azure Subscription

### Deployment
1. `cd infrastructure/terraform`
2. `terraform init`
3. `terraform plan -out main.tfplan`
4. `terraform apply main.tfplan`
