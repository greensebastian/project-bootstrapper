terraform {
  backend "azurerm" {
    storage_account_name = "stprojectbootstrapperne"
    container_name       = "tfstate"
    key                  = "project-bootstrapper"
  }
}
