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

variable "app_service_subnet_id" {
  description = "Subnet ID for App Service VNet integration"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "sku_name" {
  description = "App Service Plan SKU"
  type        = string
}

variable "os_type" {
  description = "Operating System type for the App Service Plan"
  type        = string
}

variable "zone_balancing_enabled" {
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
variable "always_on" {
  description = "Enable Always On for App Service (not supported on Free/Shared tiers)"
  type        = bool
}

variable "identity" {
  description = "Managed Identity configuration"
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
}

variable "application_stack" {
  description = "Application stack configuration"
  type        = any
}

variable "app_settings" {
  description = "Application settings for the Web App"
  type        = map(string)
}
