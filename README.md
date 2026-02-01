# Azure Random Quotes Application

A highly available web application displaying random quotes from Azure SQL Database. Built with Terraform for a Senior DevOps Engineer technical challenge.

## Overview

This project demonstrates production-ready Azure infrastructure with security-first design, treating all data as critical PII. The application uses zone-redundant services, private networking, and comprehensive monitoring.

**Tech Stack**: Node.js, Azure SQL Database, Azure App Service, Terraform

## Key Features

- ✅ **Security**: Private Endpoints, TDE encryption, Managed Identity, Key Vault
- ✅ **High Availability**: Zone redundancy, auto-scaling (2-5 instances), 99.995% SLA
- ✅ **Infrastructure as Code**: Modular Terraform with 6 reusable modules
- ✅ **Monitoring**: Application Insights, health checks, audit logging

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