output "eastus2_avd_vnet_id" {
  value = azurerm_virtual_network.eastus2_avd.id
}

output "westeurope_avd_vnet_id" {
  value = azurerm_virtual_network.westeurope_avd.id
}

output "eastus2_avd_resource_group" {
  value = azurerm_resource_group.eastus2.name
}

output "westeurope_avd_resource_group" {
  value = azurerm_resource_group.westeurope.name
}

output "eastus2_avd_hosts_subnet_id" {
  value = azurerm_subnet.eastus2_avd_hosts.id
}

output "westeurope_avd_hosts_subnet_id" {
  value = azurerm_subnet.westeurope_avd_hosts.id
}
