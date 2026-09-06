output "dc_private_ip" {
  description = "Static private IP of the domain controller. Set this as the VNet DNS server."
  value       = azurerm_network_interface.dc.private_ip_address
}

output "dc_vm_name" {
  description = "Domain controller VM name, used in az vm run-command"
  value       = azurerm_windows_virtual_machine.dc.name
}

output "deallocate_command" {
  description = "Run this at the end of every lab session to stop compute billing"
  value       = "az vm deallocate --resource-group ${var.identity_resource_group_name} --name ${azurerm_windows_virtual_machine.dc.name}"
}
