# backstage-terraform
Sachin built this to provision backstage for demos and tear it down once done

## Standards Followed
### Azure Naming Conventions
- https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming

### Azure Terraform
- https://learn.microsoft.com/en-us/azure/developer/terraform/

### Google Best Practices
- https://cloud.google.com/docs/terraform/best-practices-for-terraform
  
### Azure RM Tf Structure Convention
- https://github.com/Azure/terraform-azurerm-caf-enterprise-scale#readme

## Steps
- Cloud Provisioning
  - For Azure
    - Set up a subscription
    - Set up a Contributor [Azure Custom Role](azure/id-iaac-dev-centralus-001.json)
      - az ad sp create-for-rbac --name="id-iaac-dev-centralus-001" --role="Contributor" --scopes="/subscriptions/<SUBSCRIPTION_ID>"
- Login to Cloud Provider
  - az login
  - az account set --subscription "<SUBSCRIPTION_ID>"
  - az account show (ensure you are pointing at right subscription)
- Setup Environment for Terraform
  - use `az_sp.sh` and create your own `local_az_sp.sh` filling out values to keys and then source `source ./scripts/local_az_sp.sh`
- Terraform Provision
  - `cd environments/dev`
  - `terraform init`
  - `terraform validate`
  - `terraform plan`
  - `terraform apply`
- Terraform Destroy
  - `terraform destroy`

## Post Setup
You should see output as below
```
Outputs:

backstage_app = {
  "details" = {
    "backstage_app" = "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/rg-backstage-sandbox-001/providers/Microsoft.Web/sites/backstagedev"
    "backstage_app_plan" = "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/rg-backstage-sandbox-001/providers/Microsoft.Web/serverfarms/backstagedev-plan"
    "backstage_rg" = "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/rg-backstage-sandbox-001"
  }
}
```

## TO BE DELETED
## Run
### Local with your Az
- az login
- az account set --subscription "<SUBSCRIPTION_ID>"
- If you want to customize for other actions, start from scratch like below and customize
  - az ad sp create-for-rbac --name="id-iaac-dev-centralus-001" --role="Contributor" --scopes="/subscriptions/<SUBSCRIPTION_ID>"
- use `az_sp.sh` and create your own `local_az_sp.sh` filling out values to keys and then source `./scripts/local_az_sp.sh`

### Use Managed Identity for CI/CD
- use `az_msi.sh` and create your own `local_az_msi.sh` filling out values to keys and then source `./scripts/local_az_msi.sh`