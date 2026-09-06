############################################
# Resource groups
############################################

resource "azurerm_resource_group" "eastus2" {
  name     = "rg-connectivity-${var.environment}-eus2-01"
  location = "eastus2"
  tags     = local.common_tags
}

resource "azurerm_resource_group" "westeurope" {
  name     = "rg-connectivity-${var.environment}-weu-01"
  location = "westeurope"
  tags     = local.common_tags
}

############################################
# Hub VNets - one per region, per Part C section 2
############################################

resource "azurerm_virtual_network" "eastus2_hub" {
  name                = "vnet-hub-${var.environment}-eus2-01"
  location            = azurerm_resource_group.eastus2.location
  resource_group_name = azurerm_resource_group.eastus2.name
  address_space       = var.eastus2_hub_address_space
  tags                = local.common_tags
}

resource "azurerm_virtual_network" "westeurope_hub" {
  name                = "vnet-hub-${var.environment}-weu-01"
  location            = azurerm_resource_group.westeurope.location
  resource_group_name = azurerm_resource_group.westeurope.name
  address_space       = var.westeurope_hub_address_space
  tags                = local.common_tags
}

############################################
# Subnets - GatewaySubnet and AzureFirewallSubnet names are
# fixed by Azure and cannot be changed.
############################################

resource "azurerm_subnet" "eastus2_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.eastus2.name
  virtual_network_name = azurerm_virtual_network.eastus2_hub.name
  address_prefixes     = ["10.100.0.0/26"]
}

resource "azurerm_subnet" "eastus2_firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.eastus2.name
  virtual_network_name = azurerm_virtual_network.eastus2_hub.name
  address_prefixes     = ["10.100.1.0/26"]
}

resource "azurerm_subnet" "westeurope_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.westeurope.name
  virtual_network_name = azurerm_virtual_network.westeurope_hub.name
  address_prefixes     = ["10.101.0.0/26"]
}

resource "azurerm_subnet" "westeurope_firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.westeurope.name
  virtual_network_name = azurerm_virtual_network.westeurope_hub.name
  address_prefixes     = ["10.101.1.0/26"]
}
