terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.1.0"
    }
  }

  required_version = ">= 0.13.0"
}

provider "azurerm" {
  features {}
}
