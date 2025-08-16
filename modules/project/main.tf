terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.5.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.40.0"
    }
  }
}

provider "azuread" {}

provider "azurerm" {
  features {}
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
  suffix  = [lower(var.domain), lower(var.name), lower(var.environment)]
}

locals {
  name = "${var.domain}-${var.name}-${var.environment}"
}

data "azuread_client_config" "current" {}

resource "azuread_application" "app" {
  display_name = local.name
  owners       = [data.azuread_client_config.current.object_id]
}
