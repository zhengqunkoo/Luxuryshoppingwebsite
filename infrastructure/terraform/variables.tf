variable "acr_repository" {
  description = "Name of the ACR repository"
  default     = "luxury-shopping"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "rg-oslp-prod-003"
}

variable "location" {
  description = "Azure region"
  default     = "southeastasia"
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
  default     = "vnet-oslp-prod-003"
}

variable "aks_name" {
  description = "Name of the AKS Cluster"
  default     = "aks-oslp-prod-003"
}
