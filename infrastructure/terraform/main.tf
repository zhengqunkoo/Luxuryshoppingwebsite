resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                = "acroslpprod003"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Premium"
  admin_enabled       = true
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet 1: Ingress (Dedicated for App Gateway)
resource "azurerm_subnet" "ingress_subnet" {
  name                 = "snet-ingress"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Subnet 2: Compute (AKS Nodes)
resource "azurerm_subnet" "compute_subnet" {
  name                 = "snet-compute"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Subnet 3: PaaS / Private Link (Data & AI)
resource "azurerm_subnet" "paas_subnet" {
  name                 = "snet-paas"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

output "acr_name" {
  value = azurerm_container_registry.acr.name
}

output "acr_repository" {
  value = var.acr_repository
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "azure_resource_group" {
  value = azurerm_resource_group.rg.name
}

output "azure_webapp_name" {
  value = azurerm_linux_web_app.web.name
}
