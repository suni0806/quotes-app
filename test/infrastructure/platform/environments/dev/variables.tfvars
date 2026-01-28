# Dev Environment Variables
environment         = "dev"
project_name        = "quotesapp"
location           = "eastus"
sql_admin_username = "sqladmin"
# sql_admin_password should be set via environment variable or passed at runtime

common_tags = {
  Environment = "Development"
  Project     = "RandomQuotes"
  ManagedBy   = "Terraform"
  CostCenter  = "Engineering"
}

# App Service Configuration - Dev uses smaller SKU for cost savings
app_service_sku                     = "B2"  # Basic tier for dev
app_service_zone_balancing_enabled  = false  # Disable zone balancing in dev
autoscale_min_instances             = 1
autoscale_max_instances             = 2
autoscale_default_instances         = 1
autoscale_cpu_threshold_high        = 80
autoscale_cpu_threshold_low         = 20

# SQL Database Configuration - Dev uses Basic tier
sql_database_sku            = "Basic"
sql_zone_redundant          = false  # No zone redundancy in dev
sql_backup_retention_days   = 7
sql_audit_retention_days    = 30  # Shorter retention in dev

# Storage Configuration - Dev uses LRS for cost savings
storage_account_tier        = "Standard"
storage_replication_type    = "LRS"

# Networking Configuration - Dev uses smaller address spaces
vnet_address_space              = ["10.1.0.0/16"]
app_service_subnet_prefix       = ["10.1.1.0/24"]
private_endpoint_subnet_prefix  = ["10.1.2.0/24"]

# Monitoring Configuration
log_analytics_retention_days = 30
