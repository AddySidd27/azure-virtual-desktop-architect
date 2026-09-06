############################################
# ExpressRoute gateways
#
# SKU: ErGwScale - confirmed against Microsoft Learn (April 2026) as
# the current-generation, zone-redundant, autoscaling ExpressRoute
# gateway SKU (2-40 scale units, up to 40 Gbps). Chosen specifically
# to avoid guessing a fixed-capacity SKU against traffic volumes this
# engagement does not have real data for yet - see Part C, section 5.
#
# This module builds the GATEWAY only. The ExpressRoute CIRCUIT itself
# is provisioned jointly with Northwind's connectivity provider, a
# process outside Terraform's scope - see Part C, section 10. The
# azurerm_virtual_network_gateway_connection resource that actually
# links this gateway to a circuit is not created here; it is applied
# once the circuit exists, as a follow-up, deliberately not before.
############################################

resource "azurerm_public_ip" "eastus2_ergw" {
  name                = "pip-ergw-${var.environment}-eus2-01"
  location            = azurerm_resource_group.eastus2.location
  resource_group_name = azurerm_resource_group.eastus2.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  tags                = local.common_tags
}

resource "azurerm_virtual_network_gateway" "eastus2" {
  name                = "ergw-${var.environment}-eus2-01"
  location            = azurerm_resource_group.eastus2.location
  resource_group_name = azurerm_resource_group.eastus2.name
  type                = "ExpressRoute"
  sku                 = "ErGwScale"

  ip_configuration {
    name                          = "ergw-ipconfig"
    public_ip_address_id          = azurerm_public_ip.eastus2_ergw.id
    subnet_id                     = azurerm_subnet.eastus2_gateway.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.common_tags
}

resource "azurerm_public_ip" "westeurope_ergw" {
  name                = "pip-ergw-${var.environment}-weu-01"
  location            = azurerm_resource_group.westeurope.location
  resource_group_name = azurerm_resource_group.westeurope.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  tags                = local.common_tags
}

resource "azurerm_virtual_network_gateway" "westeurope" {
  name                = "ergw-${var.environment}-weu-01"
  location            = azurerm_resource_group.westeurope.location
  resource_group_name = azurerm_resource_group.westeurope.name
  type                = "ExpressRoute"
  sku                 = "ErGwScale"

  ip_configuration {
    name                          = "ergw-ipconfig"
    public_ip_address_id          = azurerm_public_ip.westeurope_ergw.id
    subnet_id                     = azurerm_subnet.westeurope_gateway.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.common_tags
}
