output "host_pool_name" {
  description = "centralus host pool name"
  value       = azurerm_virtual_desktop_host_pool.centralus.name
}

output "host_pool_id" {
  description = "centralus host pool resource ID. Added for Lab 17 (regional autoscaling), which needs this to attach a scaling plan without hard-coding the ID."
  value       = azurerm_virtual_desktop_host_pool.centralus.id
}

output "workspace_name" {
  description = "centralus workspace name - distinct from the eastus2 workspace by design"
  value       = azurerm_virtual_desktop_workspace.centralus.name
}

output "application_group_name" {
  description = "centralus desktop application group name"
  value       = azurerm_virtual_desktop_application_group.centralus_desktop.name
}

output "application_group_id" {
  description = "centralus desktop application group resource ID, used in Lab 16's non-overlapping assignment design"
  value       = azurerm_virtual_desktop_application_group.centralus_desktop.id
}

output "session_host_names" {
  description = "centralus session host VM names"
  value       = azurerm_windows_virtual_machine.host[*].name
}
