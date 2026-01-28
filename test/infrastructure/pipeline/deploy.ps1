# Azure Random Quotes - Deployment Script (PowerShell)
# This script automates the deployment of the application to Azure

$ErrorActionPreference = "Stop"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  Azure Random Quotes Deployment" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

# Check if Azure CLI is installed
try {
    $null = Get-Command az -ErrorAction Stop
    Write-Success "Azure CLI found"
} catch {
    Write-Error-Custom "Azure CLI is not installed. Please install it first."
    Write-Host "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
}

# Check if Terraform is installed
try {
    $null = Get-Command terraform -ErrorAction Stop
    Write-Success "Terraform found"
} catch {
    Write-Error-Custom "Terraform is not installed. Please install it first."
    Write-Host "Visit: https://www.terraform.io/downloads.html"
    exit 1
}

# Check if logged into Azure
Write-Host ""
Write-Host "Checking Azure login status..."
try {
    $account = az account show 2>$null | ConvertFrom-Json
    Write-Success "Already logged into Azure"
    Write-Host "Current subscription: $($account.name)"
} catch {
    Write-Warning-Custom "Not logged into Azure. Initiating login..."
    az login
}

# Confirm subscription
Write-Host ""
$continue = Read-Host "Continue with current subscription? (y/n)"
if ($continue -ne 'y' -and $continue -ne 'Y') {
    Write-Host "Please set the correct subscription using: az account set --subscription <subscription-id>"
    exit 0
}

# Check if terraform.tfvars exists
Write-Host ""
if (-not (Test-Path "terraform\terraform.tfvars")) {
    Write-Warning-Custom "terraform.tfvars not found"
    Write-Host "Creating from example..."
    Copy-Item "terraform\terraform.tfvars.example" "terraform\terraform.tfvars"
    Write-Warning-Custom "Please edit terraform\terraform.tfvars with your values before continuing"
    Read-Host "Press enter when ready..."
}

# Deploy infrastructure with Terraform
Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  Deploying Infrastructure" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

Push-Location terraform

Write-Success "Initializing Terraform..."
terraform init

Write-Success "Validating Terraform configuration..."
terraform validate

Write-Host ""
Write-Warning-Custom "Running Terraform plan..."
terraform plan -out=tfplan

Write-Host ""
$continue = Read-Host "Review the plan above. Continue with apply? (y/n)"
if ($continue -ne 'y' -and $continue -ne 'Y') {
    Write-Warning-Custom "Deployment cancelled"
    Pop-Location
    exit 0
}

Write-Success "Applying Terraform configuration..."
terraform apply tfplan

Write-Success "Infrastructure deployed successfully!"

# Get outputs
Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  Retrieving Deployment Information" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

$resourceGroup = terraform output -raw resource_group_name
$appServiceName = terraform output -raw app_service_name
$sqlServer = terraform output -raw sql_server_fqdn
$sqlDatabase = terraform output -raw sql_database_name

Write-Success "Resource Group: $resourceGroup"
Write-Success "App Service: $appServiceName"
Write-Success "SQL Server: $sqlServer"
Write-Success "SQL Database: $sqlDatabase"

Pop-Location

# Build application package
Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  Building Application Package" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

Push-Location app

Write-Success "Installing dependencies..."
npm install --production

Write-Success "Creating deployment package..."
Pop-Location

# Create zip file
if (Test-Path "app.zip") {
    Remove-Item "app.zip"
}

Compress-Archive -Path "app\*" -DestinationPath "app.zip" -Force

Write-Success "Application package created"

# Deploy application
Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  Deploying Application" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

Write-Success "Deploying to App Service..."
az webapp deployment source config-zip `
  --resource-group $resourceGroup `
  --name $appServiceName `
  --src app.zip

Write-Success "Application deployed successfully!"

# Seed database
Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  Database Seeding" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

Write-Warning-Custom "Database seeding requires connection string"
Write-Host "You can seed the database using the scripts\seed-database.js script"
Write-Host ""
Write-Host "Instructions:"
Write-Host "1. cd scripts"
Write-Host "2. Copy .env.example to .env"
Write-Host "3. Update .env with connection string from Key Vault"
Write-Host "4. Run: npm install; node seed-database.js"

# Get App URL
Push-Location terraform
$appUrl = terraform output -raw app_service_url
Pop-Location

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  Deployment Complete!" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Success "Application URL: $appUrl"
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Seed the database (see instructions above)"
Write-Host "2. Visit the application URL to test"
Write-Host "3. Monitor in Azure Portal: https://portal.azure.com"
Write-Host ""
Write-Success "Deployment successful! 🚀"
