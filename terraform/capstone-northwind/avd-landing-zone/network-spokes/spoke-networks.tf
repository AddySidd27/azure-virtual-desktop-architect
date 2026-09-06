locals {
  common_tags = {
    BusinessUnit       = "Northwind"
    Environment        = var.environment
    CostCentre         = var.cost_centre
    DataClassification = "AVD-Landing-Zone"
    Owner              = var.owner
  }
}

resource "azurerm_resource_group" "eastus2" {
  name     = "rg-avd-network-${var.environment}-eus2-01"
  location = "eastus2"
  tags     = local.common_tags
}

resource "azurerm_resource_group" "westeurope" {
  name     = "rg-avd-network-${var.environment}-weu-01"
  location = "westeurope"
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "eastus2_avd" {
  name                = "vnet-avd-${var.environment}-eus2-01"
  location            = azurerm_resource_group.eastus2.location
  resource_group_name = azurerm_resource_group.eastus2.name
  address_space       = var.eastus2_avd_address_space
  tags                = local.common_tags
}

resource "azurerm_virtual_network" "westeurope_avd" {
  name                = "vnet-avd-${var.environment}-weu-01"
  location            = azurerm_resource_group.westeurope.location
  resource_group_name = azurerm_resource_group.westeurope.name
  address_space       = var.westeurope_avd_address_space
  tags                = local.common_tags
}

resource "azurerm_subnet" "eastus2_avd_hosts" {
  name                 = "snet-avd-hosts-${var.environment}-eus2-01"
  resource_group_name  = azurerm_resource_group.eastus2.name
  virtual_network_name = azurerm_virtual_network.eastus2_avd.name
  address_prefixes     = ["10.120.0.0/23"]
}

resource "azurerm_subnet" "westeurope_avd_hosts" {
  name                 = "snet-avd-hosts-${var.environment}-weu-01"
  resource_group_name  = azurerm_resource_group.westeurope.name
  virtual_network_name = azurerm_virtual_network.westeurope_avd.name
  address_prefixes     = ["10.121.0.0/23"]
}

############################################
# Spoke-to-hub peering, same pattern as platform/identity
############################################

resource "azurerm_virtual_network_peering" "eastus2_avd_to_hub" {
  name                         = "peer-avd-eus2-to-hub"
  resource_group_name          = azurerm_resource_group.eastus2.name
  virtual_network_name         = azurerm_virtual_network.eastus2_avd.name
  remote_virtual_network_id    = local.eastus2_hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true
}

resource "azurerm_virtual_network_peering" "eastus2_hub_to_avd" {
  name                         = "peer-hub-to-avd-eus2"
  resource_group_name          = local.eastus2_hub_resource_group
  virtual_network_name         = local.eastus2_hub_vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.eastus2_avd.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "westeurope_avd_to_hub" {
  name                         = "peer-avd-weu-to-hub"
  resource_group_name          = azurerm_resource_group.westeurope.name
  virtual_network_name         = azurerm_virtual_network.westeurope_avd.name
  remote_virtual_network_id    = local.westeurope_hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true
}

resource "azurerm_virtual_network_peering" "westeurope_hub_to_avd" {
  name                         = "peer-hub-to-avd-weu"
  resource_group_name          = local.westeurope_hub_resource_group
  virtual_network_name         = local.westeurope_hub_vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.westeurope_avd.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}
