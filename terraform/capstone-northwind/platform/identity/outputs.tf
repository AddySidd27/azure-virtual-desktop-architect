output "eastus2_dc_private_ips" {
  value = azurerm_network_interface.eastus2_dc[*].private_ip_address
}

output "westeurope_dc_private_ips" {
  value = azurerm_network_interface.westeurope_dc[*].private_ip_address
}

output "eastus2_dc_vm_names" {
  value = azurerm_windows_virtual_machine.eastus2_dc[*].name
}

output "westeurope_dc_vm_names" {
  value = azurerm_windows_virtual_machine.westeurope_dc[*].name
}
