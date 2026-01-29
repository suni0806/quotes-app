# ===================================================================
# Storage Module
# Creates storage account for audit logs
# ===================================================================

# Storage Account for Audit Logs
resource "azurerm_storage_account" "audit" {
  name                     = "${var.project_name}stg${var.suffix}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.replication_type

  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"

  tags = var.tags
}
