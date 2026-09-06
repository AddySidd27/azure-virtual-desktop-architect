resource "azurerm_virtual_desktop_host_pool" "lab" {
  name                     = "hp-avd-${local.suffix}"
  location                 = var.location
  resource_group_name      = data.azurerm_resource_group.service.name
  type                     = "Pooled"
  load_balancer_type       = "BreadthFirst"
  maximum_sessions_allowed = var.max_session_limit
  preferred_app_group_type = "Desktop" # locked at creation; see ch03 for why this cannot be changed safely later
  start_vm_on_connect      = true
  validate_environment     = true # keep true for lab work; disables the "friendly name" safety net that hides real errors

  tags = local.common_tags
}

# Registration token, short lived deliberately. Regenerate rather than
# storing a long-lived token anywhere, per ch18's registration guidance.
resource "azurerm_virtual_desktop_host_pool_registration_info" "lab" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.lab.id
  expiration_date = timeadd(timestamp(), "24h")

  lifecycle {
    ignore_changes = [expiration_date] # prevents a diff on every plan; regenerate explicitly with -replace when needed
  }
}
