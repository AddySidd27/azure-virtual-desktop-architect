############################################
# VNet peering - westus2 <-> eastus2 only
#
# No peering to centralus. This lab protects eastus2 specifically;
# centralus's own DR posture, if it needed one, would be a separate
# lab exercise with its own DR region, not bolted onto this one.
############################################

resource "azurerm_virtual_network_peering" "westus2_to_eastus2" {
  name                         = "peer-wus2-to-eus2"
  resource_group_name          = azurerm_resource_group.dr.name
  virtual_network_name         = azurerm_virtual_network.dr.name
  remote_virtual_network_id    = data.terraform_remote_state.lab03_network.outputs.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "eastus2_to_westus2" {
  name                         = "peer-eus2-to-wus2"
  resource_group_name          = data.terraform_remote_state.lab03_network.outputs.resource_group_name
  virtual_network_name         = data.terraform_remote_state.lab03_network.outputs.vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.dr.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
