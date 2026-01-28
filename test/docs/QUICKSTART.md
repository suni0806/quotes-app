# Quick Start Guide

Get the application running in Azure in under 20 minutes!

## Prerequisites Check

```powershell
# Check Azure CLI
az --version

# Check Terraform
terraform --version

# Check Node.js
node --version
```

If any are missing, install them from:
- Azure CLI: https://aka.ms/installazurecli
- Terraform: https://www.terraform.io/downloads
- Node.js: https://nodejs.org/

## Step 1: Login to Azure (2 minutes)

```powershell
# Login
az login

# Select subscription
az account list --output table
az account set --subscription "YOUR-SUBSCRIPTION-NAME"
```

## Step 2: Configure Terraform (1 minute)

```powershell
cd terraform
copy terraform.tfvars.example terraform.tfvars
notepad terraform.tfvars
```

Edit these values:
```hcl
environment     = "prod"
location        = "eastus2"        # Choose your region
admin_username  = "sqladmin"
admin_password  = "YourStr0ngP@ssw0rd!"  # Change this!
```

**Important**: Use a strong password (12+ chars, mixed case, numbers, symbols)

## Step 3: Deploy Infrastructure (10 minutes)

```powershell
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Deploy (type 'yes' when prompted)
terraform apply
```

☕ Coffee break while Terraform creates ~15 Azure resources...

## Step 4: Deploy Application (3 minutes)

```powershell
# Run automated deployment script
cd ..
.\deploy.ps1
```

Or manually:

```powershell
# Get resource names
cd terraform
$rg = terraform output -raw resource_group_name
$app = terraform output -raw app_service_name

# Deploy app
cd ..\app
npm install --production
cd ..
Compress-Archive -Path "app\*" -DestinationPath "app.zip" -Force
az webapp deployment source config-zip --resource-group $rg --name $app --src app.zip
```

## Step 5: Seed Database (2 minutes)

```powershell
# Get connection string
cd terraform
az keyvault secret show `
  --vault-name (terraform output -raw key_vault_name) `
  --name sql-connection-string `
  --query value -o tsv

# Seed database
cd ..\scripts
npm install
copy .env.example .env
notepad .env  # Paste connection string
node seed-database.js
```

## Step 6: Test Application (1 minute)

```powershell
# Get URL
cd ..\terraform
terraform output app_service_url
```

Open the URL in your browser and click "Get New Quote"!

## Verification Checklist

✅ Application loads in browser
✅ Quote displays when clicking button
✅ Different quotes appear on each click
✅ Statistics show correct count
✅ HTTPS is enforced (padlock in browser)

## Common Issues

### "No quotes found"
**Solution**: Database not seeded. Run Step 5 again.

### "Cannot connect to database"
**Solution**: Wait 2-3 minutes for VNet integration to complete, then restart app:
```powershell
az webapp restart --resource-group <rg-name> --name <app-name>
```

### "Terraform apply failed"
**Solution**: Check region supports zone redundancy. Try: eastus2, westus2, or westeurope.

## Clean Up (when done testing)

```powershell
cd terraform
terraform destroy  # Type 'yes' when prompted
```

⚠️ This deletes all resources and data!

## Cost Estimate

**Production config**: ~$600/month
**Running for 1 hour**: ~$0.83

## Next Steps

1. ✅ Read [README.md](README.md) for detailed documentation
2. ✅ Review [ARCHITECTURE.md](ARCHITECTURE.md) for system design
3. ✅ Check [SECURITY.md](SECURITY.md) for security details
4. ✅ See [DEPLOYMENT.md](DEPLOYMENT.md) for advanced deployment

## Getting Help

- Check [DEPLOYMENT.md](DEPLOYMENT.md) troubleshooting section
- Review Application Insights logs in Azure Portal
- Verify all prerequisites are installed correctly

## Success! 🎉

Your highly available, secure, Azure-based random quotes application is now live!

**Application URL**: [From terraform output]
**Resource Group**: [From terraform output]
**Region**: [Your chosen region]

Enjoy your quotes! ✨
