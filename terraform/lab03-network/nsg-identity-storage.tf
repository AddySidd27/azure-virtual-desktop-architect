############################################
# NSG - identity subnet (domain controller, Lab 4)
############################################

resource "azurerm_network_security_group" "identity" {
  name                = "nsg-identity-${local.suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.network.name
  tags                = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "identity" {
  subnet_id                 = azurerm_subnet.identity.id
  network_security_group_id = azurerm_network_security_group.identity.id
}

# Domain services must be reachable from the session host subnet.
# Ports are deliberately broad for the lab; Chapter 13 covers tightening
# AD DS port ranges in production.
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
  resource_group_name         = data.azurerm_resource_group.network.name
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
  resource_group_name         = data.azurerm_resource_group.network.name
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
  resource_group_name         = data.azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.identity.name
}

############################################
# NSG - storage subnet (private endpoints, Lab 5)
############################################

resource "azurerm_network_security_group" "storage" {
  name                = "nsg-storage-${local.suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.network.name
  tags                = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "storage" {
  subnet_id                 = azurerm_subnet.storage.id
  network_security_group_id = azurerm_network_security_group.storage.id
}

# SMB 445 from session hosts for FSLogix profile containers (Lab 5 and 6)
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
  resource_group_name         = data.azurerm_resource_group.network.name
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
  resource_group_name         = data.azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.storage.name
}
