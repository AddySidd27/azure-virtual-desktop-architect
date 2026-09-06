############################################
# NSG - session hosts
#
# Outbound requirements are derived from the Microsoft required FQDN and
# endpoint list. See Chapter 4 section 3. NSGs match on service tags,
# ports and IP ranges - not FQDNs. FQDN-level filtering requires Azure
# Firewall or an NGFW (Chapter 13).
############################################

resource "azurerm_network_security_group" "hosts" {
  name                = "nsg-hosts-${local.suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.network.name
  tags                = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "hosts" {
  subnet_id                 = azurerm_subnet.hosts.id
  network_security_group_id = azurerm_network_security_group.hosts.id
}

locals {
  # Outbound TCP 443 rules driven by Azure service tags
  hosts_outbound_443 = {
    "Allow-AVD-Service-Traffic" = { priority = 100, tag = "WindowsVirtualDesktop" }
    "Allow-Azure-Monitor"       = { priority = 110, tag = "AzureMonitor" }
    "Allow-Azure-Cloud"         = { priority = 120, tag = "AzureCloud" }
    "Allow-Entra-ID"            = { priority = 125, tag = "AzureActiveDirectory" }
    "Allow-Front-Door"          = { priority = 130, tag = "AzureFrontDoor.Frontend" }
  }
}

resource "azurerm_network_security_rule" "hosts_outbound_443" {
  for_each = local.hosts_outbound_443

  name                        = each.key
  priority                    = each.value.priority
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = each.value.tag
  resource_group_name         = data.azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.hosts.name
}

# AVD relayed RDP connectivity over UDP 3478. Microsoft publishes this
# destination through the WindowsVirtualDesktop service tag.
resource "azurerm_network_security_rule" "hosts_rdp_udp" {
  name                        = "Allow-AVD-Relayed-RDP-UDP"
  priority                    = 140
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "3478"
  source_address_prefix       = "*"
  destination_address_prefix  = "WindowsVirtualDesktop"
  resource_group_name         = data.azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.hosts.name
}

# Windows activation (KMS)
resource "azurerm_network_security_rule" "hosts_kms" {
  name                        = "Allow-Windows-Activation-KMS"
  priority                    = 150
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1688"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  resource_group_name         = data.azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.hosts.name
}

# Certificate checks, IMDS and platform health monitoring use TCP 80
resource "azurerm_network_security_rule" "hosts_http" {
  name                        = "Allow-Certificates-And-Platform-HTTP"
  priority                    = 160
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  resource_group_name         = data.azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.hosts.name
}

# Explicit deny for inbound RDP from the internet.
# Azure default rules already block this. The rule exists to make the
# design intent visible to auditors and future engineers.
resource "azurerm_network_security_rule" "hosts_deny_inbound_rdp" {
  name                        = "Deny-Inbound-RDP-From-Internet"
  priority                    = 4000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.hosts.name
}
