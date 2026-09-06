output "session_host_names" {
  value = azurerm_windows_virtual_machine.host[*].name
}

output "session_host_computer_names" {
  description = "Windows computer names, 15 character limit, distinct from the Azure resource name"
  value       = azurerm_windows_virtual_machine.host[*].computer_name
}

output "deallocate_all_command" {
  description = "Run at the end of every lab session to stop compute billing"
  value       = "az vm deallocate --ids $(az vm list -g ${var.hosts_resource_group_name} --query \"[].id\" -o tsv)"
}
