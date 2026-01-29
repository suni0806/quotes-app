output "sql_server_id" {
  description = "Resource ID of the SQL Server"
  value       = azurerm_mssql_server.main.id
}

output "sql_server_name" {
  description = "Name of the SQL Server"
  value       = azurerm_mssql_server.main.name
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "sql_database_name" {
  description = "Name of the SQL Database"
  value       = azurerm_mssql_database.main.name
}

output "sql_database_id" {
  description = "Resource ID of the SQL Database"
  value       = azurerm_mssql_database.main.id
}

output "private_endpoint_id" {
  description = "Resource ID of the private endpoint"
  value       = azurerm_private_endpoint.sql.id
}
