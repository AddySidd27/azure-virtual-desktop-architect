output "workspace_id" {
  value = azurerm_virtual_desktop_workspace.regional.id
}

output "application_group_ids" {
  value = { for k, v in azurerm_virtual_desktop_application_group.persona : k => v.id }
}
