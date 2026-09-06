############################################
# Scaling plan - centralus
#
# A genuinely different schedule from eastus2, not a copy with the
# region name changed. Central time zone, and this lab assumes the
# centralus population skews toward a support/service-desk pattern
# with an earlier start and a longer ramp-down tail - deliberately
# different demand assumptions to make the point that active-active
# regions do not have to share a scaling story just because they
# share a Terraform module structure.
############################################

resource "azurerm_virtual_desktop_scaling_plan" "centralus" {
  name                = "sp-avd-lab-cus-01"
  location            = "centralus"
  resource_group_name = data.terraform_remote_state.lab11_network.outputs.resource_group_names.avd
  friendly_name       = "Central US regional scaling plan"
  time_zone           = "Central Standard Time"
  host_pool_type      = "Pooled"

  schedule {
    name                               = "weekday"
    days_of_week                       = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    ramp_up_start_time                 = "06:00"
    ramp_up_load_balancing_algorithm   = "BreadthFirst"
    ramp_up_minimum_hosts_percent      = 60
    ramp_up_capacity_threshold_percent = 75

    peak_start_time               = "08:00"
    peak_load_balancing_algorithm = "BreadthFirst"

    ramp_down_start_time                 = "17:00"
    ramp_down_load_balancing_algorithm   = "DepthFirst"
    ramp_down_minimum_hosts_percent      = 15
    ramp_down_capacity_threshold_percent = 75
    ramp_down_force_logoff_users         = false
    ramp_down_wait_time_minutes          = 45
    ramp_down_notification_message       = "This session host is scaling down for Central US's off-peak window. Please save your work."

    off_peak_start_time               = "21:00"
    off_peak_load_balancing_algorithm = "DepthFirst"
  }

  host_pool_association {
    hostpool_id          = data.terraform_remote_state.lab14_hostpools.outputs.host_pool_id
    scaling_plan_enabled = true
  }

  tags = local.common_tags
}
