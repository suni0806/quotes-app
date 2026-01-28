output "key_vault_id" {
  description = "Resource ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "sql_connection_secret_id" {
  description = "Secret ID for SQL connection string"
  value       = azurerm_key_vault_secret.sql_connection_string.id
}

output "sql_connection_secret_version_id" {
  description = "Versioned secret ID for SQL connection string"
  value       = azurerm_key_vault_secret.sql_connection_string.versionless_id
}
