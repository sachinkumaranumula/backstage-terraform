# PROVIDER REQUIREMENTS
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}
# DO NOT ENLIST PROVIDER HERE

locals {
  appEnv = "${var.application_name}${var.environment}"
  default_rg_tags = {
    BusinessUnit       = "Engineering"
    Criticality        = "Medium"
    DataClassification = "Confidential"
    Env                = var.environment
    ApplicationName    = var.application_name
  }
}

# Backstage 
resource "azurerm_resource_group" "rg_backstage" {
  name     = "rg-backstage-${var.subscription_purpose}-001"
  location = var.region
  tags     = local.default_rg_tags
}

resource "azurerm_service_plan" "backstage_app_service_plan" {
  name                = "${local.appEnv}-plan"
  resource_group_name = azurerm_resource_group.rg_backstage.name
  location            = azurerm_resource_group.rg_backstage.location
  os_type             = "Linux"
  sku_name            = "S1"
}

data "azurerm_client_config" "current" {}

resource "azuread_application" "backstage_app" {
  display_name = "${local.appEnv}App"
  owners       = [data.azurerm_client_config.current.object_id]

  web {
    redirect_uris = [
      "https://${var.custom_domain}/api/auth/github/handler/frame"
    ]
  }
}

resource "azuread_service_principal" "backstage_app_service_principal" {
  application_id = azuread_application.backstage_app.application_id
  owners         = [data.azurerm_client_config.current.object_id]
}

resource "azuread_application_password" "backstage_app_password" {
  application_object_id = azuread_application.backstage_app.object_id
}

resource "azurerm_linux_web_app" "backstage_app" {
  name                = local.appEnv
  resource_group_name = azurerm_resource_group.rg_backstage.name
  location            = azurerm_service_plan.backstage_app_service_plan.location
  service_plan_id     = azurerm_service_plan.backstage_app_service_plan.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
  }

  logs {
    application_logs {
      file_system_level = "Verbose"
    }
    detailed_error_messages = true
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_USERNAME" = azuread_application.backstage_app.application_id
    "DOCKER_REGISTRY_SERVER_PASSWORD" = azuread_application_password.backstage_app_password.value
    # backstage app-config.yaml
    "CUSTOM_DOMAIN"                     = var.custom_domain
    "WEBSITES_PORT"                     = var.websites_port
    "AUTH_GITHUB_CLIENT_ID"             = var.auth_github_clientid
    "AUTH_GITHUB_CLIENT_SECRET"         = var.auth_github_client_secret
    "GITHUB_INTEGRATION_PERSONAL_TOKEN" = var.github_integration_personal_token
    "GITHUB_WEBHOOK_SECRET"             = var.github_webhook_secret
    #"APPINSIGHTS_INSTRUMENTATIONKEY"    = azurerm_application_insights.app_insights.instrumentation_key
  }
}

# Tearing down below takes a lot of time with terraform
# resource "azurerm_application_insights" "app_insights" {
#   name                = "${local.appEnv}Insights"
#   resource_group_name = azurerm_resource_group.rg_backstage.name
#   location            = azurerm_resource_group.rg_backstage.location
#   application_type    = "other"
# }

resource "azurerm_role_assignment" "backstage_app_acrpull_role_assignment" {
  scope                = var.acr_object_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.backstage_app.identity[0].principal_id
}

resource "azurerm_role_assignment" "backstage_app_service_principal_acrpull_role_assignment" {
  scope                = var.acr_object_id
  role_definition_name = "AcrPull"
  principal_id         = azuread_service_principal.backstage_app_service_principal.object_id
}

# Enabling Az login at GitHub for Azure App Service
resource "azurerm_role_assignment" "app_service_contributor_role_assignment" {
  scope                = azurerm_linux_web_app.backstage_app.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.backstage_app_service_principal.object_id
}

resource "github_actions_secret" "github_azure_subscription_id" {
  repository      = var.backstage_github_repository
  secret_name     = "AZURE_SUBSCRIPTION_ID"
  plaintext_value = data.azurerm_client_config.current.subscription_id
}

resource "github_actions_secret" "github_azure_tenant_id" {
  repository      = var.backstage_github_repository
  secret_name     = "AZURE_TENANT_ID"
  plaintext_value = data.azurerm_client_config.current.tenant_id
}

resource "github_actions_secret" "github_azure_client_id" {
  repository      = var.backstage_github_repository
  secret_name     = "AZURE_CLIENT_ID"
  plaintext_value = data.azurerm_client_config.current.client_id
}

resource "github_actions_secret" "azure_credentials" {
  repository  = var.backstage_github_repository
  secret_name = "AZURE_CREDENTIALS"
  plaintext_value = jsonencode({
    "clientId"       = azuread_service_principal.backstage_app_service_principal.application_id
    "clientSecret"   = azuread_application_password.backstage_app_password.value
    "subscriptionId" = data.azurerm_client_config.current.subscription_id
    "tenantId"       = data.azurerm_client_config.current.tenant_id
  })
}

resource "github_actions_secret" "app_name" {
  repository      = var.backstage_github_repository
  secret_name     = "BACKSTAGE_APP_NAME"
  plaintext_value = azurerm_linux_web_app.backstage_app.name
}
