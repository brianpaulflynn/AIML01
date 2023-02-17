terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.76.0"
    }
  }
}
provider "azurerm" {
  features {}
    subscription_id="${var.ARM_SUBSCRIPTION_ID}"
    tenant_id="${var.ARM_TENANT_ID}"
    client_id="${var.ARM_CLIENT_ID}"
    client_secret="${var.ARM_CLIENT_SECRET}"
}
data "azurerm_client_config" "current" {}
