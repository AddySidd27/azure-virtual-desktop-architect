############################################
# Hub-to-hub peering
#
# Direct peering, no shared transit component - Part C section 2's
# hub-and-spoke decision. Carries AD replication traffic (identity
# module) and future cross-region platform traffic.
############################################

resource "azurerm_virtual_network_peering" "eastus2_to_westeurope" {
  name                         = "peer-hub-eus2-to-weu"
  resource_group_name          = azurerm_resource_group.eastus2.name
  virtual_network_name         = azurerm_virtual_network.eastus2_hub.name
  remote_virtual_network_id    = azurerm_virtual_network.westeurope_hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "westeurope_to_eastus2" {
  name                         = "peer-hub-weu-to-eus2"
  resource_group_name          = azurerm_resource_group.westeurope.name
  virtual_network_name         = azurerm_virtual_network.westeurope_hub.name
  remote_virtual_network_id    = azurerm_virtual_network.eastus2_hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
