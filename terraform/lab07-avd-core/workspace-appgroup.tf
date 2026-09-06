resource "azurerm_virtual_desktop_workspace" "lab" {
  name                = "ws-avd-${local.suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.service.name
  friendly_name       = "AVD Lab Workspace"
  tags                = local.common_tags
}

resource "azurerm_virtual_desktop_application_group" "desktop" {
  name                = "ag-desktop-${local.suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.service.name
  host_pool_id        = azurerm_virtual_desktop_host_pool.lab.id
  type                = "Desktop"
  friendly_name       = "Lab Desktop"
  tags                = local.common_tags
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "lab" {
  workspace_id         = azurerm_virtual_desktop_workspace.lab.id
  application_group_id = azurerm_virtual_desktop_application_group.desktop.id
}
