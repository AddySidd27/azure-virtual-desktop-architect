############################################
# One independent scaling plan PER PERSONA, not one combined plan
# per region with three host-pool associations - matching the master
# plan's "six independent scaling plans" exactly, and Lab 17's proven
# resource shape. Standard Power Management Autoscale throughout -
# the same SHC/Dynamic Autoscaling reconciliation as Part F8: no
# Dynamic Autoscaling dependency, since that requires Session Host
# Configuration, which the existing ADR rules out.
############################################

resource "azurerm_virtual_desktop_scaling_plan" "persona" {
  for_each = local.pooled_host_pool_ids

  name                = "sp-${each.key}-${var.environment}-${var.location_short}-01"
  location            = var.location
  resource_group_name = local.avd_resource_group
  friendly_name       = "${each.key} autoscale - ${var.location}"
  time_zone           = var.time_zone
  host_pool_type      = "Pooled"

  schedule {
    name                               = "weekdays"
    days_of_week                       = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    ramp_up_start_time                 = local.schedule.ramp_up_time
    ramp_up_load_balancing_algorithm   = "BreadthFirst"
    ramp_up_minimum_hosts_percent      = local.schedule.ramp_up_min_percent
    ramp_up_capacity_threshold_percent = local.schedule.ramp_up_threshold_percent

    peak_start_time               = local.schedule.peak_time
    peak_load_balancing_algorithm = "BreadthFirst"

    ramp_down_start_time                 = local.schedule.ramp_down_time
    ramp_down_load_balancing_algorithm   = "DepthFirst"
    ramp_down_minimum_hosts_percent      = local.schedule.ramp_down_min_percent
    ramp_down_wait_time_minutes          = local.schedule.ramp_down_wait_minutes
    ramp_down_force_logoff_users         = false
    ramp_down_capacity_threshold_percent = local.schedule.ramp_up_threshold_percent

    off_peak_start_time               = local.schedule.off_peak_time
    off_peak_load_balancing_algorithm = "DepthFirst"
  }

  host_pool_association {
    hostpool_id          = each.value
    scaling_plan_enabled = true
  }
}
