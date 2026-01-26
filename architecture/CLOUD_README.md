# Cloud Architecture (Azure)

This document outlines the target cloud architecture for the AI-assisted Online Shopping for Luxury Products (OSLP) platform, based on the Project Proposal Final Report.

## Architecture Diagram (Mermaid)

The following diagram represents the **Phase 2 Target State** (Kubernetes Microservices), evolving from the Phase 1 (App Service PaaS) model.

```mermaid
graph TD
    %% User Layer
    subgraph Clients
        Customer[Customer (Web/Mobile)]
        Admin[Shop Administrator]
    end

    %% Edge Layer
    subgraph Azure_Edge [Azure Edge Services]
        AFD[Azure Front Door]
        WAF[Web Application Firewall]
        CDN[Azure CDN]
        AFD --> WAF
        AFD --> CDN
    end

    %% Identity & Security
    subgraph Identity_Security [Identity & Security]
        ADB2C[Azure AD B2C]
        KV[Azure Key Vault]
    end

    %% Compute Layer (AKS)
    subgraph AKS_Cluster [Azure Kubernetes Service (AKS)]
        Ingress[App Gateway Ingress Controller]
        
        subgraph Pods
            WebPod[oslp-web (Frontend)]
            AIPod[oslp-ai (AI Advisor)]
            CorePod[oslp-core (Commerce API)]
            SecretPod[secret-provider]
        end

        HPA[Horizontal Pod Autoscaler]
    end

    %% AI Services
    subgraph AI_Services [Azure AI]
        OpenAI[Azure OpenAI Service]
        AISearch[Azure AI Search]
    end

    %% Data Layer
    subgraph Data_Services [Data Services (VNet Secured)]
        SQL[Azure SQL Database]
        Redis[Azure Cache for Redis]
        Blob[Azure Blob Storage]
    end

    %% DevOps & Monitoring
    subgraph DevOps [DevOps & Management]
        ACR[Azure Container Registry]
        Monitor[Azure Monitor / Log Analytics]
        Pipelines[Azure DevOps Pipelines]
    end

    %% Connections
    Customer -->|HTTPS| AFD
    Admin -->|HTTPS| AFD
    
    AFD -->|Traffic Route| Ingress
    
    Ingress --> WebPod
    Ingress --> CorePod
    
    %% Application Logic
    WebPod -->|API Calls| CorePod
    WebPod -->|Auth| ADB2C
    
    CorePod -->|Read/Write| SQL
    CorePod -->|Cache| Redis
    CorePod -->|Images/Logs| Blob
    CorePod -->|Search| AISearch

    %% AI Integration
    WebPod -->|Chat| AIPod
    AIPod -->|Inference| OpenAI
    AIPod -->|Context| Redis

    %% Security & Secrets
    SecretPod -.->|Mount Secrets| WebPod
    SecretPod -.->|Mount Secrets| CorePod
    SecretPod -.->|Mount Secrets| AIPod
    SecretPod -->|Fetch| KV

    %% Deployment
    Pipelines -->|Build & Push| ACR
    Pipelines -->|Deploy| AKS_Cluster

    %% Monitoring
    Monitor -.->|Logs & Metrics| AKS_Cluster
    Monitor -.->|Logs| SQL
    Monitor -.->|Logs| AFD
```

## Component Breakdown

### 1. Edge & Entry
- **Azure Front Door**: Global load balancer with CDN capabilities to ensure low latency and high availability.
- **WAF (Web Application Firewall)**: Protects against common web exploits (OWASP top 10).

### 2. Compute (AKS)
- **Ingress Controller**: Routes incoming traffic to the appropriate service pods.
- **oslp-web**: The frontend application (Flask/Jinja2) serving the UI.
- **oslp-core**: The backend commerce API handling business logic.
- **oslp-ai**: Dedicated service for managing AI interactions.
- **Horizontal Pod Autoscaler (HPA)**: Automatically scales pods based on CPU/Memory usage.

### 3. Data & Storage
- **Azure SQL Database**: Managed relational database for persistent data (Users, Orders, Products).
- **Azure Cache for Redis**: In-memory data store for session management and high-speed caching.
- **Azure Blob Storage**: Stores unstructured data like product images and logs.

### 4. Artificial Intelligence
- **Azure OpenAI Service**: Powers the "Virtual Advisor" for personalized shopping experiences.
- **Azure AI Search**: Enhances product discovery with intelligent search capabilities.

### 5. Security & Identity
- **Azure AD B2C**: Handles customer identity management (Sign-up, Sign-in).
- **Azure Key Vault**: securely stores secrets, keys, and certificates.
- **Private Endpoints**: Ensures traffic between apps and data services remains on the Microsoft backbone network, not the public internet.

### 6. DevOps
- **Azure DevOps Pipelines**: CI/CD for automated testing and deployment.
- **Azure Container Registry**: Stores Docker images.
- **Azure Monitor**: Provides full-stack observability.
