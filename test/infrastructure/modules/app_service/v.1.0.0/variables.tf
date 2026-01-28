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

variable "app_insights_connection_string" {
  description = "Application Insights connection string"
  type        = string
  sensitive   = true
}

variable "sql_connection_secret_id" {
  description = "Key Vault secret ID for SQL connection string"
  type        = string
}

variable "app_service_subnet_id" {
  description = "Subnet ID for App Service VNet integration"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "sku_name" {
  description = "App Service Plan SKU"
  type        = string
  default     = "P1v2"
}

variable "zone_balancing_enabled" {
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
