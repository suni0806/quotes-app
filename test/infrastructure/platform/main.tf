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
  keepers = {
    # Changing the location will force a new suffix and fresh resource names
    location = var.location
  }
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
  source = "../modules/networking/v.1.0.0"

  resource_group_name            = azurerm_resource_group.main.name
  location                       = azurerm_resource_group.main.location
  environment                    = var.environment
  project_name                   = var.project_name
  vnet_address_space             = var.vnet_address_space
  app_service_subnet_prefix      = var.app_service_subnet_prefix
  private_endpoint_subnet_prefix = var.private_endpoint_subnet_prefix
  app_service_subnet_delegations = var.app_service_subnet_delegations
  tags                           = azurerm_resource_group.main.tags
}

# ===================================================================
# Module: Storage (for SQL audit logs)
# Creates storage account for auditing
# ===================================================================
module "storage" {
  source = "../modules/storage/v.1.0.0"

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
  source = "../modules/sql_database/v.1.0.0"

  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  environment                = var.environment
  project_name               = var.project_name
  suffix                     = random_string.suffix.result
  admin_username             = var.sql_admin_username
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
  source = "../modules/monitoring/v.1.0.0"

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
  source = "../modules/app_service/v.1.0.0"

  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  environment                  = var.environment
  project_name                 = var.project_name
  suffix                       = random_string.suffix.result
  sku_name                     = var.app_service_sku
  zone_balancing_enabled       = var.app_service_zone_balancing_enabled
  autoscale_min_instances      = var.autoscale_min_instances
  autoscale_max_instances      = var.autoscale_max_instances
  autoscale_default_instances  = var.autoscale_default_instances
  autoscale_cpu_threshold_high = var.autoscale_cpu_threshold_high
  autoscale_cpu_threshold_low  = var.autoscale_cpu_threshold_low
  os_type                      = var.app_service_os_type
  identity                     = var.app_service_identity
  application_stack            = var.app_service_application_stack
  app_settings = merge(var.extra_app_settings, {
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = module.monitoring.app_insights_connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = var.app_service_appinsights_extension_version
    "SQL_SERVER"                                 = module.sql_database.sql_server_fqdn
    "SQL_DATABASE"                               = module.sql_database.sql_database_name
  })
  # Free tier (F1) does not support VNet integration on Linux
  app_service_subnet_id = var.app_service_sku == "F1" ? null : module.networking.app_service_subnet_id
  always_on             = var.app_service_always_on
  tags                  = azurerm_resource_group.main.tags

  depends_on = [module.monitoring, module.sql_database]
}

# ===================================================================
# Module: Key Vault
# Creates Key Vault and stores secrets
# ===================================================================
module "key_vault" {
  source = "../modules/key_vault/v.1.0.0"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  project_name        = var.project_name
  suffix              = random_string.suffix.result
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id

  sql_connection_string = "Server=tcp:${module.sql_database.sql_server_fqdn},1433;Initial Catalog=${module.sql_database.sql_database_name};Authentication=\"Active Directory Managed Identity\";Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  tags                  = azurerm_resource_group.main.tags

  depends_on = [module.sql_database]
}

# ===================================================================
# Key Vault Access Policy for App Service
# Defined outside module to break circular dependency
# ===================================================================
resource "azurerm_key_vault_access_policy" "app_service" {
  key_vault_id = module.key_vault.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = module.app_service.app_service_principal_id

  secret_permissions = [
    "Get", "List"
  ]
}
