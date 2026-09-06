############################################
# Azure Firewall - one per regional hub
#
# Justified here as a platform-shared resource across every current
# and future workload in Corp, per Part C section 5 - a genuinely
# different context from Lab 18's rejection of Firewall for a single
# lab environment's egress control.
############################################

resource "azurerm_public_ip" "eastus2_fw" {
  name                = "pip-fw-${var.environment}-eus2-01"
  location            = azurerm_resource_group.eastus2.location
  resource_group_name = azurerm_resource_group.eastus2.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  tags                = local.common_tags
}

resource "azurerm_firewall" "eastus2" {
  name                = "fw-${var.environment}-eus2-01"
  location            = azurerm_resource_group.eastus2.location
  resource_group_name = azurerm_resource_group.eastus2.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  zones               = ["1", "2", "3"]

  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = azurerm_subnet.eastus2_firewall.id
    public_ip_address_id = azurerm_public_ip.eastus2_fw.id
  }

  tags = local.common_tags
}

resource "azurerm_public_ip" "westeurope_fw" {
  name                = "pip-fw-${var.environment}-weu-01"
  location            = azurerm_resource_group.westeurope.location
  resource_group_name = azurerm_resource_group.westeurope.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  tags                = local.common_tags
}

resource "azurerm_firewall" "westeurope" {
  name                = "fw-${var.environment}-weu-01"
  location            = azurerm_resource_group.westeurope.location
  resource_group_name = azurerm_resource_group.westeurope.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  zones               = ["1", "2", "3"]

  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = azurerm_subnet.westeurope_firewall.id
    public_ip_address_id = azurerm_public_ip.westeurope_fw.id
  }

  tags = local.common_tags
}
