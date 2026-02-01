# SQL Database Module v.1.0.0

This module creates Azure SQL Database resources including:
- Azure SQL Server with private endpoint
- SQL Database with zone redundancy
- Auditing configuration

## Usage

```hcl
module "sql_database" {
  source = "../../modules/sql_database/v.1.0.0"

  resource_group_name         = "rg-example"
  location                    = "eastus"
  environment                 = "dev"
  suffix                      = "abc123"
  admin_username              = "sqladmin"
  admin_password              = "SecurePassword123!"
  private_endpoint_subnet_id  = "/subscriptions/.../subnets/pe-subnet"
  private_dns_zone_id         = "/subscriptions/.../privateDnsZones/..."
  tenant_id                   = "00000000-0000-0000-0000-000000000000"
  object_id                   = "00000000-0000-0000-0000-000000000000"
  audit_storage_endpoint      = "https://storage.blob.core.windows.net/"
  audit_storage_access_key    = "storage-key"
  
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
| environment | Environment name | string | Yes |
| suffix | Unique suffix | string | Yes |
| admin_username | SQL admin username | string | Yes |
| admin_password | SQL admin password | string | Yes |
| private_endpoint_subnet_id | Subnet for private endpoint | string | Yes |
| private_dns_zone_id | Private DNS zone ID | string | Yes |
| tenant_id | Azure AD tenant ID | string | Yes |
| object_id | Azure AD object ID | string | Yes |
| audit_storage_endpoint | Storage endpoint for auditing | string | Yes |
| audit_storage_access_key | Storage access key | string | Yes |
| tags | Resource tags | map(string) | Yes |

## Outputs

| Name | Description |
|------|-------------|
| sql_server_id | SQL Server resource ID |
| sql_server_fqdn | SQL Server FQDN |
| sql_database_name | Database name |

## Features

- **Zone Redundancy**: P1 SKU with zone redundancy
- **Private Endpoint**: No public network access
- **Encryption**: TDE enabled
- **Auditing**: 90-day retention
- **Backups**: Short and long-term retention

## Version History

- **v.1.0.0**: Initial release
