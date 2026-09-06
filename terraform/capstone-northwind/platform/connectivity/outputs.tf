output "eastus2_hub_vnet_id" {
  value = azurerm_virtual_network.eastus2_hub.id
}

output "westeurope_hub_vnet_id" {
  value = azurerm_virtual_network.westeurope_hub.id
}

output "eastus2_hub_vnet_name" {
  value = azurerm_virtual_network.eastus2_hub.name
}

output "westeurope_hub_vnet_name" {
  value = azurerm_virtual_network.westeurope_hub.name
}

output "eastus2_hub_resource_group" {
  value = azurerm_resource_group.eastus2.name
}

output "westeurope_hub_resource_group" {
  value = azurerm_resource_group.westeurope.name
}

output "eastus2_firewall_private_ip" {
  description = "Consumed by the identity module (and, later, Part E's AVD spokes) as the UDR next hop"
  value       = azurerm_firewall.eastus2.ip_configuration[0].private_ip_address
}

output "westeurope_firewall_private_ip" {
  value = azurerm_firewall.westeurope.ip_configuration[0].private_ip_address
}
