# Storage Module v.1.0.0

This module creates Azure Storage Account for audit logs.

## Usage

```hcl
module "storage" {
  source = "../../modules/storage/v.1.0.0"

  resource_group_name = "rg-example"
  location            = "eastus"
  suffix              = "abc123"
  
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
| tags | Resource tags | map(string) | Yes |

## Outputs

| Name | Description |
|------|-------------|
| storage_account_id | Storage account ID |
| primary_blob_endpoint | Blob endpoint |
| primary_access_key | Storage access key |

## Version History

- **v.1.0.0**: Initial release
