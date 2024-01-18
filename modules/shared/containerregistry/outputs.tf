output "container_registry" {
  description = "ACR Login Server"
  value = {
    rg_id        = azurerm_resource_group.rg_acr.id
    object_id    = azurerm_container_registry.acr.id
    location     = azurerm_container_registry.acr.location
    login_server = azurerm_container_registry.acr.login_server
  }
}

