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
}



# ===================================================================
# App Service Configuration
# ===================================================================
variable "app_service_sku" {
  description = "App Service Plan SKU"
  type        = string
}

variable "app_service_os_type" {
  description = "OS Type for the App Service"
  type        = string
}

variable "app_service_zone_balancing_enabled" {
  description = "Enable zone balancing for App Service Plan"
  type        = bool
}

variable "autoscale_min_instances" {
  description = "Minimum number of instances for auto-scaling"
  type        = number
}

variable "autoscale_max_instances" {
  description = "Maximum number of instances for auto-scaling"
  type        = number
}

variable "autoscale_default_instances" {
  description = "Default number of instances for auto-scaling"
  type        = number
}

variable "autoscale_cpu_threshold_high" {
  description = "CPU percentage threshold for scaling up"
  type        = number
}

variable "autoscale_cpu_threshold_low" {
  description = "CPU percentage threshold for scaling down"
  type        = number
}

variable "app_service_identity" {
  description = "Managed Identity configuration for App Service"
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
}

variable "app_service_application_stack" {
  description = "Application stack configuration for App Service"
  type        = any
}

variable "app_service_appinsights_extension_version" {
  description = "Application Insights extension version"
  type        = string
}

variable "extra_app_settings" {
  description = "Additional application settings"
  type        = map(string)
}

# ===================================================================
# SQL Database Configuration
# ===================================================================
variable "sql_database_sku" {
  description = "SQL Database SKU"
  type        = string
}

variable "sql_zone_redundant" {
  description = "Enable zone redundancy for SQL Database"
  type        = bool
}

variable "sql_backup_retention_days" {
  description = "Short-term backup retention in days"
  type        = number
}

variable "sql_audit_retention_days" {
  description = "SQL audit log retention in days"
  type        = number
}

# ===================================================================
# Storage Configuration
# ===================================================================
variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
}

variable "storage_replication_type" {
  description = "Storage account replication type"
  type        = string
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
}
variable "app_service_always_on" {
  description = "Enable Always On for App Service (not supported on Free/Shared tiers)"
  type        = bool
}
