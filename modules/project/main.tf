terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.5.0"
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
  suffix  = [lower(var.domain), lower(var.name)]
}

locals {
  identifier               = "${lower(var.domain)}-${lower(var.name)}"
  administrator_object_ids = toset(concat([data.azuread_client_config.current.object_id], tolist(data.azuread_users.administrators.object_ids)))
}

data "azuread_client_config" "current" {}

data "azuread_users" "administrators" {
  user_principal_names = var.administrators
}

resource "azuread_group_without_members" "administrators" {
  display_name     = "${local.identifier}-administrators"
  owners           = local.administrator_object_ids
  security_enabled = true
}

resource "azuread_group_member" "administrators" {
  for_each         = local.administrator_object_ids
  group_object_id  = azuread_group_without_members.administrators.object_id
  member_object_id = each.value
}

resource "github_repository" "repo" {
  name = local.identifier

  allow_auto_merge    = true
  allow_update_branch = true

  auto_init = true
}

resource "github_branch" "main" {
  repository = github_repository.repo.name
  branch     = "main"
}

resource "github_branch_default" "default" {
  repository = github_repository.repo.name
  branch     = github_branch.main.branch
}

module "environment" {
  for_each                       = var.environments
  source                         = "../environment"
  administrators_group_object_id = azuread_group_without_members.administrators.object_id
  domain                         = var.domain
  name                           = var.name
  environment_name               = each.key
  users                          = each.value.users
  github_repository = {
    organization = split("/", github_repository.repo.full_name)[0]
    name         = split("/", github_repository.repo.full_name)[1]
  }
  terraform_storage_account_name = "${var.terraform_storage_account_name}${each.key}"
}
