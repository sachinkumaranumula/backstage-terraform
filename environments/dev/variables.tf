variable "region" {
  default = "eastus"
}

variable "subscription_purpose" {
  default = "sandbox"
}

variable "workload_name" {
  default = "IDP"
}

variable "application_name" {
  default = "backstage"
}

variable "environment" {
  default = "dev"
}

variable "backstage_github_repository" {
  default = "backstage"
}

# Dump the below in KeyVault or repo secrets
variable "auth_github_clientid" {}

variable "auth_github_client_secret" {}

variable "github_integration_personal_token" {}

variable "github_webhook_secret" {}

variable "custom_domain" {
  default = "backstagedev.azurewebsites.net"
}

variable "websites_port" {
  default = 7007
}
