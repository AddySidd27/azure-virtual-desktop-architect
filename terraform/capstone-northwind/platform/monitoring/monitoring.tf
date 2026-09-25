locals {
  common_tags = {
    BusinessUnit       = "Northwind"
    Environment        = var.environment
    CostCentre         = var.cost_centre
    DataClassification = "Platform-Monitoring"
    Owner              = var.owner
  }
}

resource "azurerm_resource_group" "monitoring" {
  name     = "rg-monitoring-${var.environment}-eus2-01"
  location = "eastus2"
  tags     = local.common_tags
}

############################################
# Tenant-wide Log Analytics workspace, shared across the platform
# and AVD-specific monitoring modules.
############################################

resource "azurerm_log_analytics_workspace" "platform" {
  name                = "log-northwind-platform-${var.environment}"
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days

  tags = local.common_tags
}

############################################
# The diagnostic-settings policy assignment from Part B (section 2.5)
# could not actually reach a target workspace until now - this is
# what makes that policy's DeployIfNotExists effect functional rather
# than pointed at nothing.
#
# [VERIFY BEFORE IMPLEMENTATION] this module does not itself re-create
# the policy assignment from terraform/capstone-northwind/platform/policy/
# - it exposes the workspace ID as an output, which that module's
# variable (log_analytics_workspace_id) should now be set to. Apply
# the policy module again with this module's output once both exist.
############################################
