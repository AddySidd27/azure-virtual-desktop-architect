############################################
# NSG - identity subnet (domain controller, Lab 12)
############################################

resource "azurerm_network_security_group" "identity" {
  name                = "nsg-identity-${local.suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "identity" {
  subnet_id                 = azurerm_subnet.identity.id
  network_security_group_id = azurerm_network_security_group.identity.id
}

resource "azurerm_network_security_rule" "identity_from_hosts" {
  name                        = "Allow-Domain-Services-From-Hosts"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.subnet_prefixes["hosts"]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.identity.name
}

# Cross-region domain replication: the eastus2 domain controller (Lab 4)
# must reach this centralus domain controller once Lab 12 promotes it,
# and vice versa. This rule allows the whole eastus2 VNet range, not just
# its identity subnet, because AD replication traffic can originate from
# either domain controller's own subnet depending on site topology.
resource "azurerm_network_security_rule" "identity_from_eastus2" {
  name                        = "Allow-AD-Replication-From-Eastus2"
  priority                    = 105
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.10.0.0/16"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.identity.name
}

# Added for Lab 19's correction: westus2's DR session hosts authenticate
# against this domain controller during an eastus2 outage, so they need
# a working path to it that does not itself depend on eastus2. This is
# client authentication traffic (Kerberos, LDAP, DNS), not DC-to-DC
# replication - westus2 has no domain controller of its own to
# replicate with, only DR session hosts that need to authenticate.
resource "azurerm_network_security_rule" "identity_from_westus2_dr" {
  name                        = "Allow-Auth-From-Westus2-DR"
  priority                    = 106
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.30.0.0/16"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.identity.name
}

resource "azurerm_network_security_rule" "identity_from_mgmt" {
  name                        = "Allow-Management-Access"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.subnet_prefixes["mgmt"]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.identity.name
}

resource "azurerm_network_security_rule" "identity_deny_inbound_internet" {
  name                        = "Deny-Inbound-From-Internet"
  priority                    = 4000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.identity.name
}

############################################
# NSG - storage subnet (private endpoints, Lab 13)
############################################

resource "azurerm_network_security_group" "storage" {
  name                = "nsg-storage-${local.suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "storage" {
  subnet_id                 = azurerm_subnet.storage.id
  network_security_group_id = azurerm_network_security_group.storage.id
}

resource "azurerm_network_security_rule" "storage_smb_from_hosts" {
  name                        = "Allow-SMB-From-Session-Hosts"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "445"
  source_address_prefix       = var.subnet_prefixes["hosts"]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.storage.name
}

resource "azurerm_network_security_rule" "storage_deny_inbound_internet" {
  name                        = "Deny-Inbound-From-Internet"
  priority                    = 4000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.storage.name
}
