output "app_service" {
  description = "App Service for Backstage"
  value = {
    backstage_rg       = azurerm_resource_group.rg_backstage.id
    backstage_app_plan = azurerm_service_plan.backstage_app_service_plan.id
    backstage_app      = azurerm_linux_web_app.backstage_app.id
  }
}
