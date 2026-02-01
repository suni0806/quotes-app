# Azure Random Quotes Application

A highly available web application displaying random quotes from Azure SQL Database. Built with Terraform for a Senior DevOps Engineer technical challenge.

## Overview

This project demonstrates production-ready Azure infrastructure with security-first design, treating all data as critical PII. The application uses zone-redundant services, private networking, and comprehensive monitoring.

**Tech Stack**: Node.js, Azure SQL Database, Azure App Service, Terraform

## Quick Start

```bash
# Deploy infrastructure
cd quotes-app/infrastructure/platform
terraform init
terraform apply -var-file="environments/dev/variables.tfvars"

# Deploy application
cd ../../application
npm install
npm start
```

## Key Features

- ✅ **Security**: Private Endpoints, TDE encryption, Managed Identity, Key Vault
- ✅ **High Availability**: Zone redundancy, auto-scaling (2-5 instances), 99.995% SLA
- ✅ **Infrastructure as Code**: Modular Terraform with 6 reusable modules
- ✅ **Monitoring**: Application Insights, health checks, audit logging

## Architecture

```
Internet (HTTPS) → App Service (Zone Redundant) → VNet → Private Endpoint → Azure SQL (Encrypted)
```

## Documentation

- [PROJECT_SUMMARY.md](quotes-app/docs/PROJECT_SUMMARY.md) - Complete overview & AI usage disclosure
- [DEPLOYMENT.md](quotes-app/docs/DEPLOYMENT.md) - Step-by-step deployment guide
- [ARCHITECTURE.md](quotes-app/docs/ARCHITECTURE.md) - Technical architecture details
- [SECURITY.md](quotes-app/docs/SECURITY.md) - Security implementation

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

**AI Disclosure**: GitHub Copilot used extensively (60-80% across components). All code reviewed and tested. See [PROJECT_SUMMARY.md](quotes-app/docs/PROJECT_SUMMARY.md) for details.

## Author

**Sidharth Dinesan** - Technical Challenge for Degreed Senior DevOps Engineer (Azure)

Repository: [github.com/suni0806/test](https://github.com/suni0806/test)