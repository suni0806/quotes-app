# App Service Module v.1.0.0

This module creates Azure App Service resources including:
- App Service Plan with zone redundancy
- Linux Web App with managed identity
- Auto-scaling configuration

## Usage

```hcl
module "app_service" {
  source = "../../modules/app_service/v.1.0.0"

  resource_group_name            = "rg-example"
  location                       = "eastus"
  environment                    = "dev"
  suffix                         = "abc123"
  app_insights_connection_string = "InstrumentationKey=..."
  sql_connection_secret_id       = "https://kv.../secrets/sql-connection"
  app_service_subnet_id          = "/subscriptions/.../subnets/app-subnet"
  
  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| resource_group_name | Name of the resource group | string | Yes |
| location | Azure region | string | Yes |
| environment | Environment name (dev/staging/prod) | string | Yes |
| suffix | Unique suffix for resource names | string | Yes |
| app_insights_connection_string | Application Insights connection string | string | Yes |
| sql_connection_secret_id | Key Vault secret ID for SQL connection | string | Yes |
| app_service_subnet_id | Subnet ID for VNet integration | string | Yes |
| tags | Resource tags | map(string) | Yes |

## Outputs

| Name | Description |
|------|-------------|
| app_service_name | Name of the App Service |
| app_service_hostname | Default hostname of the App Service |
| app_service_principal_id | Managed identity principal ID |

## Features

- **Zone Redundancy**: P1v2 SKU with zone balancing
- **Managed Identity**: System-assigned identity for Key Vault access
- **Auto-scaling**: CPU-based scaling (2-5 instances)
- **Security**: HTTPS only, TLS 1.2+, health checks enabled
- **VNet Integration**: Private networking support

## Version History

- **v.1.0.0**: Initial release
