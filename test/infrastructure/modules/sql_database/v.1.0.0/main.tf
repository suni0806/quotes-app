# ===================================================================
# SQL Database Module
# Creates SQL Server, Database, Private Endpoint, and Auditing
# ===================================================================

# Random password for SQL administrator
resource "random_password" "admin" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Azure SQL Server
resource "azurerm_mssql_server" "main" {
  name                         = "${var.project_name}-sqlsvr-${var.environment}-${var.suffix}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.admin_username
  administrator_login_password = random_password.admin.result

  public_network_access_enabled = true
  minimum_tls_version           = "1.2"

  azuread_administrator {
    login_username = var.object_id
    object_id      = var.object_id
  }



  tags = var.tags
}

# Azure SQL Database with Zone Redundancy
resource "azurerm_mssql_database" "main" {
  name      = "${var.project_name}-sqldb-${var.environment}"
  server_id = azurerm_mssql_server.main.id
  collation = "SQL_Latin1_General_CP1_CI_AS"

  sku_name       = var.sku_name
  zone_redundant = var.zone_redundant

  transparent_data_encryption_enabled = true

  short_term_retention_policy {
    retention_days = var.backup_retention_days
  }

  long_term_retention_policy {
    weekly_retention  = "P1W"
    monthly_retention = "P1M"
    yearly_retention  = "P1Y"
    week_of_year      = 1
  }

  tags = var.tags
}

# SQL Auditing
resource "azurerm_mssql_server_extended_auditing_policy" "main" {
  server_id                  = azurerm_mssql_server.main.id
  storage_endpoint           = var.audit_storage_endpoint
  storage_account_access_key = var.audit_storage_access_key
  retention_in_days          = var.audit_retention_days
}

# Private Endpoint for SQL
resource "azurerm_private_endpoint" "sql" {
  name                = "${var.project_name}-sqlpe-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-sql"
    private_connection_resource_id = azurerm_mssql_server.main.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "sql-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  tags = var.tags
}
