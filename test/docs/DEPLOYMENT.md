# Deployment Guide

## Prerequisites

Before deploying this application, ensure you have:

### Required Software

1. **Azure CLI** (version 2.40.0 or later)
   ```bash
   az --version
   ```
   Install: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

2. **Terraform** (version 1.0 or later)
   ```bash
   terraform --version
   ```
   Install: https://www.terraform.io/downloads.html

3. **Node.js** (version 18 or later)
   ```bash
   node --version
   ```
   Install: https://nodejs.org/

### Azure Requirements

1. **Azure Subscription** with sufficient permissions to create:
   - Resource Groups
   - App Services
   - SQL Databases
   - Virtual Networks
   - Key Vaults
   - Storage Accounts

2. **Subscription Limits**
   - Ensure you have quota for Premium App Service Plans
   - Verify SQL Database quota for Premium tier

## Step-by-Step Deployment

### Step 1: Clone and Prepare

```bash
# Navigate to project directory
cd test

# Verify structure
ls -la
```

### Step 2: Azure Login

```bash
# Login to Azure
az login

# Set the correct subscription
az account list --output table
az account set --subscription "<your-subscription-id>"

# Verify
az account show
```

### Step 3: Configure Terraform

```bash
# Navigate to terraform directory
cd terraform

# Copy example file
cp terraform.tfvars.example terraform.tfvars

# Edit the file
# Windows: notepad terraform.tfvars
# Linux/Mac: nano terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
environment     = "prod"
location        = "eastus2"  # Choose your region
admin_username  = "sqladmin"
admin_password  = "YourStrongP@ssw0rd123!"  # Use a strong password
```

**Important**: Choose a region that supports:
- Availability Zones
- Premium v2 App Service Plans
- Zone-redundant SQL Database

Recommended regions: eastus2, westus2, northeurope, westeurope

### Step 4: Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply (will prompt for confirmation)
terraform apply
```

This process takes approximately 5-10 minutes and creates:
- Resource Group
- Virtual Network (VNet)
- Azure SQL Server with Private Endpoint
- Azure SQL Database (zone-redundant)
- App Service Plan (zone-redundant)
- App Service with VNet integration
- Key Vault with secrets
- Application Insights
- Storage Account for auditing

### Step 5: Save Terraform Outputs

```bash
# Save important values
terraform output > ../deployment-info.txt

# Or individually
terraform output app_service_url
terraform output resource_group_name
terraform output sql_server_fqdn
```

### Step 6: Deploy Application Code

#### Option A: Using Automated Script (Recommended)

**Windows:**
```powershell
cd ..
.\deploy.ps1
```

**Linux/Mac:**
```bash
cd ..
chmod +x deploy.sh
./deploy.sh
```

#### Option B: Manual Deployment

```bash
# Navigate to app directory
cd ../app

# Install dependencies
npm install --production

# Create deployment package
cd ..
zip -r app.zip app/ -x "app/node_modules/*" "app/.env*"

# Deploy to App Service
az webapp deployment source config-zip \
  --resource-group <resource-group-name> \
  --name <app-service-name> \
  --src app.zip
```

### Step 7: Seed the Database

The database needs to be populated with quotes before the application will work.

```bash
# Navigate to scripts directory
cd scripts

# Install dependencies
npm install

# Create .env file
cp .env.example .env
```

Get the connection string from Key Vault:

```bash
# Get Key Vault name
cd ../terraform
terraform output key_vault_name

# Retrieve connection string
az keyvault secret show \
  --vault-name <key-vault-name> \
  --name sql-connection-string \
  --query value -o tsv
```

Edit `scripts/.env` and add the connection string:

```bash
DATABASE_CONNECTION_STRING=<connection-string-from-above>
NODE_ENV=production
```

Run the seed script:

```bash
# From scripts directory
node seed-database.js
```

The script will:
- Create the Quotes table if it doesn't exist
- Insert 50 famous quotes
- Display sample quotes and statistics

### Step 8: Verify Deployment

#### Test the Application

1. Get the application URL:
   ```bash
   cd ../terraform
   terraform output app_service_url
   ```

2. Open the URL in a browser

3. Click "Get New Quote" - you should see a random quote

#### Check Application Logs

```bash
# Stream logs
az webapp log tail \
  --resource-group <resource-group-name> \
  --name <app-service-name>
```

#### Verify Database Connection

```bash
# Check App Service configuration
az webapp config appsettings list \
  --resource-group <resource-group-name> \
  --name <app-service-name> \
  --output table
```

#### Monitor in Application Insights

1. Go to Azure Portal: https://portal.azure.com
2. Navigate to your Resource Group
3. Open Application Insights
4. View Live Metrics and Logs

## Troubleshooting

### Issue: Application shows "No quotes found"

**Solution**: Database hasn't been seeded
```bash
cd scripts
node seed-database.js
```

### Issue: Cannot connect to database

**Solutions**:
1. Verify VNet integration is active
2. Check Private Endpoint status
3. Verify connection string in Key Vault
4. Check App Service logs for specific error

```bash
# Check VNet integration
az webapp vnet-integration list \
  --resource-group <resource-group-name> \
  --name <app-service-name>
```

### Issue: Terraform apply fails

**Solutions**:
1. Check subscription limits/quotas
2. Verify region supports required features
3. Ensure unique naming (resource names must be unique)
4. Check Azure service health

### Issue: Application won't start

**Solutions**:
1. Verify Node.js version in App Service
2. Check environment variables
3. Review application logs
4. Restart the App Service

```bash
az webapp restart \
  --resource-group <resource-group-name> \
  --name <app-service-name>
```

## Post-Deployment Configuration

### Enable Monitoring Alerts

```bash
# Create CPU alert
az monitor metrics alert create \
  --name "High CPU Alert" \
  --resource-group <resource-group-name> \
  --scopes <app-service-plan-id> \
  --condition "avg Percentage CPU > 80" \
  --window-size 5m \
  --evaluation-frequency 1m
```

### Configure Custom Domain (Optional)

```bash
# Add custom domain
az webapp config hostname add \
  --resource-group <resource-group-name> \
  --webapp-name <app-service-name> \
  --hostname <your-domain.com>

# Enable SSL
az webapp config ssl bind \
  --resource-group <resource-group-name> \
  --name <app-service-name> \
  --certificate-thumbprint <thumbprint> \
  --ssl-type SNI
```

### Enable Geo-Replication (Optional)

```bash
# Create secondary database
az sql db replica create \
  --resource-group <resource-group-name> \
  --server <sql-server-name> \
  --name <database-name> \
  --partner-resource-group <secondary-rg> \
  --partner-server <secondary-server> \
  --secondary-type Geo
```

## Cleanup/Teardown

To remove all resources:

**Windows:**
```powershell
.\cleanup.ps1
```

**Linux/Mac:**
```bash
chmod +x cleanup.sh
./cleanup.sh
```

**Or manually:**
```bash
cd terraform
terraform destroy
```

**Note**: Some resources like Key Vault have soft-delete enabled and may need to be purged manually:

```bash
az keyvault purge --name <key-vault-name>
```

## Cost Management

### Monitor Costs

```bash
# View cost analysis
az consumption usage list \
  --start-date 2024-01-01 \
  --end-date 2024-01-31

# Set budget alert
az consumption budget create \
  --budget-name "monthly-budget" \
  --amount 100 \
  --category Cost \
  --time-grain Monthly
```

### Optimization Tips

1. **Development**: Use Basic/Standard tiers
2. **Production**: Use Premium with auto-scaling
3. **Off-hours**: Scale down during low usage
4. **Reserved Instances**: Commit for 1-3 years for savings

## Next Steps

1. ✅ Configure monitoring alerts
2. ✅ Set up automated backups validation
3. ✅ Implement CI/CD pipeline
4. ✅ Add custom domain and SSL
5. ✅ Configure Azure Front Door (optional)
6. ✅ Enable Advanced Threat Protection
7. ✅ Set up disaster recovery plan
8. ✅ Document runbooks for operations team

## Support

For issues or questions:
1. Check troubleshooting section above
2. Review Azure service health
3. Check Application Insights logs
4. Review Terraform documentation
5. Contact Azure support
