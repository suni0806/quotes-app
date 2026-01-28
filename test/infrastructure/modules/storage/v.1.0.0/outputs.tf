output "storage_account_id" {
  description = "Resource ID of the storage account"
  value       = azurerm_storage_account.audit.id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.audit.name
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint of the storage account"
  value       = azurerm_storage_account.audit.primary_blob_endpoint
}

output "primary_access_key" {
  description = "Primary access key of the storage account"
  value       = azurerm_storage_account.audit.primary_access_key
  sensitive   = true
}

output "secondary_access_key" {
  description = "Secondary access key of the storage account"
  value       = azurerm_storage_account.audit.secondary_access_key
  sensitive   = true
}
