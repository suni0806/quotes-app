# Azure Random Quotes Application

A highly available web application displaying random quotes from Azure SQL Database. Built with Terraform for a Senior DevOps Engineer technical challenge.

## Overview

This project demonstrates production ready Azure infrastructure with security first design, treating all data as critical PII. The application uses zone redundant services, private networking, and comprehensive monitoring.

**Tech Stack**: Node.js, Azure SQL Database, Azure App Service, Terraform
```

## Key Features

- ✅ **Security**: Private Endpoints, TDE encryption, Managed Identity, Key Vault
- ✅ **High Availability**: Zone redundancy, auto-scaling (2-5 instances), 99.995% SLA
- ✅ **Infrastructure as Code**: Modular Terraform with 6 reusable modules
- ✅ **Monitoring**: Application Insights, health checks, audit logging

## Project Structure

```
test/
├── quotes-app/                                    # Main application directory
│   ├── application/                              # Node.js web application
│   │   ├── server.js                            # Express API server (quote retrieval)
│   │   ├── package.json                         # Node.js dependencies
│   │   ├── public/
│   │   │   └── index.html                       # Frontend UI for quote display
│   │   └── scripts/
│   │       ├── seed-database.js                 # Database seeding (50 quotes)
│   │       └── package.json                     # Seed script dependencies
│   │
│   ├── infrastructure/                           # Terraform Infrastructure as Code
│   │   ├── modules/                             # Reusable Terraform modules
│   │   │   ├── app_service/v.1.0.0/            # App Service Plan + Web App + Autoscaling
│   │   │   ├── sql_database/v.1.0.0/           # SQL Server + Database + Private Endpoint
│   │   │   ├── networking/v.1.0.0/             # VNet + Subnets + Private DNS zones
│   │   │   ├── key_vault/v.1.0.0/              # Key Vault for secrets management
│   │   │   ├── storage/v.1.0.0/                # Storage Account for SQL audit logs
│   │   │   └── monitoring/v.1.0.0/             # Application Insights + Log Analytics
│   │   │
│   │   ├── platform/                            # Platform deployment configuration
│   │   │   ├── main.tf                          # Root module orchestration
│   │   │   ├── variables.tf                     # Variable definitions
│   │   │   ├── outputs.tf                       # Output values
│   │   │   ├── backend.tf                       # Remote state configuration
│   │   │   └── environments/                    # Environment-specific configs
│   │   │       ├── dev/                         # Development environment
│   │   │       │   ├── backend.tfvars          # Dev backend settings
│   │   │       │   └── variables.tfvars        # Dev variable values
│   │   │       └── production/                  # Production environment
│   │   │           ├── backend.tfvars          # Prod backend settings
│   │   │           └── variables.tfvars        # Prod variable values
│   │   │
│   │   ├── pipeline/                            # CI/CD automation
│   │   │   ├── iac_cicd.yml                    # Azure Pipelines - IaC deployment
│   │   │
│   │   └── iac_deployment_templates/            # Pipeline templates
│   │       ├── iac-build-template.yml          # Build template
│   │       ├── iac-deploy-template.yml         # Deploy template
│   │       ├── iac-validate-template.yml       # Validation template
│   │       └── iac-backend-storage-template.yml # Backend setup template
│   │
│   ├── app_deployment_templates/                # Application deployment pipelines
│   │   ├── build-app-service.yml               # App build pipeline
│   │   └── deploy-app-service.yml              # App deploy pipeline
│   │
│   └── workflows/                               # GitHub Actions (optional)
│       ├── deploy-app.yml                      # GitHub workflow for deployment
│       └── README.md                           # Workflow documentation
│
└── README.md                                    # This file
```

### Key Folder Purposes

| Path | Purpose |
|------|---------|
| `quotes-app/infrastructure/modules/` | Self-contained, versioned Terraform modules for each Azure service |
| `quotes-app/infrastructure/platform/` | Main Terraform orchestration combining all modules |
| `quotes-app/infrastructure/platform/environments/` | Environment-specific configurations (dev/prod) |
| `quotes-app/infrastructure/pipeline/` | Automation scripts for deployment and cleanup |
| `quotes-app/app_deployment_templates/` | Azure Pipelines YAML for application deployment |
| `quotes-app/application/` | Node.js Express application for serving quotes API and frontend |

## Architecture

```
Internet (HTTPS) → App Service (Zone Redundant) → VNet → Private Endpoint → Azure SQL (Encrypted)
```

## Requirements Compliance

| Requirement | Status |
|-------------|--------|
| Public web app connecting to Azure SQL | ✅ |
| Database seeded with quotes | ✅ |
| Random quote display | ✅ |
| Treat data as critical PII | ✅ |
| Highly available | ✅ |
| Azure + Terraform | ✅ |
| AI usage documented | ✅ |


## Author

**Sidharth Dinesan** - Technical Challenge for Degreed Senior DevOps Engineer (Azure)

Repository: [github.com/suni0806/test](https://github.com/suni0806/test)