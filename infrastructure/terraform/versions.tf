terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
  subscription_id = "5b12417c-36fe-453a-995f-20d5624f9c58"
  tenant_id       = "5ba5ef5e-3109-4e77-85bd-cfeb0d347e82"
}
