# Infrastructure Platform

This directory contains the modularized Terraform infrastructure code for the Random Quotes application.

## 📁 Structure

```
platform/
├── backend.tf                    # Backend configuration
├── provider.tf                   # Provider configuration
├── main.tf                       # Main infrastructure resources
├── variables.tf                  # Variable definitions
├── subscription_variables.tf     # Subscription-level variables
├── outputs.tf                    # Output definitions
└── environments/                 # Environment-specific configurations
    ├── dev/
    │   ├── backend.tfvars       # Dev backend config
    │   └── variables.tfvars     # Dev variable values
    ├── staging/
    │   ├── backend.tfvars       # Staging backend config
    │   └── variables.tfvars     # Staging variable values
    └── production/
        ├── backend.tfvars       # Production backend config
        └── variables.tfvars     # Production variable values
```

## 🚀 Usage

### Initialize for Specific Environment

```bash
# Development
cd platform
terraform init -backend-config=environments/dev/backend.tfvars

# Staging
terraform init -backend-config=environments/staging/backend.tfvars

# Production
terraform init -backend-config=environments/production/backend.tfvars
```

### Plan Deployment

```bash
# Development
terraform plan -var-file=environments/dev/variables.tfvars

# Staging
terraform plan -var-file=environments/staging/variables.tfvars

# Production
terraform plan -var-file=environments/production/variables.tfvars
```

### Apply Infrastructure

```bash
# Development
terraform apply -var-file=environments/dev/variables.tfvars

# Staging
terraform apply -var-file=environments/staging/variables.tfvars

# Production
terraform apply -var-file=environments/production/variables.tfvars
```

## 🔐 Required Secrets

Set these as environment variables:

```bash
export TF_VAR_subscription_id="your-subscription-id"
export TF_VAR_tenant_id="your-tenant-id"
export TF_VAR_sql_admin_password="your-secure-password"
```

## 📋 Prerequisites

1. **Azure Storage Account** for remote state:
   ```bash
   # Create resource group
   az group create --name rg-quotes-terraform-state-dev --location eastus
   
   # Create storage account
   az storage account create \
     --name stquotesterraformdev \
     --resource-group rg-quotes-terraform-state-dev \
     --location eastus \
     --sku Standard_LRS
   
   # Create container
   az storage container create \
     --name tfstate \
     --account-name stquotesterraformdev
   ```

2. **Service Principal** with appropriate permissions

3. **Terraform** version >= 1.0

## 🌍 Environment Configuration

Each environment has its own configuration in `environments/{env}/`:

- **backend.tfvars**: Remote state storage configuration
- **variables.tfvars**: Environment-specific variable values

### Customization

Edit the `.tfvars` files to customize:
- Resource names
- SKUs and pricing tiers
- Tags
- Location/region
- Security settings

## 🔄 CI/CD Integration

Use with Azure DevOps or GitHub Actions:

```yaml
# Example workflow step
- name: Terraform Init
  run: terraform init -backend-config=environments/${{ env.ENVIRONMENT }}/backend.tfvars

- name: Terraform Apply
  run: terraform apply -var-file=environments/${{ env.ENVIRONMENT }}/variables.tfvars -auto-approve
```

## 📝 Best Practices

✅ **Never commit secrets** - Use environment variables or Key Vault
✅ **Use remote state** - Configured via backend.tfvars
✅ **Separate environments** - Each has its own state and config
✅ **Tag all resources** - For cost tracking and management
✅ **Review plans** - Always run `terraform plan` before apply
✅ **Version control** - Commit infrastructure changes

## 🆘 Common Commands

```bash
# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Show current state
terraform show

# List resources
terraform state list

# Destroy infrastructure (careful!)
terraform destroy -var-file=environments/dev/variables.tfvars
```

## 📚 Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
