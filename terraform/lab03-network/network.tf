############################################
# Virtual network
############################################

resource "azurerm_virtual_network" "avd" {
  name                = "vnet-avd-${local.suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.network.name
  address_space       = var.vnet_address_space
  tags                = local.common_tags
}

############################################
# Subnets
############################################

resource "azurerm_subnet" "identity" {
  name                 = "snet-identity-${local.suffix}"
  resource_group_name  = data.azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.avd.name
  address_prefixes     = [var.subnet_prefixes["identity"]]
}

resource "azurerm_subnet" "hosts" {
  name                 = "snet-hosts-${local.suffix}"
  resource_group_name  = data.azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.avd.name
  address_prefixes     = [var.subnet_prefixes["hosts"]]
}

resource "azurerm_subnet" "storage" {
  name                 = "snet-storage-${local.suffix}"
  resource_group_name  = data.azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.avd.name
  address_prefixes     = [var.subnet_prefixes["storage"]]
}

resource "azurerm_subnet" "mgmt" {
  name                 = "snet-mgmt-${local.suffix}"
  resource_group_name  = data.azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.avd.name
  address_prefixes     = [var.subnet_prefixes["mgmt"]]
}

# Reserved for later use. The subnet is free; Azure Bastion itself is NOT deployed here.
# See the cost warning in Lab 3 before deploying Bastion.
resource "azurerm_subnet" "bastion" {
  count                = var.deploy_bastion_subnet ? 1 : 0
  name                 = "AzureBastionSubnet" # name is mandatory and case-sensitive
  resource_group_name  = data.azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.avd.name
  address_prefixes     = [var.subnet_prefixes["bastion"]]
}
