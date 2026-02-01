output "vnet_id" {
  description = "Resource ID of the Virtual Network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.main.name
}

output "app_service_subnet_id" {
  description = "Resource ID of the App Service subnet"
  value       = azurerm_subnet.app_service.id
}

output "app_service_subnet_name" {
  description = "Name of the App Service subnet"
  value       = azurerm_subnet.app_service.name
}

output "private_endpoint_subnet_id" {
  description = "Resource ID of the private endpoint subnet"
  value       = azurerm_subnet.private_endpoints.id
}

output "private_endpoint_subnet_name" {
  description = "Name of the private endpoint subnet"
  value       = azurerm_subnet.private_endpoints.name
}

output "private_dns_zone_id" {
  description = "Resource ID of the private DNS zone for SQL"
  value       = azurerm_private_dns_zone.sql.id
}

output "private_dns_zone_name" {
  description = "Name of the private DNS zone"
  value       = azurerm_private_dns_zone.sql.name
}
