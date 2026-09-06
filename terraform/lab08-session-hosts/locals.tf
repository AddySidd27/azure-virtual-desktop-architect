locals {
  suffix = "${var.environment}-${var.location_short}-01"

  common_tags = {
    environment  = var.environment
    workload     = "avd"
    owner        = var.owner
    costCenter   = "learning"
    autoShutdown = "true"
    deletionDate = var.deletion_date
    managedBy    = "terraform"
  }
}

data "azurerm_resource_group" "hosts" {
  name = var.hosts_resource_group_name
}

data "azurerm_virtual_network" "avd" {
  name                = var.vnet_name
  resource_group_name = var.network_resource_group_name
}

data "azurerm_subnet" "hosts" {
  name                 = var.hosts_subnet_name
  virtual_network_name = data.azurerm_virtual_network.avd.name
  resource_group_name  = var.network_resource_group_name
}
