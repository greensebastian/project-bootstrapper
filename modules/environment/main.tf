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

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
  suffix  = [lower(var.domain), lower(var.name), lower(var.environment_name)]
}

module "regions" {
  source  = "Azure/regions/azurerm"
  version = "0.8.2"
}

locals {
  identifier = "${lower(var.domain)}-${lower(var.name)}-${lower(var.environment_name)}"
  region     = lookup(module.regions.regions_by_display_name, "North Europe", null)
}

data "github_user" "current" {
  username = ""
}

data "azuread_users" "contributors" {
  user_principal_names = var.users.contributors
}

data "azuread_users" "readers" {
  user_principal_names = var.users.readers
}

data "azuread_group" "administrators" {
  object_id = var.administrators_group_object_id
}

resource "azuread_group_without_members" "contributors" {
  display_name     = "${local.identifier}-contributors"
  owners           = data.azuread_group.administrators.members
  security_enabled = true
}

resource "azuread_group_without_members" "readers" {
  display_name     = "${local.identifier}-readers"
  owners           = data.azuread_group.administrators.members
  security_enabled = true
}

resource "azuread_group_member" "contributors" {
  for_each         = toset(data.azuread_users.contributors.object_ids)
  group_object_id  = azuread_group_without_members.contributors.object_id
  member_object_id = each.value
}

resource "azuread_group_member" "readers" {
  for_each         = toset(data.azuread_users.readers.object_ids)
  group_object_id  = azuread_group_without_members.readers.object_id
  member_object_id = each.value
}

resource "azuread_application" "app" {
  display_name = local.identifier
  owners       = data.azuread_group.administrators.members
}

resource "azuread_service_principal" "app" {
  client_id = azuread_application.app.client_id
}

resource "azuread_application_federated_identity_credential" "github_credential" {
  application_id = azuread_application.app.id
  display_name   = "${local.identifier}-deploy"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_repository.organization}/${var.github_repository.name}:environment:${var.environment_name}"
}

resource "azurerm_role_assignment" "app_contributor" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.app.object_id
}

resource "github_repository_environment" "environment" {
  environment = var.environment_name
  repository  = var.github_repository.name
  reviewers {
    users = [data.github_user.current.id]
  }
}

resource "azurerm_resource_group" "rg" {
  name     = module.naming.resource_group.name
  location = local.region.name
}
