############################################
# Log Analytics workspace - centralus
#
# A SEPARATE workspace, not shared with eastus2's (Lab 10). Same
# reasoning as Lab 16's non-overlapping groups and Lab 17's independent
# scaling plans: a shared monitoring workspace would be a single
# component whose failure or misconfiguration could affect visibility
# into both regions at once, undermining the independence this whole
# design is built around.
############################################

resource "azurerm_log_analytics_workspace" "centralus" {
  name                = "log-avd-${local.suffix}"
  location            = var.location
  resource_group_name = data.terraform_remote_state.lab11_network.outputs.resource_group_names.monitoring
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = local.common_tags
}

resource "azurerm_monitor_diagnostic_setting" "centralus_hostpool" {
  name                       = "diag-hostpool"
  target_resource_id         = data.terraform_remote_state.lab14_hostpools.outputs.host_pool_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.centralus.id

  enabled_log { category = "Checkpoint" }
  enabled_log { category = "Error" }
  enabled_log { category = "Management" }
  enabled_log { category = "Connection" }
  enabled_log { category = "HostRegistration" }
}
