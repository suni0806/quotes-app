# Networking Module v.1.0.0

This module creates networking resources including:
- Virtual Network
- Subnets with delegations
- Private DNS zones

## Usage

```hcl
module "networking" {
  source = "../../modules/networking/v.1.0.0"

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
| vnet_id | Virtual Network ID |
| app_service_subnet_id | App Service subnet ID |
| private_endpoint_subnet_id | Private endpoint subnet ID |
| private_dns_zone_id | Private DNS zone ID |

## Features

- **VNet**: 10.0.0.0/16 address space
- **App Service Subnet**: Delegated for App Service
- **Private Endpoint Subnet**: For private connectivity
- **Private DNS**: For SQL Database private link

## Version History

- **v.1.0.0**: Initial release
