output "vnet_id" {
  description = "Resource ID of the AVD lab virtual network"
  value       = azurerm_virtual_network.avd.id
}

output "vnet_name" {
  description = "Name of the AVD lab virtual network"
  value       = azurerm_virtual_network.avd.name
}

output "resource_group_name" {
  description = "Resource group holding the network resources. Added for Lab 11 (multi-region peering), which needs this to create the eastus2 side of the VNet peering without hard-coding the name."
  value       = data.azurerm_resource_group.network.name
}

output "subnet_ids" {
  description = "Subnet resource IDs consumed by later labs"
  value = {
    identity = azurerm_subnet.identity.id
    hosts    = azurerm_subnet.hosts.id
    storage  = azurerm_subnet.storage.id
    mgmt     = azurerm_subnet.mgmt.id
  }
}

output "nsg_ids" {
  description = "Network security group resource IDs"
  value = {
    hosts    = azurerm_network_security_group.hosts.id
    identity = azurerm_network_security_group.identity.id
    storage  = azurerm_network_security_group.storage.id
  }
}
