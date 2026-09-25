############################################
# Five host pools per region, one per persona, STANDARD host-pool
# management - per the existing ADR (adr-shc-vs-standard-host-pools.md)
# and the master plan's reconciliation (section 2.1 / Part F8): no
# stable Terraform resource exists for Session Host Configuration, so
# this design does not use it, exactly as Labs 14-20 already
# established for the lab environment. This is the same pattern,
# applied here for the first time in the capstone.
############################################

resource "azurerm_virtual_desktop_host_pool" "persona" {
  for_each = var.personas

  name                     = "hp-${each.key}-${var.environment}-${var.location_short}-01"
  location                 = var.location
  resource_group_name      = local.avd_resource_group
  type                     = each.value.type
  load_balancer_type       = each.value.type == "Pooled" ? "BreadthFirst" : "Persistent"           # Microsoft's Azure Verified Modules documentation and the Terraform Registry both state "Persistent should be used if the host pool type is Personal".
  maximum_sessions_allowed = each.value.type == "Pooled" ? each.value.max_sessions_per_host : null # Driven by users_per_host per persona in variables.tf rather than a single hardcoded value - see that file for the density assumptions. [VERIFY BEFORE IMPLEMENTATION] confirm the per-persona numbers against real usage data.
  preferred_app_group_type = "Desktop"
  start_vm_on_connect      = true
  validate_environment     = true

  tags = local.common_tags
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "persona" {
  for_each = var.personas

  hostpool_id     = azurerm_virtual_desktop_host_pool.persona[each.key].id
  expiration_date = timeadd(timestamp(), "24h")

  lifecycle {
    ignore_changes = [expiration_date]
  }
}

############################################
# Diagnostic settings, applied directly to each host pool, pointed at
# the tenant-wide monitoring workspace. This does NOT wait for the
# tenant-wide diagnostic-settings policy to be re-applied (a separate
# follow-up) - these resources get diagnostics from the moment
# they exist, independent of that policy's status.
############################################

resource "azurerm_monitor_diagnostic_setting" "persona_hostpool" {
  for_each = var.personas

  name                       = "diag-hostpool"
  target_resource_id         = azurerm_virtual_desktop_host_pool.persona[each.key].id
  log_analytics_workspace_id = local.monitoring_workspace_id

  enabled_log { category = "Checkpoint" }
  enabled_log { category = "Error" }
  enabled_log { category = "Management" }
  enabled_log { category = "Connection" }
  enabled_log { category = "HostRegistration" }
}
