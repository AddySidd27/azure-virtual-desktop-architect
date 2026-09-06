############################################
# Scaling plan - eastus2
#
# Power Management Autoscale, required implementation for this book
# (see the ADR). This REPLACES the single-region plan Lab 10 built:
# Lab 10's plan assumed one region; this lab's eastus2 plan is scoped
# more tightly (business-hours pattern for the East Coast/Central time
# user population) and lives alongside a genuinely independent
# centralus plan, rather than being the only scaling plan in the
# environment.
############################################

resource "azurerm_virtual_desktop_scaling_plan" "eastus2" {
  name                = "sp-avd-lab-eus2-01"
  location            = "eastus2"
  resource_group_name = data.azurerm_resource_group.eastus2_service.name
  friendly_name       = "East US 2 regional scaling plan"
  time_zone           = "Eastern Standard Time"
  host_pool_type      = "Pooled"

  schedule {
    name                               = "weekday"
    days_of_week                       = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    ramp_up_start_time                 = "07:00"
    ramp_up_load_balancing_algorithm   = "BreadthFirst"
    ramp_up_minimum_hosts_percent      = 50
    ramp_up_capacity_threshold_percent = 80

    peak_start_time               = "09:00"
    peak_load_balancing_algorithm = "BreadthFirst"

    ramp_down_start_time                 = "18:00"
    ramp_down_load_balancing_algorithm   = "DepthFirst"
    ramp_down_minimum_hosts_percent      = 10
    ramp_down_capacity_threshold_percent = 80
    ramp_down_force_logoff_users         = false
    ramp_down_wait_time_minutes          = 30
    ramp_down_notification_message       = "This session host is scaling down for East US 2's off-peak window. Please save your work."

    off_peak_start_time               = "20:00"
    off_peak_load_balancing_algorithm = "DepthFirst"
  }

  host_pool_association {
    hostpool_id          = data.terraform_remote_state.lab07_avd_core.outputs.host_pool_id
    scaling_plan_enabled = true
  }

  tags = local.common_tags
}
