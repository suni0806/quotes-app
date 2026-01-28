# Project File Structure

```
test/
│
├── 📄 README.md                    # Main project documentation
├── 📄 QUICKSTART.md                # Quick start guide (15-20 min deployment)
├── 📄 PROJECT_SUMMARY.md           # Executive summary and AI usage disclosure
├── 📄 ARCHITECTURE.md              # System architecture and design
├── 📄 DEPLOYMENT.md                # Detailed deployment guide
├── 📄 SECURITY.md                  # Security and compliance documentation
├── 📄 CONTRIBUTING.md              # Contribution guidelines
├── 📄 .gitignore                   # Git ignore rules
│
├── 🚀 deploy.sh                    # Bash deployment script
├── 🚀 deploy.ps1                   # PowerShell deployment script
├── 🧹 cleanup.sh                   # Resource cleanup script (Bash)
├── 🧹 cleanup.ps1                  # Resource cleanup script (PowerShell)
│
├── 📁 terraform/                   # Infrastructure as Code
│   ├── main.tf                     # Main Terraform config (15 Azure resources)
│   ├── variables.tf                # Input variables
│   ├── outputs.tf                  # Output values
│   └── terraform.tfvars.example    # Example configuration
│
├── 📁 app/                         # Web Application
│   ├── server.js                   # Express server + SQL logic
│   ├── package.json                # Node.js dependencies
│   ├── .env.example                # Example environment variables
│   └── 📁 public/
│       └── index.html              # Frontend UI
│
└── 📁 scripts/                     # Database Utilities
    ├── seed-database.js            # Database seeding script (50 quotes)
    ├── package.json                # Dependencies for scripts
    └── .env.example                # Example environment variables
```

## File Descriptions

### Documentation Files

| File | Purpose | Lines | Read Time |
|------|---------|-------|-----------|
| **README.md** | Main project overview, setup instructions | 250 | 10 min |
| **QUICKSTART.md** | Fast deployment guide | 150 | 5 min |
| **PROJECT_SUMMARY.md** | Executive summary, AI usage disclosure | 400 | 15 min |
| **ARCHITECTURE.md** | System architecture, diagrams, components | 350 | 15 min |
| **DEPLOYMENT.md** | Step-by-step deployment, troubleshooting | 500 | 20 min |
| **SECURITY.md** | Security measures, compliance, PII protection | 600 | 25 min |
| **CONTRIBUTING.md** | Contribution guidelines, code standards | 300 | 10 min |

### Infrastructure Files

| File | Purpose | Technology | Lines |
|------|---------|------------|-------|
| **terraform/main.tf** | Azure resources definition | HCL | 450 |
| **terraform/variables.tf** | Input parameters | HCL | 30 |
| **terraform/outputs.tf** | Deployment outputs | HCL | 50 |
| **terraform/terraform.tfvars.example** | Configuration template | HCL | 10 |

### Application Files

| File | Purpose | Technology | Lines |
|------|---------|------------|-------|
| **app/server.js** | Web server + database logic | Node.js | 220 |
| **app/public/index.html** | User interface | HTML/CSS/JS | 350 |
| **app/package.json** | Dependencies | JSON | 30 |
| **app/.env.example** | Config template | ENV | 15 |

### Script Files

| File | Purpose | Technology | Lines |
|------|---------|------------|-------|
| **scripts/seed-database.js** | Database seeding | Node.js | 200 |
| **scripts/package.json** | Script dependencies | JSON | 15 |
| **deploy.ps1** | Automated deployment | PowerShell | 150 |
| **deploy.sh** | Automated deployment | Bash | 130 |
| **cleanup.ps1** | Resource cleanup | PowerShell | 40 |
| **cleanup.sh** | Resource cleanup | Bash | 35 |

## Total Project Stats

- **Total Files**: 25+
- **Total Lines of Code**: ~2,500+
- **Documentation Lines**: ~2,500+
- **Languages**: HCL, JavaScript, HTML, CSS, Bash, PowerShell
- **Azure Resources Created**: 15
- **Development Time**: ~15 hours (with AI assistance)

## Key Technologies

### Infrastructure
- ✅ Terraform (IaC)
- ✅ Azure Resource Manager
- ✅ Azure CLI

### Application
- ✅ Node.js 18 LTS
- ✅ Express.js
- ✅ mssql (SQL Server driver)
- ✅ Application Insights SDK

### Azure Services
- ✅ App Service (Linux, Premium v2)
- ✅ SQL Database (Premium, Zone-redundant)
- ✅ Virtual Network
- ✅ Private Endpoint
- ✅ Key Vault
- ✅ Application Insights
- ✅ Log Analytics
- ✅ Storage Account (GRS)
- ✅ Monitor Autoscale

## Reading Order

### For Deployment
1. 📄 QUICKSTART.md (fastest path)
2. 📄 README.md (complete overview)
3. 📄 DEPLOYMENT.md (detailed steps)

### For Understanding
1. 📄 PROJECT_SUMMARY.md (high-level overview)
2. 📄 ARCHITECTURE.md (system design)
3. 📄 SECURITY.md (security details)

### For Contributing
1. 📄 CONTRIBUTING.md (guidelines)
2. 📄 CODE_STRUCTURE.md (this file)
3. Review existing code

## Code Navigation

### To modify infrastructure:
```
terraform/main.tf          → Resource definitions
terraform/variables.tf     → Change default values
terraform/outputs.tf       → Add new outputs
```

### To modify application:
```
app/server.js             → Backend logic
app/public/index.html     → Frontend UI
app/package.json          → Dependencies
```

### To modify database:
```
scripts/seed-database.js  → Seed data
app/server.js (lines 40-60) → Table schema
```

## Quick Actions

### Deploy Everything
```powershell
cd terraform
terraform init
terraform apply
cd ..
.\deploy.ps1
```

### Update Application Only
```powershell
cd app
# Make changes
cd ..
Compress-Archive -Path "app\*" -DestinationPath "app.zip" -Force
az webapp deployment source config-zip --resource-group <rg> --name <app> --src app.zip
```

### Update Infrastructure Only
```powershell
cd terraform
# Modify .tf files
terraform plan
terraform apply
```

### View Logs
```powershell
az webapp log tail --resource-group <rg> --name <app>
```

### Destroy Everything
```powershell
cd terraform
terraform destroy
```

## File Size Breakdown

```
Documentation:   ~150 KB (2,500 lines)
Code:           ~100 KB (2,500 lines)
Total:          ~250 KB
```

## Dependencies

### Required
- Azure CLI
- Terraform 1.0+
- Node.js 18+
- Azure Subscription

### Optional
- Git (for version control)
- VS Code (recommended IDE)
- PowerShell 7+ (for scripts)

## License

MIT License - See README.md for details

---

**Navigation Tip**: Use Ctrl+F to search for specific files or topics in this document.
