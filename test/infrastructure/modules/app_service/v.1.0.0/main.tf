# ===================================================================
# App Service Module
# Creates App Service Plan, Web App, and Auto-scaling
# ===================================================================

# App Service Plan with Zone Redundancy
resource "azurerm_service_plan" "main" {
  name                   = "${var.project_name}-appsvcplan-${var.environment}"
  location               = var.location
  resource_group_name    = var.resource_group_name
  os_type                = "Linux"
  sku_name               = var.sku_name
  zone_balancing_enabled = var.zone_balancing_enabled

  tags = var.tags
}

# Linux Web App
resource "azurerm_linux_web_app" "main" {
  name                = "${var.project_name}-appsvc-${var.environment}-${var.suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.main.id

  https_only = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on = var.always_on

    application_stack {
      node_version = "18-lts"
    }

    minimum_tls_version = "1.2"
    health_check_path   = "/health"
    http2_enabled       = true
  }

  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = var.app_insights_connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "WEBSITE_NODE_DEFAULT_VERSION"               = "~18"
    "SQL_SERVER"                                 = var.sql_server_fqdn
    "SQL_DATABASE"                               = var.sql_database_name
  }

  virtual_network_subnet_id = var.app_service_subnet_id

  tags = var.tags
}

# Auto-scaling
resource "azurerm_monitor_autoscale_setting" "main" {
  name                = "${var.project_name}-autoscale-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_service_plan.main.id

  profile {
    name = "default"

    capacity {
      default = var.autoscale_default_instances
      minimum = var.autoscale_min_instances
      maximum = var.autoscale_max_instances
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = var.autoscale_cpu_threshold_high
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = var.autoscale_cpu_threshold_low
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }

  tags = var.tags
}


