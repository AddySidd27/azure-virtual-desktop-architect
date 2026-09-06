############################################
# Azure Bastion - Premium SKU, per regional hub
#
# Confirmed against Microsoft Learn: session recording requires the
# Premium SKU specifically - Standard does not include it. Chosen for
# that stated reason (Part D, section 3.5), given this hub's spoke
# holds the domain controllers built in Part C.
############################################

resource "azurerm_subnet" "eastus2_bastion" {
  name                 = "AzureBastionSubnet" # fixed name, required by Azure
  resource_group_name  = var.eastus2_hub_resource_group
  virtual_network_name = var.eastus2_hub_vnet_name
  address_prefixes     = ["10.100.2.0/26"]
}

resource "azurerm_public_ip" "eastus2_bastion" {
  name                = "pip-bastion-${var.environment}-eus2-01"
  location            = "eastus2"
  resource_group_name = var.eastus2_hub_resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_bastion_host" "eastus2" {
  name                = "bas-${var.environment}-eus2-01"
  location            = "eastus2"
  resource_group_name = var.eastus2_hub_resource_group
  sku                 = "Premium"

  ip_configuration {
    name                 = "bastion-ipconfig"
    subnet_id            = azurerm_subnet.eastus2_bastion.id
    public_ip_address_id = azurerm_public_ip.eastus2_bastion.id
  }

  tags = local.common_tags
}

resource "azurerm_subnet" "westeurope_bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.westeurope_hub_resource_group
  virtual_network_name = var.westeurope_hub_vnet_name
  address_prefixes     = ["10.101.2.0/26"]
}

resource "azurerm_public_ip" "westeurope_bastion" {
  name                = "pip-bastion-${var.environment}-weu-01"
  location            = "westeurope"
  resource_group_name = var.westeurope_hub_resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_bastion_host" "westeurope" {
  name                = "bas-${var.environment}-weu-01"
  location            = "westeurope"
  resource_group_name = var.westeurope_hub_resource_group
  sku                 = "Premium"

  ip_configuration {
    name                 = "bastion-ipconfig"
    subnet_id            = azurerm_subnet.westeurope_bastion.id
    public_ip_address_id = azurerm_public_ip.westeurope_bastion.id
  }

  tags = local.common_tags
}

# [VERIFY BEFORE IMPLEMENTATION] Session recording itself (storage
# account, container, and the session-recording feature flag) is not
# enabled by this resource block alone - confirm the current
# azurerm_bastion_host schema's support for session recording
# configuration, or the required portal/CLI step, against Microsoft
# Learn at implementation time. See Part D, section 3.5.
