# Assignment happens on the application group, never on the host pool
# directly and never on individual users. See ch03.
resource "azurerm_role_assignment" "avd_users_desktop" {
  scope                = azurerm_virtual_desktop_application_group.desktop.id
  role_definition_name = "Desktop Virtualization User"
  principal_id         = var.avd_users_group_object_id
}
