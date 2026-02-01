# Cleanup script to destroy all Azure resources created by Terraform

$ErrorActionPreference = "Stop"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  Azure Resources Cleanup" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "WARNING: This will destroy all Azure resources created by this project!" -ForegroundColor Red
Write-Host "This action cannot be undone!" -ForegroundColor Red
Write-Host ""

$confirmation = Read-Host "Are you sure you want to continue? Type 'yes' to confirm"

if ($confirmation -ne "yes") {
    Write-Host "⚠ Cleanup cancelled" -ForegroundColor Yellow
    exit 0
}

Push-Location terraform

Write-Host "⚠ Running Terraform destroy..." -ForegroundColor Yellow
terraform destroy

Write-Host "✓ All resources have been destroyed!" -ForegroundColor Green
Write-Host ""
Write-Host "⚠ Note: Some resources like Key Vault may have soft-delete enabled" -ForegroundColor Yellow
Write-Host "⚠ You may need to purge them manually from Azure Portal" -ForegroundColor Yellow

Pop-Location
