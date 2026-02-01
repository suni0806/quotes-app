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
quotes-app/
├── application/
│   ├── server.js
│   ├── package.json
│   ├── public/
│   │   └── index.html
│   └── scripts/
│       ├── seed-database.js
│       └── package.json
├── infrastructure/
│   ├── modules/
│   │   ├── app_service/v.1.0.0/
│   │   ├── sql_database/v.1.0.0/
│   │   ├── networking/v.1.0.0/
│   │   ├── key_vault/v.1.0.0/
│   │   ├── storage/v.1.0.0/
│   │   └── monitoring/v.1.0.0/
│   ├── platform/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── backend.tf
│   │   └── environments/
│   │       ├── dev/
│   │       │   ├── backend.tfvars
│   │       │   └── variables.tfvars
│   │       └── production/
│   │           ├── backend.tfvars
│   │           └── variables.tfvars
│   ├── pipeline/
│   │   └── iac_cicd.yml
│   └── iac_deployment_templates/
│       ├── iac-build-template.yml
│       ├── iac-deploy-template.yml
│       ├── iac-validate-template.yml
│       └── iac-backend-storage-template.yml
├── app_deployment_templates/
│   ├── build-app-service.yml
│   └── deploy-app-service.yml
└── workflows/
    └── deploy-app.yml
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