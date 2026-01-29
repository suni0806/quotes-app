# ===================================================================
# Main Terraform Configuration - Quotes Application Infrastructure
# Uses modular approach with separate modules for each component
# ===================================================================

# Data source for current client
data "azurerm_client_config" "current" {}

# Random suffix for unique names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-rg-${var.environment}-${random_string.suffix.result}"
  location = var.location

  tags = merge(var.common_tags, {
    Environment = var.environment
    Purpose     = "Random Quotes Application"
    ManagedBy   = "Terraform"
  })
}

# ===================================================================
# Module: Networking
# Creates VNet, Subnets, and Private DNS zones
# ===================================================================
module "networking" {
  source = "../../modules/networking/v.1.0.0"

  resource_group_name            = azurerm_resource_group.main.name
  location                       = azurerm_resource_group.main.location
  environment                    = var.environment
  project_name                   = var.project_name
  vnet_address_space             = var.vnet_address_space
  app_service_subnet_prefix      = var.app_service_subnet_prefix
  private_endpoint_subnet_prefix = var.private_endpoint_subnet_prefix
  tags                           = azurerm_resource_group.main.tags
}

# ===================================================================
# Module: Storage (for SQL audit logs)
# Creates storage account for auditing
# ===================================================================
module "storage" {
  source = "../../modules/storage/v.1.0.0"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  project_name        = var.project_name
  suffix              = random_string.suffix.result
  account_tier        = var.storage_account_tier
  replication_type    = var.storage_replication_type
  tags                = azurerm_resource_group.main.tags
}

# ===================================================================
# Module: SQL Database
# Creates SQL Server, Database, and Private Endpoint
# ===================================================================
module "sql_database" {
  source = "../../modules/sql_database/v.1.0.0"

  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  environment                = var.environment
  project_name               = var.project_name
  suffix                     = random_string.suffix.result
  admin_username             = var.sql_admin_username
  admin_password             = var.sql_admin_password
  sku_name                   = var.sql_database_sku
  zone_redundant             = var.sql_zone_redundant
  backup_retention_days      = var.sql_backup_retention_days
  audit_retention_days       = var.sql_audit_retention_days
  private_endpoint_subnet_id = module.networking.private_endpoint_subnet_id
  private_dns_zone_id        = module.networking.private_dns_zone_id
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  object_id                  = data.azurerm_client_config.current.object_id
  audit_storage_endpoint     = module.storage.primary_blob_endpoint
  audit_storage_access_key   = module.storage.primary_access_key
  tags                       = azurerm_resource_group.main.tags

  depends_on = [module.networking, module.storage]
}

# ===================================================================
# Module: Monitoring
# Creates Application Insights and Log Analytics
# ===================================================================
module "monitoring" {
  source = "../../modules/monitoring/v.1.0.0"

  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  environment                  = var.environment
  project_name                 = var.project_name
  log_analytics_retention_days = var.log_analytics_retention_days
  tags                         = azurerm_resource_group.main.tags
}

# ===================================================================
# Module: App Service
# Creates App Service Plan, Web App, and Auto-scaling
# ===================================================================
module "app_service" {
  source = "../../modules/app_service/v.1.0.0"

  resource_group_name            = azurerm_resource_group.main.name
  location                       = azurerm_resource_group.main.location
  environment                    = var.environment
  project_name                   = var.project_name
  suffix                         = random_string.suffix.result
  sku_name                       = var.app_service_sku
  zone_balancing_enabled         = var.app_service_zone_balancing_enabled
  autoscale_min_instances        = var.autoscale_min_instances
  autoscale_max_instances        = var.autoscale_max_instances
  autoscale_default_instances    = var.autoscale_default_instances
  autoscale_cpu_threshold_high   = var.autoscale_cpu_threshold_high
  autoscale_cpu_threshold_low    = var.autoscale_cpu_threshold_low
  app_insights_connection_string = module.monitoring.app_insights_connection_string
  sql_connection_secret_id       = module.key_vault.sql_connection_secret_id
  app_service_subnet_id          = module.networking.app_service_subnet_id
  tags                           = azurerm_resource_group.main.tags

  depends_on = [module.monitoring, module.key_vault]
}

# ===================================================================
# Module: Key Vault
# Creates Key Vault and stores secrets
# ===================================================================
module "key_vault" {
  source = "../../modules/key_vault/v.1.0.0"

  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  project_name             = var.project_name
  suffix                   = random_string.suffix.result
  tenant_id                = data.azurerm_client_config.current.tenant_id
  object_id                = data.azurerm_client_config.current.object_id
  app_service_principal_id = module.app_service.app_service_principal_id
  sql_connection_string    = "Server=tcp:${module.sql_database.sql_server_fqdn},1433;Initial Catalog=${module.sql_database.sql_database_name};Persist Security Info=False;User ID=${var.sql_admin_username};Password=${var.sql_admin_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  tags                     = azurerm_resource_group.main.tags

  depends_on = [module.sql_database, module.app_service]
}
