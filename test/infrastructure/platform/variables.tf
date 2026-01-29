variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "quotesapp"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus2"
}

variable "sql_admin_username" {
  description = "SQL Server administrator username"
  type        = string
  sensitive   = true
  default     = "sqladmin"
}

variable "sql_admin_password" {
  description = "SQL Server administrator password"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.sql_admin_password) >= 12
    error_message = "Password must be at least 12 characters long."
  }
}

# ===================================================================
# App Service Configuration
# ===================================================================
variable "app_service_sku" {
  description = "App Service Plan SKU"
  type        = string
  default     = "P1v2"
}

variable "app_service_zone_balancing_enabled" {
  description = "Enable zone balancing for App Service Plan"
  type        = bool
  default     = true
}

variable "autoscale_min_instances" {
  description = "Minimum number of instances for auto-scaling"
  type        = number
  default     = 2
}

variable "autoscale_max_instances" {
  description = "Maximum number of instances for auto-scaling"
  type        = number
  default     = 5
}

variable "autoscale_default_instances" {
  description = "Default number of instances for auto-scaling"
  type        = number
  default     = 2
}

variable "autoscale_cpu_threshold_high" {
  description = "CPU percentage threshold for scaling up"
  type        = number
  default     = 75
}

variable "autoscale_cpu_threshold_low" {
  description = "CPU percentage threshold for scaling down"
  type        = number
  default     = 25
}

# ===================================================================
# SQL Database Configuration
# ===================================================================
variable "sql_database_sku" {
  description = "SQL Database SKU"
  type        = string
  default     = "P1"
}

variable "sql_zone_redundant" {
  description = "Enable zone redundancy for SQL Database"
  type        = bool
  default     = true
}

variable "sql_backup_retention_days" {
  description = "Short-term backup retention in days"
  type        = number
  default     = 7
}

variable "sql_audit_retention_days" {
  description = "SQL audit log retention in days"
  type        = number
  default     = 90
}

# ===================================================================
# Storage Configuration
# ===================================================================
variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "GRS"
}

# ===================================================================
# Networking Configuration
# ===================================================================
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "app_service_subnet_prefix" {
  description = "Address prefix for App Service subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "private_endpoint_subnet_prefix" {
  description = "Address prefix for private endpoint subnet"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

# ===================================================================
# Monitoring Configuration
# ===================================================================
variable "log_analytics_retention_days" {
  description = "Log Analytics retention in days"
  type        = number
  default     = 30
}
