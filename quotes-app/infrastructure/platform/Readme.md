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
``