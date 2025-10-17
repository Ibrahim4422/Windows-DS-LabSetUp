terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.113"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "b0a3fc70-2e57-4cdb-8d94-6b3e721f6c43"
}
