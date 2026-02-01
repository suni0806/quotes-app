variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "suffix" {
  description = "Unique suffix for resource names"
  type        = string
}

variable "admin_username" {
  description = "SQL Server administrator username"
  type        = string
  sensitive   = true
}



variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for SQL Server"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "object_id" {
  description = "Azure AD object ID for AAD administrator"
  type        = string
}

variable "audit_storage_endpoint" {
  description = "Storage account blob endpoint for audit logs"
  type        = string
}

variable "audit_storage_access_key" {
  description = "Storage account access key for audit logs"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "sku_name" {
  description = "SQL Database SKU"
  type        = string
  default     = "P1"
}

variable "zone_redundant" {
  description = "Enable zone redundancy for SQL Database"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Short-term backup retention in days"
  type        = number
  default     = 7
}

variable "audit_retention_days" {
  description = "SQL audit log retention in days"
  type        = number
  default     = 90
}
