variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}



variable "sql_admin_username" {
  description = "SQL Server administrator username"
  type        = string
  sensitive   = true
  default     = "sqladmin"
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

variable "app_service_node_version" {
  description = "Node.js version for the Web App"
  type        = string
  default     = "~18"
}

variable "app_service_appinsights_extension_version" {
  description = "Application Insights extension version"
  type        = string
  default     = "~3"
}

variable "extra_app_settings" {
  description = "Additional application settings"
  type        = map(string)
  default     = {}
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
}

variable "app_service_subnet_prefix" {
  description = "Address prefix for App Service subnet"
  type        = list(string)
}

variable "private_endpoint_subnet_prefix" {
  description = "Address prefix for private endpoint subnet"
  type        = list(string)
}

variable "app_service_subnet_delegations" {
  description = "Delegations for the App Service subnet"
  type = list(object({
    name = string
    service_delegation = object({
      name    = string
      actions = list(string)
    })
  }))
}

# ===================================================================
# Monitoring Configuration
# ===================================================================
variable "log_analytics_retention_days" {
  description = "Log Analytics retention in days"
  type        = number
  default     = 30
}
variable "app_service_always_on" {
  description = "Enable Always On for App Service (not supported on Free/Shared tiers)"
  type        = bool
  default     = true
}
