# Production Environment Variables
environment        = "production"
project_name       = "quotesapp"
location           = "eastus2"
sql_admin_username = "sqladmin"
# sql_admin_password should be set via environment variable or passed at runtime

common_tags = {
  Environment = "Production"
  Project     = "RandomQuotes"
  ManagedBy   = "Terraform"
  CostCenter  = "Engineering"
  Compliance  = "Required"
}
# App Service Configuration - Production downgraded to basic to bypass quota
app_service_sku                    = "B1"
app_service_zone_balancing_enabled = false
autoscale_min_instances            = 1
autoscale_max_instances            = 1
autoscale_default_instances        = 1
autoscale_cpu_threshold_high       = 70
autoscale_cpu_threshold_low        = 30

# SQL Database Configuration - Production downgraded to basic to bypass quota
sql_database_sku          = "Basic"
sql_zone_redundant        = false
sql_backup_retention_days = 7
sql_audit_retention_days  = 7

# Storage Configuration - Production downgraded to LRS
storage_account_tier     = "Standard"
storage_replication_type = "LRS"

# Networking Configuration
vnet_address_space             = ["10.0.0.0/16"]
app_service_subnet_prefix      = ["10.0.1.0/24"]
private_endpoint_subnet_prefix = ["10.0.2.0/24"]

# Monitoring Configuration
log_analytics_retention_days = 90