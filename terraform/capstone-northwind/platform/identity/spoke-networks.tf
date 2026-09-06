############################################
# Resource groups and spoke VNets
#
# Domain controllers sit in their own spoke, peered to the regional
# hub - not inside the hub VNet itself, which is reserved for the
# gateway and firewall subnets built in the connectivity module.
############################################

resource "azurerm_resource_group" "eastus2" {
  name     = "rg-identity-${var.environment}-eus2-01"
  location = "eastus2"
  tags     = local.common_tags
}

resource "azurerm_resource_group" "westeurope" {
  name     = "rg-identity-${var.environment}-weu-01"
  location = "westeurope"
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "eastus2_spoke" {
  name                = "vnet-identity-${var.environment}-eus2-01"
  location            = azurerm_resource_group.eastus2.location
  resource_group_name = azurerm_resource_group.eastus2.name
  address_space       = var.eastus2_spoke_address_space
  tags                = local.common_tags
}

resource "azurerm_virtual_network" "westeurope_spoke" {
  name                = "vnet-identity-${var.environment}-weu-01"
  location            = azurerm_resource_group.westeurope.location
  resource_group_name = azurerm_resource_group.westeurope.name
  address_space       = var.westeurope_spoke_address_space
  tags                = local.common_tags
}

resource "azurerm_subnet" "eastus2_dc" {
  name                 = "snet-dc-${var.environment}-eus2-01"
  resource_group_name  = azurerm_resource_group.eastus2.name
  virtual_network_name = azurerm_virtual_network.eastus2_spoke.name
  address_prefixes     = ["10.110.0.0/26"]
}

resource "azurerm_subnet" "westeurope_dc" {
  name                 = "snet-dc-${var.environment}-weu-01"
  resource_group_name  = azurerm_resource_group.westeurope.name
  virtual_network_name = azurerm_virtual_network.westeurope_spoke.name
  address_prefixes     = ["10.111.0.0/26"]
}

############################################
# Spoke-to-hub peering
############################################

resource "azurerm_virtual_network_peering" "eastus2_spoke_to_hub" {
  name                         = "peer-identity-eus2-to-hub"
  resource_group_name          = azurerm_resource_group.eastus2.name
  virtual_network_name         = azurerm_virtual_network.eastus2_spoke.name
  remote_virtual_network_id    = var.eastus2_hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true # spoke uses the hub's ExpressRoute gateway
}

resource "azurerm_virtual_network_peering" "eastus2_hub_to_spoke" {
  name                         = "peer-hub-to-identity-eus2"
  resource_group_name          = var.eastus2_hub_resource_group
  virtual_network_name         = var.eastus2_hub_vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.eastus2_spoke.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "westeurope_spoke_to_hub" {
  name                         = "peer-identity-weu-to-hub"
  resource_group_name          = azurerm_resource_group.westeurope.name
  virtual_network_name         = azurerm_virtual_network.westeurope_spoke.name
  remote_virtual_network_id    = var.westeurope_hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true
}

resource "azurerm_virtual_network_peering" "westeurope_hub_to_spoke" {
  name                         = "peer-hub-to-identity-weu"
  resource_group_name          = var.westeurope_hub_resource_group
  virtual_network_name         = var.westeurope_hub_vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.westeurope_spoke.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

############################################
# NSGs - identity subnets
############################################

resource "azurerm_network_security_group" "eastus2_dc" {
  name                = "nsg-dc-${var.environment}-eus2-01"
  location            = azurerm_resource_group.eastus2.location
  resource_group_name = azurerm_resource_group.eastus2.name
  tags                = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "eastus2_dc" {
  subnet_id                 = azurerm_subnet.eastus2_dc.id
  network_security_group_id = azurerm_network_security_group.eastus2_dc.id
}

# AD replication from the other region's identity spoke specifically,
# not the whole hub range - matches the principle already established
# in Lab 11's equivalent rule, scoped to what actually replicates.
resource "azurerm_network_security_rule" "eastus2_dc_replication_from_westeurope" {
  name                        = "Allow-AD-Replication-From-WestEurope"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.westeurope_spoke_address_space[0]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.eastus2.name
  network_security_group_name = azurerm_network_security_group.eastus2_dc.name
}

resource "azurerm_network_security_group" "westeurope_dc" {
  name                = "nsg-dc-${var.environment}-weu-01"
  location            = azurerm_resource_group.westeurope.location
  resource_group_name = azurerm_resource_group.westeurope.name
  tags                = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "westeurope_dc" {
  subnet_id                 = azurerm_subnet.westeurope_dc.id
  network_security_group_id = azurerm_network_security_group.westeurope_dc.id
}

resource "azurerm_network_security_rule" "westeurope_dc_replication_from_eastus2" {
  name                        = "Allow-AD-Replication-From-Eastus2"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.eastus2_spoke_address_space[0]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.westeurope.name
  network_security_group_name = azurerm_network_security_group.westeurope_dc.name
}

############################################
# UDRs - route egress through the regional hub's Azure Firewall
#
# This is the spoke-side half of Part C section 5's Firewall
# decision. The hub module builds the Firewall; this module, as the
# actual spoke, is where routing traffic to it belongs.
############################################

resource "azurerm_route_table" "eastus2" {
  name                = "rt-identity-${var.environment}-eus2-01"
  location            = azurerm_resource_group.eastus2.location
  resource_group_name = azurerm_resource_group.eastus2.name
  tags                = local.common_tags

  route {
    name                   = "default-via-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.eastus2_firewall_private_ip
  }
}

resource "azurerm_subnet_route_table_association" "eastus2_dc" {
  subnet_id      = azurerm_subnet.eastus2_dc.id
  route_table_id = azurerm_route_table.eastus2.id
}

resource "azurerm_route_table" "westeurope" {
  name                = "rt-identity-${var.environment}-weu-01"
  location            = azurerm_resource_group.westeurope.location
  resource_group_name = azurerm_resource_group.westeurope.name
  tags                = local.common_tags

  route {
    name                   = "default-via-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.westeurope_firewall_private_ip
  }
}

resource "azurerm_subnet_route_table_association" "westeurope_dc" {
  subnet_id      = azurerm_subnet.westeurope_dc.id
  route_table_id = azurerm_route_table.westeurope.id
}
