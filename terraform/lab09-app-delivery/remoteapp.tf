# The Lab 7 host pool was created with preferred_app_group_type = "Desktop".
# Per ch03/ch25, a RemoteApp group on a Desktop-preferred pool would be
# invisible to assigned users with no error. Rather than change that
# setting on a live pool (which Lab 7 explicitly warns against), this lab
# creates a second small host pool dedicated to RemoteApp, which is also
# the more realistic production pattern from Project 10.
resource "azurerm_virtual_desktop_host_pool" "remoteapp" {
  name                     = "hp-avd-remoteapp-${local.suffix}"
  location                 = var.location
  resource_group_name      = data.azurerm_resource_group.service.name
  type                     = "Pooled"
  load_balancer_type       = "BreadthFirst"
  maximum_sessions_allowed = 4
  preferred_app_group_type = "RemoteApp"
  start_vm_on_connect      = true
  tags                     = local.common_tags
}

resource "azurerm_virtual_desktop_application_group" "remoteapp" {
  name                = "ag-remoteapp-${local.suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.service.name
  host_pool_id        = azurerm_virtual_desktop_host_pool.remoteapp.id
  type                = "RemoteApp"
  friendly_name       = "Lab RemoteApp"
  tags                = local.common_tags
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "remoteapp" {
  workspace_id         = data.azurerm_virtual_desktop_workspace.lab.id
  application_group_id = azurerm_virtual_desktop_application_group.remoteapp.id
}

data "azurerm_virtual_desktop_workspace" "lab" {
  name                = "ws-avd-${local.suffix}"
  resource_group_name = data.azurerm_resource_group.service.name
}

resource "azurerm_role_assignment" "avd_users_remoteapp" {
  scope                = azurerm_virtual_desktop_application_group.remoteapp.id
  role_definition_name = "Desktop Virtualization User"
  principal_id         = var.avd_users_group_object_id
}

# Publish Notepad as the lab's example RemoteApp: universally present on
# every Windows image, so this resource applies cleanly with no dependency
# on an application actually being installed on a host, which real
# line-of-business apps would require (see ch25 for the App Attach and
# image-delivery alternatives that avoid this constraint).
resource "azurerm_virtual_desktop_application" "notepad" {
  name                         = "notepad"
  application_group_id         = azurerm_virtual_desktop_application_group.remoteapp.id
  friendly_name                = "Notepad (Lab RemoteApp example)"
  path                         = "C:\\Windows\\System32\\notepad.exe"
  command_line_argument_policy = "DoNotAllow"
  icon_path                    = "C:\\Windows\\System32\\notepad.exe"
  icon_index                   = 0
}
