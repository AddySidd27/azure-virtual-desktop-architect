############################################
# DR region network foundation
#
# westus2 has no prior lab presence, unlike centralus (Lab 11). This
# lab builds a minimal network here: one resource group, one VNet, one
# subnet, one NSG. This lab protects eastus2 specifically (Labs 1-10's
# original region), not centralus - centralus already has its own
# independent active-active design (Lab 14) and is not this lab's
# concern in the sense of being protected by it.
#
# CORRECTED: this lab peers to BOTH eastus2 and centralus, not eastus2
# alone. The original design peered only to eastus2, which meant DR
# session hosts had no working identity path during the exact scenario
# DR exists for: an eastus2 outage. westus2 now also peers to
# centralus, and DR session hosts' DNS server order lists centralus's
# domain controller (Lab 12, independently healthy during an eastus2
# outage) first, with eastus2's domain controller second. See the lab
# markdown's "Identity and networking during an eastus2 outage"
# section for the full reasoning. Peering itself has no standing
# hourly cost, only data transfer, so keeping both links permanently
# connected rather than conditionally creating them does not conflict
# with the warm-standby cost model.
############################################

resource "azurerm_resource_group" "dr" {
  name     = "rg-avd-dr-${local.suffix}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "dr" {
  name                = "vnet-avd-dr-${local.suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.dr.name
  address_space       = ["10.30.0.0/16"] # non-overlapping with eastus2 (10.10.0.0/16) and centralus (10.20.0.0/16)
  tags                = local.common_tags
}

resource "azurerm_subnet" "dr_hosts" {
  name                 = "snet-dr-hosts-${local.suffix}"
  resource_group_name  = azurerm_resource_group.dr.name
  virtual_network_name = azurerm_virtual_network.dr.name
  address_prefixes     = ["10.30.1.0/24"]
}

resource "azurerm_network_security_group" "dr_hosts" {
  name                = "nsg-dr-hosts-${local.suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.dr.name
  tags                = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "dr_hosts" {
  subnet_id                 = azurerm_subnet.dr_hosts.id
  network_security_group_id = azurerm_network_security_group.dr_hosts.id
}

# Same outbound allow-list Lab 3 and Lab 11 use - the AVD service
# requirements are identical regardless of which region a host sits in.
locals {
  dr_outbound_443 = {
    "Allow-AVD-Service-Traffic" = { priority = 100, tag = "WindowsVirtualDesktop" }
    "Allow-Azure-Monitor"       = { priority = 110, tag = "AzureMonitor" }
    "Allow-Azure-Cloud"         = { priority = 120, tag = "AzureCloud" }
    "Allow-Entra-ID"            = { priority = 125, tag = "AzureActiveDirectory" }
    "Allow-Front-Door"          = { priority = 130, tag = "AzureFrontDoor.Frontend" }
  }
}

resource "azurerm_network_security_rule" "dr_outbound_443" {
  for_each = local.dr_outbound_443

  name                        = each.key
  priority                    = each.value.priority
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = each.value.tag
  resource_group_name         = azurerm_resource_group.dr.name
  network_security_group_name = azurerm_network_security_group.dr_hosts.name
}

resource "azurerm_network_security_rule" "dr_deny_inbound_rdp" {
  name                        = "Deny-Inbound-RDP-From-Internet"
  priority                    = 4000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.dr.name
  network_security_group_name = azurerm_network_security_group.dr_hosts.name
}

# Relayed RDP connectivity over UDP. The WindowsVirtualDesktop service tag
# represents the current AVD endpoint range published by Microsoft.
resource "azurerm_network_security_rule" "dr_rdp_udp" {
  name                        = "Allow-AVD-Relayed-RDP-UDP"
  priority                    = 140
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "3478"
  source_address_prefix       = "*"
  destination_address_prefix  = "WindowsVirtualDesktop"
  resource_group_name         = azurerm_resource_group.dr.name
  network_security_group_name = azurerm_network_security_group.dr_hosts.name
}

# Windows activation. Microsoft lists the azkms.core.windows.net endpoint
# with the Internet service tag for TCP 1688.
resource "azurerm_network_security_rule" "dr_windows_activation" {
  name                        = "Allow-Windows-Activation-KMS"
  priority                    = 150
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1688"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  resource_group_name         = azurerm_resource_group.dr.name
  network_security_group_name = azurerm_network_security_group.dr_hosts.name
}

# Certificate validation endpoints include TCP 80 destinations without one
# common NSG service tag. Use an FQDN-aware firewall for tighter filtering.
resource "azurerm_network_security_rule" "dr_certificate_checks" {
  name                        = "Allow-Certificate-Checks-HTTP"
  priority                    = 160
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  resource_group_name         = azurerm_resource_group.dr.name
  network_security_group_name = azurerm_network_security_group.dr_hosts.name
}
