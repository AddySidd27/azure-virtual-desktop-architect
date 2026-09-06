############################################
# Workspace and application group - centralus
#
# A SEPARATE workspace, not a shared one with eastus2. This is required
# by Microsoft's own active-active guidance: users see duplicate feed
# entries in this design, and separate, clearly-labelled workspaces are
# how that duplication stays legible rather than confusing.
# Source: Azure Architecture Center, azure-virtual-desktop-multi-region-bcdr.
############################################

resource "azurerm_virtual_desktop_workspace" "centralus" {
  name                = "ws-avdlab-${local.suffix}"
  location            = var.location
  resource_group_name = data.terraform_remote_state.lab11_network.outputs.resource_group_names.avd
  friendly_name       = "AVD Lab - Central US"
  description         = "Central US desktop feed. Distinct from the East US 2 workspace by design - see Lab 14."
  tags                = local.common_tags
}

resource "azurerm_virtual_desktop_application_group" "centralus_desktop" {
  name                = "ag-desktop-${local.suffix}"
  location            = var.location
  resource_group_name = data.terraform_remote_state.lab11_network.outputs.resource_group_names.avd
  host_pool_id        = azurerm_virtual_desktop_host_pool.centralus.id
  type                = "Desktop"
  friendly_name       = "Central US Desktop"
  tags                = local.common_tags
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "centralus" {
  workspace_id         = azurerm_virtual_desktop_workspace.centralus.id
  application_group_id = azurerm_virtual_desktop_application_group.centralus_desktop.id
}

# Assignment on the application group, never on the host pool directly and
# never on individual users, matching Lab 7's pattern and Chapter 3.
resource "azurerm_role_assignment" "avd_users_centralus_desktop" {
  scope                = azurerm_virtual_desktop_application_group.centralus_desktop.id
  role_definition_name = "Desktop Virtualization User"
  principal_id         = var.avd_users_group_object_id
}
