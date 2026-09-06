############################################
# VNet peering - eastus2 <-> centralus
#
# Peering is not transitive and is not automatically bidirectional.
# Each side needs its own peering resource, created in that side's own
# subscription/region context. The centralus side is created here; the
# eastus2 side is created here too, using the remote-state VNet ID from
# Lab 3, since Lab 3's own state is not being modified by this lab.
############################################

resource "azurerm_virtual_network_peering" "centralus_to_eastus2" {
  name                         = "peer-cus-to-eus2"
  resource_group_name          = azurerm_resource_group.network.name
  virtual_network_name         = azurerm_virtual_network.avd.name
  remote_virtual_network_id    = data.terraform_remote_state.lab03_network.outputs.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "eastus2_to_centralus" {
  name                         = "peer-eus2-to-cus"
  resource_group_name          = data.terraform_remote_state.lab03_network.outputs.resource_group_name
  virtual_network_name         = data.terraform_remote_state.lab03_network.outputs.vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.avd.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
