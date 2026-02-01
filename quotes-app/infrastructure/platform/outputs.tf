output "sql_server_name" {
  description = "The name of the SQL Server"
  value       = module.sql_database.sql_server_name
}

output "sql_database_name" {
  description = "The name of the SQL Database"
  value       = module.sql_database.sql_database_name
}

output "app_service_name" {
  description = "The name of the App Service"
  value       = module.app_service.app_service_name
}

output "sql_server_fqdn" {
  description = "The FQDN of the SQL Server"
  value       = module.sql_database.sql_server_fqdn
}

