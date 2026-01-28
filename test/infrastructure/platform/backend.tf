terraform {
  backend "azurerm" {
    # Backend configuration is provided via backend.tfvars file
    # Run: terraform init -backend-config=environments/{env}/backend.tfvars
  }
}
