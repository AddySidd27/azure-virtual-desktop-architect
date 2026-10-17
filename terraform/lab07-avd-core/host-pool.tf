resource "azurerm_virtual_desktop_host_pool" "lab" {
  name                     = "hp-avd-${local.suffix}"
  location                 = var.location
  resource_group_name      = data.azurerm_resource_group.service.name
  type                     = "Pooled"
  load_balancer_type       = "BreadthFirst"
  maximum_sessions_allowed = var.max_session_limit
  preferred_app_group_type = "Desktop" # locked at creation; see ch03 for why this cannot be changed safely later
  # Start VM on Connect also needs the "Desktop Virtualization Power On
  # Contributor" role assigned to the AVD service principal (or the host pool's
  # managed identity) at a scope containing the session hosts. This module does
  # NOT create that assignment, so until it is made manually the setting has no
  # effect and a deallocated host will not start on sign-in (Lab 7 Step 2b).
  # Learn also says the setting cannot be enabled while creating a host pool in
  # the portal; whether the ARM/provider create path accepts it is untested.
  start_vm_on_connect = true
  # Validation environment: the host pool receives AVD service updates before
  # standard pools. Learn recommends it for test pools only, not production.
  validate_environment = true

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
