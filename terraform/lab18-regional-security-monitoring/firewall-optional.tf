############################################
# Optional: centralus Azure Firewall
#
# OFF by default (var.deploy_firewall = false). Costs roughly 900 USD/month
# running regardless of traffic volume - disproportionate for lab
# purposes. Lab 11's NSGs already provide the required outbound-only
# egress control for a lab environment. Set deploy_firewall = true only
# if you specifically want to exercise this pattern and accept the cost.
############################################

resource "azurerm_public_ip" "firewall" {
  count               = var.deploy_firewall ? 1 : 0
  name                = "pip-fw-${local.suffix}"
  location            = var.location
  resource_group_name = data.terraform_remote_state.lab11_network.outputs.resource_group_names.network
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_subnet" "firewall" {
  count                = var.deploy_firewall ? 1 : 0
  name                 = "AzureFirewallSubnet" # Azure requires this exact name for Firewall subnets
  resource_group_name  = data.terraform_remote_state.lab11_network.outputs.resource_group_names.network
  virtual_network_name = "vnet-avd-${local.suffix}"
  address_prefixes     = ["10.20.6.0/26"]
}

resource "azurerm_firewall" "centralus" {
  count               = var.deploy_firewall ? 1 : 0
  name                = "fw-avd-${local.suffix}"
  location            = var.location
  resource_group_name = data.terraform_remote_state.lab11_network.outputs.resource_group_names.network
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = azurerm_subnet.firewall[0].id
    public_ip_address_id = azurerm_public_ip.firewall[0].id
  }

  tags = local.common_tags
}
