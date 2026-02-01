# Azure Random Quotes Application

A highly available, secure web application that displays random quotes from an Azure SQL Database. Built with security-first principles treating all data as critical PII.

## Architecture Overview

This solution implements:
- **Azure App Service** with zone redundancy for high availability
- **Azure SQL Database** with zone redundancy and encryption
- **Private Endpoint** for secure database connectivity
- **Azure Key Vault** for secrets management
- **Virtual Network** with private subnets for isolation
- **Application Insights** for monitoring
- **TLS/SSL encryption** for all communications

## Security Features (PII Protection)

1. **Network Isolation**: Database accessible only via Private Endpoint
2. **Encryption**: 
   - Data encrypted at rest (Transparent Data Encryption)
   - Data encrypted in transit (TLS 1.2+)
3. **Secrets Management**: All credentials stored in Azure Key Vault
4. **No Public Database Access**: SQL Database not exposed to internet
5. **Managed Identities**: App Service uses managed identity for Key Vault access
6. **Audit Logging**: Azure SQL auditing enabled

## High Availability Features

1. **Zone Redundancy**: Both App Service and SQL Database use availability zones
2. **Multiple App Service Instances**: Auto-scaling capability
3. **Azure SQL SLA**: 99.995% uptime with zone redundancy
4. **Geo-replication Ready**: Infrastructure supports failover regions

## Prerequisites

- Azure subscription
- Terraform >= 1.0
- Azure CLI
- Node.js >= 18.x (for local development)

## Deployment Instructions

### Step 1: Setup Azure CLI

```bash
az login
az account set --subscription "<your-subscription-id>"
```

### Step 2: Configure Terraform Variables

Create a `terraform.tfvars` file in the `infrastructure/` directory:

```hcl
environment     = "prod"
location        = "eastus2"  # Choose a region that supports availability zones
admin_username  = "sqladmin"
admin_password  = "<strong-password>"  # Use a strong password
```

### Step 3: Deploy Infrastructure

```bash
cd infrastructure
terraform init
terraform plan
terraform apply
```

This will provision:
- Resource Group
- Virtual Network with subnets
- Azure SQL Server with Private Endpoint
- Azure SQL Database (zone redundant)
- App Service Plan (Premium with zone redundancy)
- App Service with VNet integration
- Key Vault with secrets
- Application Insights

### Step 4: Seed Database

After infrastructure is deployed, seed the database with quotes:

```bash
# Get connection details from Terraform output
terraform output

# Run seed script (from project root)
cd ../application/scripts
node seed-database.js
```

### Step 5: Deploy Application

```bash
cd ../application
zip -r ../app.zip .
az webapp deployment source config-zip \
  --resource-group <resource-group-name> \
  --name <app-service-name> \
  --src ../app.zip
```

### Step 6: Verify Deployment

Visit the App Service URL (from Terraform output) to see the random quotes application.

## Local Development

1. Install dependencies:
```bash
cd application
npm install
```

2. Create `.env` file with connection string:
```
DATABASE_CONNECTION_STRING=<your-connection-string>
PORT=3000
```

3. Run locally:
```bash
npm start
```

## AI Tool Usage

**GitHub Copilot** was used throughout development for:
- Terraform resource configurations and best practices
- Node.js/Express application boilerplate
- SQL query optimization
- Security configuration recommendations
- Documentation generation

## Project Structure

```
.
├── infrastructure/         # Infrastructure as Code
│   ├── main.tf            # Main Terraform configuration
│   ├── variables.tf       # Input variables
│   ├── outputs.tf         # Output values
│   ├── deploy.ps1         # Deployment script (PowerShell)
│   ├── deploy.sh          # Deployment script (Bash)
│   └── terraform.tfvars.example
├── application/           # Web application
│   ├── server.js          # Express server
│   ├── package.json       # Node.js dependencies
│   ├── public/            # Static assets
│   │   └── index.html     # Frontend
│   └── scripts/           # Database utilities
│       └── seed-database.js
└── README.md             # This file
```

## Monitoring

Access Application Insights from Azure Portal to monitor:
- Application performance
- Request rates and response times
- Failure rates
- Custom telemetry

## Cost Optimization

Current configuration prioritizes availability and security. To optimize costs:
- Use Basic/Standard tier for non-production
- Reduce SQL Database DTUs
- Scale down App Service plan
- Disable zone redundancy for dev/test

## Compliance

This architecture supports:
- GDPR compliance
- HIPAA compliance (with additional BAA)
- SOC 2 compliance
- Data residency requirements

## Troubleshooting

### Cannot connect to database
- Verify App Service VNet integration is active
- Check Private Endpoint DNS resolution
- Verify SQL firewall rules

### Quotes not displaying
- Check Application Insights logs
- Verify database has been seeded
- Test database connectivity from App Service console

## License

MIT

## Author

Created as part of Azure architecture challenge demonstration.
