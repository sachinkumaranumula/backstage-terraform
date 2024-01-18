output "backstage_app" {
  description = "Details of provisioned Backstage app"
  value = {
    details = module.backstage.app_service
  }
}
