# Monitoring Module v.1.0.0

This module creates monitoring resources including:
- Log Analytics Workspace
- Application Insights

## Usage

```hcl
module "monitoring" {
  source = "../../modules/monitoring/v.1.0.0"

  resource_group_name = "rg-example"
  location            = "eastus"
  environment         = "dev"
  
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
| tags | Resource tags | map(string) | Yes |

## Outputs

| Name | Description |
|------|-------------|
| app_insights_connection_string | Application Insights connection string |
| app_insights_instrumentation_key | Application Insights key |

## Version History

- **v.1.0.0**: Initial release
