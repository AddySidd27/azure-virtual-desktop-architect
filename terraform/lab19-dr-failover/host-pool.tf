############################################
# DR host pool - westus2
#
# Standard host-pool management, matching Lab 14's reasoning (see the
# ADR). Genuinely separate from Lab 14's active-active pools: this
# module lives in its own Terraform directory, not a flag inside
# lab14-active-active-hostpools, so the two patterns stay comparable
# side by side rather than merged into one confusing option set.
############################################

resource "azurerm_virtual_desktop_host_pool" "dr" {
  name                     = "hp-avd-dr-${local.suffix}"
  location                 = var.location
  resource_group_name      = azurerm_resource_group.dr.name
  type                     = "Pooled"
  load_balancer_type       = "BreadthFirst"
  maximum_sessions_allowed = 8
  preferred_app_group_type = "Desktop"
  start_vm_on_connect      = true
  validate_environment     = true

  tags = local.common_tags
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "dr" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.dr.id
  expiration_date = timeadd(timestamp(), "24h")

  lifecycle {
    ignore_changes = [expiration_date]
  }
}

############################################
# Application group - attached to the EXISTING eastus2 workspace
#
# Unlike Lab 14, this lab does NOT create a new workspace. Microsoft's
# documented active-passive user experience has no duplicate feed: a
# failed-over user's desktop entry is the same one they always had,
# now pointing at DR infrastructure, not a second, DR-labelled entry
# they'd need to learn to recognise only during an actual incident.
############################################

resource "azurerm_virtual_desktop_application_group" "dr_desktop" {
  name                = "ag-desktop-dr-${local.suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.dr.name
  host_pool_id        = azurerm_virtual_desktop_host_pool.dr.id
  type                = "Desktop"
  friendly_name       = "DR Desktop (East US 2 Failover Target)"
  tags                = local.common_tags
}

# Deliberately NOT associated with the eastus2 workspace at apply time.
# The failover runbook (Lab 19's PowerShell) performs this association
# only when a DR event is actually declared - keeping it disconnected
# by default is what prevents a user from ever seeing this pool
# during normal operation, matching the "DR requires deliberate admin
# action" principle this lab is built around.
