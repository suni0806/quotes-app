# Staging Environment Variables
environment        = "staging"
project_name       = "quotesapp"
location           = "eastus"
sql_admin_username = "sqladmin"
# sql_admin_password should be set via environment variable or passed at runtime

common_tags = {
  Environment = "Staging"
  Project     = "RandomQuotes"
  ManagedBy   = "Terraform"
  CostCenter  = "Engineering"
}

# App Service Configuration - Staging uses Standard tier
app_service_sku                    = "S2" # Standard tier for staging
app_service_zone_balancing_enabled = false
autoscale_min_instances            = 2
autoscale_max_instances            = 4
autoscale_default_instances        = 2
autoscale_cpu_threshold_high       = 75
autoscale_cpu_threshold_low        = 25

# SQL Database Configuration - Staging uses Standard tier
sql_database_sku          = "S3"
sql_zone_redundant        = false
sql_backup_retention_days = 14
sql_audit_retention_days  = 60

# Storage Configuration - Staging uses GRS
storage_account_tier     = "Standard"
storage_replication_type = "GRS"

# Networking Configuration
vnet_address_space             = ["10.2.0.0/16"]
app_service_subnet_prefix      = ["10.2.1.0/24"]
private_endpoint_subnet_prefix = ["10.2.2.0/24"]

# Monitoring Configuration
log_analytics_retention_days = 60
