############################################
# Regional AVD-specific Log Analytics workspace - Part H1.
#
# ADDITIONAL to platform/monitoring's tenant-wide workspace (Part B
# section 2.8), not a replacement for it. Two different purposes,
# stated explicitly rather than left to look like duplication:
#   - platform/monitoring: tenant-wide compliance/audit baseline,
#     already receiving each host pool's diagnostics per Part F's
#     own deliberate choice (Part F, section 12).
#   - This workspace: AVD-specific operational monitoring (AVD
#     Insights-style session/connection health, autoscaling logs
#     from H4), scoped per region, matching the exact "don't share
#     monitoring across independently-important components"
#     reasoning already applied consistently since Labs 11-20.
#
# Host pool diagnostics are NOT rewired away from the platform
# workspace - a SECOND diagnostic setting is added below, additive,
# not a migration.
############################################

locals {
  common_tags = {
    BusinessUnit = "Northwind"
    Environment  = var.environment
    Region       = var.location
    CostCentre   = var.cost_centre
    Owner        = var.owner
  }
}

resource "azurerm_resource_group" "monitoring" {
  name     = "rg-avd-monitoring-${var.environment}-${var.location_short}-01"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_log_analytics_workspace" "avd_regional" {
  name                = "log-avd-northwind-${var.environment}-${var.location_short}-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.monitoring.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days

  tags = local.common_tags
}

############################################
# Second diagnostic setting per host pool - additive to Part F's
# existing one (which points at the platform workspace). Azure
# permits multiple diagnostic settings per resource
# ([VERIFY BEFORE IMPLEMENTATION] confirm the current per-resource
# limit against Microsoft Learn before assuming this scales past a
# handful of destinations), so this does not conflict with or
# require touching Part F's host-pools module at all.
############################################

resource "azurerm_monitor_diagnostic_setting" "hostpool_avd_regional" {
  for_each = local.host_pool_ids

  name                       = "diag-hostpool-avdinsights"
  target_resource_id         = each.value
  log_analytics_workspace_id = azurerm_log_analytics_workspace.avd_regional.id

  enabled_log { category = "Checkpoint" }
  enabled_log { category = "Error" }
  enabled_log { category = "Management" }
  enabled_log { category = "Connection" }
  enabled_log { category = "HostRegistration" }
  enabled_log { category = "AgentHealthStatus" }
  enabled_log { category = "NetworkData" }
  enabled_log { category = "SessionHostManagement" }
}

# Confirmed against multiple independent sources, including real
# published Terraform using this identical category set, that
# Checkpoint/Error/Management/Connection/HostRegistration/
# AgentHealthStatus/NetworkData/SessionHostManagement are genuine,
# current AVD diagnostic categories. [VERIFY BEFORE
# IMPLEMENTATION] whether this is the complete, currently-recommended
# set for AVD Insights specifically (one source additionally used
# ConnectionGraphicsData) - confirm against Microsoft Learn's current
# AVD Insights configuration guidance before assuming this list is
# exhaustive.
