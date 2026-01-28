# Key Vault Module v.1.0.0

This module creates Azure Key Vault and manages secrets.

## Usage

```hcl
module "key_vault" {
  source = "../../modules/key_vault/v.1.0.0"

  resource_group_name       = "rg-example"
  location                  = "eastus"
  suffix                    = "abc123"
  tenant_id                 = "00000000-0000-0000-0000-000000000000"
  object_id                 = "00000000-0000-0000-0000-000000000000"
  app_service_principal_id  = "00000000-0000-0000-0000-000000000000"
  sql_connection_string     = "Server=..."
  
  tags = {
    Environment = "Development"
  }
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| resource_group_name | Name of the resource group | string | Yes |
| location | Azure region | string | Yes |
| suffix | Unique suffix | string | Yes |
| tenant_id | Azure AD tenant ID | string | Yes |
| object_id | Current user object ID | string | Yes |
| app_service_principal_id | App Service managed identity | string | Yes |
| sql_connection_string | SQL connection string | string | Yes |
| tags | Resource tags | map(string) | Yes |

## Outputs

| Name | Description |
|------|-------------|
| key_vault_id | Key Vault resource ID |
| sql_connection_secret_id | SQL connection secret ID |

## Version History

- **v.1.0.0**: Initial release
