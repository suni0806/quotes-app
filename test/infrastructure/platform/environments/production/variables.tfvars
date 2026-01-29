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
# App Service Configuration - Production uses Premium tier with zone balancing
app_service_sku                    = "P1v2" # Premium tier for production
app_service_zone_balancing_enabled = true   # Enable zone balancing for HA
autoscale_min_instances            = 2
autoscale_max_instances            = 10
autoscale_default_instances        = 3
autoscale_cpu_threshold_high       = 70
autoscale_cpu_threshold_low        = 30

# SQL Database Configuration - Production uses Premium tier with zone redundancy
sql_database_sku          = "P1"
sql_zone_redundant        = true # Enable zone redundancy for HA
sql_backup_retention_days = 35
sql_audit_retention_days  = 90

# Storage Configuration - Production uses GRS for geo-redundancy
storage_account_tier     = "Standard"
storage_replication_type = "GRS"

# Networking Configuration
vnet_address_space             = ["10.0.0.0/16"]
app_service_subnet_prefix      = ["10.0.1.0/24"]
private_endpoint_subnet_prefix = ["10.0.2.0/24"]

# Monitoring Configuration
log_analytics_retention_days = 90