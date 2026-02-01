# GitHub Actions Deployment Setup Guide

## Prerequisites

Before using the automated deployment workflow, you need to set up the following:

## 1. Azure Service Principal

Create a service principal for GitHub Actions to authenticate with Azure:

```bash
# Login to Azure
az login

# Create service principal
az ad sp create-for-rbac \
  --name "github-actions-random-quotes" \
  --role contributor \
  --scopes /subscriptions/{subscription-id} \
  --sdk-auth
```

This will output JSON like:
```json
{
  "clientId": "...",
  "clientSecret": "...",
  "subscriptionId": "...",
  "tenantId": "...",
  "..."
}
```

## 2. GitHub Secrets

Add the following secrets to your GitHub repository:

### Navigate to: Repository → Settings → Secrets and variables → Actions

#### Required Secrets:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `AZURE_CREDENTIALS` | Full JSON output from service principal creation | Azure authentication |
| `SQL_ADMIN_USERNAME` | `sqladmin` | SQL Server admin username |
| `SQL_ADMIN_PASSWORD` | Strong password | SQL Server admin password |
| `TF_STATE_RESOURCE_GROUP` | Resource group name | For Terraform state (optional) |
| `TF_STATE_STORAGE_ACCOUNT` | Storage account name | For Terraform state (optional) |
| `TF_STATE_CONTAINER` | Container name | For Terraform state (optional) |

### How to Add Secrets:

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret with the name and value from the table above

## 3. Terraform Remote State (Optional but Recommended)

For team collaboration, store Terraform state remotely:

```bash
# Create resource group
az group create \
  --name terraform-state-rg \
  --location eastus2

# Create storage account
az storage account create \
  --name tfstate$RANDOM \
  --resource-group terraform-state-rg \
  --location eastus2 \
  --sku Standard_LRS \
  --encryption-services blob

# Create container
az storage container create \
  --name tfstate \
  --account-name <storage-account-name>
```

Then add these to GitHub secrets:
- `TF_STATE_RESOURCE_GROUP`: `terraform-state-rg`
- `TF_STATE_STORAGE_ACCOUNT`: Your storage account name
- `TF_STATE_CONTAINER`: `tfstate`

## 4. GitHub Environments (For Approvals)

Set up environments for deployment approvals:

1. Go to **Settings** → **Environments**
2. Create environment: `production`
3. Add required reviewers (optional)
4. Add deployment protection rules

For database seeding:
- Create environment: `production-database`
- Require manual approval before seeding

## Workflow Features

### Automatic Triggers

The workflow runs automatically on:
- **Push to `main` branch**: Full deployment
- **Push to `develop` branch**: Full deployment to dev environment
- **Pull Requests to `main`**: Validation only (no deployment)
- **Manual trigger**: Via GitHub Actions UI (workflow_dispatch)

### Jobs

1. **validate-infrastructure**
   - Checks Terraform formatting
   - Validates Terraform configuration
   - Runs on all triggers

2. **build-application**
   - Installs Node.js dependencies
   - Runs tests (if configured)
   - Creates deployment package
   - Uploads artifact

3. **deploy-infrastructure**
   - Deploys Azure resources with Terraform
   - Outputs resource information
   - Only runs on push to main/develop

4. **deploy-application**
   - Deploys application to App Service
   - Uses deployment artifact
   - Runs health check

5. **seed-database**
   - Seeds database with quotes
   - Only runs on manual trigger
   - Requires approval

6. **smoke-tests**
   - Tests homepage
   - Tests API endpoints
   - Validates deployment

7. **notify**
   - Reports deployment status
   - Shows application URL

## Manual Deployment

To manually trigger a deployment with database seeding:

1. Go to **Actions** tab in GitHub
2. Select **Deploy Azure Random Quotes Application**
3. Click **Run workflow**
4. Select branch (usually `main`)
5. Click **Run workflow**

This will include the database seeding job.

## Viewing Deployment Status

1. Go to **Actions** tab
2. Click on the latest workflow run
3. View each job's progress and logs
4. Check deployment URL in the output

## Terraform Backend Configuration

If using remote state, add this to `infrastructure/main.tf`:

```hcl
terraform {
  backend "azurerm" {
    # Values provided via GitHub secrets during CI/CD
  }
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}
```

## Troubleshooting

### "Azure login failed"
- Check `AZURE_CREDENTIALS` secret is correctly formatted
- Verify service principal has contributor access
- Ensure subscription ID is correct

### "Terraform init failed"
- Verify remote state secrets are correct
- Check storage account exists and is accessible
- Ensure service principal has access to storage account

### "Health check failed"
- App Service may need more time to start
- Check App Service logs in Azure Portal
- Verify application configuration

### "Database seeding failed"
- Check connection string is correct
- Verify VNet integration is working
- Ensure Private Endpoint DNS resolution is complete

## Security Best Practices

✅ Never commit secrets to Git
✅ Use environment protection rules for production
✅ Require reviews before database operations
✅ Rotate service principal credentials regularly
✅ Use separate service principals for different environments
✅ Enable audit logging for GitHub Actions

## Cost Considerations

Each workflow run:
- Uses GitHub Actions minutes (2,000 free/month on free tier)
- Deploys Azure resources (billed by Azure)
- Consider using manual triggers for testing
- Use separate environments to control costs

## Next Steps

1. ✅ Set up secrets in GitHub
2. ✅ Configure Azure service principal
3. ✅ Create Terraform remote state (optional)
4. ✅ Push code to trigger first deployment
5. ✅ Monitor deployment in Actions tab
6. ✅ Run manual workflow to seed database

## Additional Workflows

You can create additional workflow files for:
- **Pull Request validation** (`.github/workflows/pr-check.yml`)
- **Scheduled backups** (`.github/workflows/backup.yml`)
- **Security scanning** (`.github/workflows/security.yml`)
- **Cost monitoring** (`.github/workflows/cost-check.yml`)

See GitHub Actions documentation for more examples.
