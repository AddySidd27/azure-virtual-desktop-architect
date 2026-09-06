output "vnet_id" {
  description = "Resource ID of the centralus AVD lab virtual network"
  value       = azurerm_virtual_network.avd.id
}

output "vnet_name" {
  description = "Name of the centralus AVD lab virtual network"
  value       = azurerm_virtual_network.avd.name
}

output "resource_group_names" {
  description = "centralus resource group names, mirroring Lab 2's eastus2 set"
  value = {
    network    = azurerm_resource_group.network.name
    identity   = azurerm_resource_group.identity.name
    storage    = azurerm_resource_group.storage.name
    avd        = azurerm_resource_group.avd.name
    hosts      = azurerm_resource_group.hosts.name
    monitoring = azurerm_resource_group.monitoring.name
  }
}

output "subnet_ids" {
  description = "centralus subnet resource IDs consumed by Labs 12-19"
  value = {
    identity = azurerm_subnet.identity.id
    hosts    = azurerm_subnet.hosts.id
    storage  = azurerm_subnet.storage.id
    mgmt     = azurerm_subnet.mgmt.id
  }
}

output "nsg_ids" {
  description = "centralus network security group resource IDs"
  value = {
    hosts    = azurerm_network_security_group.hosts.id
    identity = azurerm_network_security_group.identity.id
    storage  = azurerm_network_security_group.storage.id
  }
}

output "peering_status" {
  description = "Peering connection states, both directions. Both must read Connected before Lab 12 depends on cross-region reachability."
  value = {
    centralus_to_eastus2 = azurerm_virtual_network_peering.centralus_to_eastus2.peering_state
    eastus2_to_centralus = azurerm_virtual_network_peering.eastus2_to_centralus.peering_state
  }
}
