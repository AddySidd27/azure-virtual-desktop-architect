############################################
# Host pool - centralus
#
# Standard host-pool management, matching Lab 7 exactly. NOT Session
# Host Configuration / Automated Host Pool. See the ADR:
# appendices/adr-shc-vs-standard-host-pools.md for why - no stable
# Terraform resource exists for SHC as of this writing.
############################################

resource "azurerm_virtual_desktop_host_pool" "centralus" {
  name                     = "hp-avd-${local.suffix}"
  location                 = var.location
  resource_group_name      = data.terraform_remote_state.lab11_network.outputs.resource_group_names.avd
  type                     = "Pooled"
  load_balancer_type       = "BreadthFirst"
  maximum_sessions_allowed = var.max_session_limit
  preferred_app_group_type = "Desktop"
  start_vm_on_connect      = true
  validate_environment     = true

  tags = local.common_tags
}

# Registration token, short lived deliberately, matching Lab 7's reasoning.
resource "azurerm_virtual_desktop_host_pool_registration_info" "centralus" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.centralus.id
  expiration_date = timeadd(timestamp(), "24h")

  lifecycle {
    ignore_changes = [expiration_date]
  }
}
