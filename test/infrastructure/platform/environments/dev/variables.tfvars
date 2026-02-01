# Dev Environment Variables
environment        = "dev"
project_name       = "quotesapp"
location           = "canadacentral"
sql_admin_username = "sqladmin"
# sql_admin_password should be set via environment variable or passed at runtime

common_tags = {
  Environment = "Development"
  Project     = "RandomQuotes"
  ManagedBy   = "Terraform"
  CostCenter  = "Engineering"
}

# App Service Configuration - Dev uses smallest available SKU
app_service_sku                           = "B1" # Smallest Basic tier
app_service_zone_balancing_enabled        = false
autoscale_min_instances                   = 1
autoscale_max_instances                   = 1
autoscale_default_instances               = 1
autoscale_cpu_threshold_high              = 80
autoscale_cpu_threshold_low               = 20
app_service_node_version                  = "~18"
app_service_appinsights_extension_version = "~3"

# SQL Database Configuration - Dev uses Basic tier
sql_database_sku          = "Basic"
sql_zone_redundant        = false
sql_backup_retention_days = 7
sql_audit_retention_days  = 7 # Reduced for quota/cost

# Storage Configuration - Dev uses LRS for cost savings
storage_account_tier     = "Standard"
storage_replication_type = "LRS"

# Networking Configuration - Dev uses smaller address spaces
vnet_address_space             = ["10.1.0.0/16"]
app_service_subnet_prefix      = ["10.1.1.0/24"]
private_endpoint_subnet_prefix = ["10.1.2.0/24"]
app_service_subnet_delegations = [
  {
    name = "app-service-delegation"
    service_delegation = {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
]

# Monitoring Configuration
log_analytics_retention_days = 30
