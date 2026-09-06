############################################
# VNet peering - westus2 <-> centralus
#
# CORRECTION: added because the original design (westus2 peered only
# to eastus2) meant DR session hosts had no working identity path
# during an actual eastus2 outage - exactly the scenario this lab
# exists to survive. centralus (Lab 12) has its own independent,
# healthy domain controller, unaffected by an eastus2 failure. This
# peering is what makes that domain controller reachable from westus2.
############################################

resource "azurerm_virtual_network_peering" "westus2_to_centralus" {
  name                         = "peer-wus2-to-cus"
  resource_group_name          = azurerm_resource_group.dr.name
  virtual_network_name         = azurerm_virtual_network.dr.name
  remote_virtual_network_id    = data.terraform_remote_state.lab11_network.outputs.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "centralus_to_westus2" {
  name                         = "peer-cus-to-wus2"
  resource_group_name          = data.terraform_remote_state.lab11_network.outputs.resource_group_names.network
  virtual_network_name         = data.terraform_remote_state.lab11_network.outputs.vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.dr.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
