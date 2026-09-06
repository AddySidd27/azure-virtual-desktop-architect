output "dc_private_ip" {
  description = "Static private IP of the centralus domain controller. Set as centralus's primary VNet DNS server and eastus2's secondary."
  value       = azurerm_network_interface.dc.private_ip_address
}

output "dc_vm_name" {
  description = "centralus domain controller VM name, used in az vm run-command"
  value       = azurerm_windows_virtual_machine.dc.name
}

output "deallocate_command" {
  description = "Run this at the end of every lab session to stop compute billing"
  value       = "az vm deallocate --resource-group ${data.terraform_remote_state.lab11_network.outputs.resource_group_names.identity} --name ${azurerm_windows_virtual_machine.dc.name}"
}
