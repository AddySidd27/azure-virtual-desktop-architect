resource "azurerm_log_analytics_workspace" "avd" {
  name                = "log-avd-${local.suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.monitoring.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = local.common_tags
}

# Diagnostic settings on the host pool. This is the opt-in step Chapter 2
# and Project 02 both flag as the single most common monitoring gap in AVD
# estates: nothing arrives until this resource exists.
resource "azurerm_monitor_diagnostic_setting" "hostpool" {
  name                       = "diag-hostpool"
  target_resource_id         = data.azurerm_virtual_desktop_host_pool.lab.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.avd.id

  enabled_log { category = "Checkpoint" }
  enabled_log { category = "Error" }
  enabled_log { category = "Management" }
  enabled_log { category = "Connection" }
  enabled_log { category = "HostRegistration" }
}
