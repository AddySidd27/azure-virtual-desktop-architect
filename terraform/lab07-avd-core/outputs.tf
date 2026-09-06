output "host_pool_name" {
  value = azurerm_virtual_desktop_host_pool.lab.name
}

output "host_pool_id" {
  description = "Resource ID of the host pool. Added for Lab 17 (regional autoscaling), which needs this to attach a scaling plan without hard-coding the ID."
  value       = azurerm_virtual_desktop_host_pool.lab.id
}

output "workspace_name" {
  value = azurerm_virtual_desktop_workspace.lab.name
}

output "application_group_name" {
  value = azurerm_virtual_desktop_application_group.desktop.name
}

output "application_group_id" {
  description = "Resource ID of the desktop application group. Added for Lab 16 (region assignment), which needs this to scope role assignments without hard-coding the ID."
  value       = azurerm_virtual_desktop_application_group.desktop.id
}

output "registration_token" {
  description = "24-hour registration token consumed in Lab 8. Do not commit this value or paste it into a chat/issue."
  value       = azurerm_virtual_desktop_host_pool_registration_info.lab.token
  sensitive   = true
}
