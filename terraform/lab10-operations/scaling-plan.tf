# Minimal scaling plan: a single ramp-up/peak/ramp-down/off-peak cycle
# against the Lab 7/8 pool. Production sizing of thresholds is a measured
# decision (Chapter 15, Project 07); the lab uses conservative defaults
# that will not surprise a one-or-two-host lab pool.
resource "azurerm_virtual_desktop_scaling_plan" "lab" {
  name                = "sp-avd-${local.suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.service.name
  friendly_name       = "Lab scaling plan"
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
    ramp_down_notification_message       = "This lab session host is scaling down. Please save your work."

    off_peak_start_time               = "20:00"
    off_peak_load_balancing_algorithm = "DepthFirst"
  }

  host_pool_association {
    hostpool_id          = data.azurerm_virtual_desktop_host_pool.lab.id
    scaling_plan_enabled = true
  }

  tags = local.common_tags
}
