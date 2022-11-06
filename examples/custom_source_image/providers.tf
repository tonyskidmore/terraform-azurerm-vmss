terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.1.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">=3.2.0"
    }
  }

  required_version = ">= 1.0.0"
}

provider "azurerm" {
  features {}
}
