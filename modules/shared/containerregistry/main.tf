# PROVIDER REQUIREMENTS
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">=2.40.0"
    }
    github = {
      source  = "integrations/github"
      version = ">=5.30.0"
    }
  }
}

locals {
  appEnv = "${var.application_name}${var.environment}"
  default_rg_tags = {
    BusinessUnit       = "Engineering"
    Criticality        = "Medium"
    DataClassification = "Confidential"
    Env                = var.environment
    WorkLoadName       = var.workload_name
  }
}

# Create ACR resource group
resource "azurerm_resource_group" "rg_acr" {
  name     = "rg-acr-${var.subscription_purpose}-001"
  location = var.region
  tags     = local.default_rg_tags
}

resource "azurerm_container_registry" "acr" {
  name                = "cr${local.appEnv}001"
  resource_group_name = azurerm_resource_group.rg_acr.name
  location            = azurerm_resource_group.rg_acr.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Backstage Deployer
data "azuread_client_config" "current" {}

resource "azuread_application" "backstage_cr_contributor" {
  display_name = "${local.appEnv}Deployer"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "backstage_cr_contributor_service_principal" {
  application_id               = azuread_application.backstage_cr_contributor.application_id
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azuread_application_password" "backstage_cr_contributor_password" {
  application_object_id = azuread_application.backstage_cr_contributor.object_id
}

resource "azurerm_role_assignment" "backstage_cr_contributor_role_assignment" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.backstage_cr_contributor_service_principal.object_id
}

# GIT Hub Secrets 
resource "github_actions_secret" "registry_login_server" {
  repository      = var.backstage_github_repository
  secret_name     = "REGISTRY_LOGIN_SERVER"
  plaintext_value = azurerm_container_registry.acr.login_server
}

resource "github_actions_secret" "registry_username" {
  repository      = var.backstage_github_repository
  secret_name     = "REGISTRY_USERNAME"
  plaintext_value = azuread_service_principal.backstage_cr_contributor_service_principal.application_id
}

resource "github_actions_secret" "registry_password" {
  repository      = var.backstage_github_repository
  secret_name     = "REGISTRY_PASSWORD"
  plaintext_value = azuread_application_password.backstage_cr_contributor_password.value
}
