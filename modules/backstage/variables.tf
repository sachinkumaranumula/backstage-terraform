variable "region" {
  type = string
}

variable "subscription_purpose" {
  type = string
}

variable "application_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "custom_domain" {
  description = "Domain for Backstage App Service"
  type        = string
}

variable "acr_object_id" {
  description = "Id of Azure Container Registry already provisioned"
  type        = string
}

variable "auth_github_clientid" {
  description = "GitHub OAuth App Client Id"
  type        = string
}

variable "auth_github_client_secret" {
  description = "GitHub OAuth Client Secret"
  type        = string
}

variable "github_integration_personal_token" {
  description = "GitHub Personal Access Token for reading and writing to GitHub repos on behalf of backstage"
  type        = string
}

variable "github_webhook_secret" {
  description = "GitHub Webhook secret for webhook that notifies a running backstage instance of changes to GitHub Org/Repos"
  type        = string
}

variable "backstage_github_repository" {
  description = "GitHub repo which has CD pipeline setup"
  type        = string
}

variable "websites_port" {
  description = "the port to which App Service would forward requests to from :80"
  type        = number
}
