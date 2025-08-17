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

    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
  }
}

provider "azuread" {}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "github" {
  owner = "greensebastian"
}

module "demo" {
  source = "./modules/project"

  administrators = ["sebastianpetergreen_outlook.com#EXT#_sebastianpetergreZELYY#EXT#@sebastiangreen.onmicrosoft.com"]
  domain         = "test"
  name           = "demo"
  environments = {
    dev = {
      users = {
        contributors = []
        readers      = []
    } }
  }
}
