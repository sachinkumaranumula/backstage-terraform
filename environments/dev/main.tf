# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.65.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.40.0"
    }
    github = {
      source  = "integrations/github"
      version = "5.31.0"
    }
  }
}

# Configure the Microsoft Azure Provider
# see https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
provider "azurerm" {
  features {}
}

# Azure AD has been split from RM provider
# see https://registry.terraform.io/providers/hashicorp/azuread/latest/docs
provider "azuread" {
  # Configuration options
}

provider "github" {
  # Configuration options 
  # set env: GITHUB_TOKEN or if using GitHub App use app_auth{}
  # set env: GITHUB_ORGANIZATION 
}

module "acr" {
  source = "../../modules/shared/containerregistry"

  workload_name               = var.workload_name
  application_name            = var.application_name
  environment                 = var.environment
  subscription_purpose        = var.subscription_purpose
  region                      = var.region
  backstage_github_repository = var.backstage_github_repository
}

module "backstage" {
  source = "../../modules/backstage"

  region                            = var.region
  subscription_purpose              = var.subscription_purpose
  application_name                  = var.application_name
  environment                       = var.environment
  custom_domain                     = var.custom_domain
  websites_port                     = var.websites_port
  acr_object_id                     = module.acr.container_registry.object_id
  auth_github_clientid              = var.auth_github_clientid
  auth_github_client_secret         = var.auth_github_client_secret
  github_integration_personal_token = var.github_integration_personal_token
  github_webhook_secret             = var.github_webhook_secret
  backstage_github_repository       = var.backstage_github_repository
}


