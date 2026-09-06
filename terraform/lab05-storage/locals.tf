locals {
  suffix = "${var.environment}-${var.location_short}-01"

  common_tags = {
    environment  = var.environment
    workload     = "avd"
    owner        = var.owner
    costCenter   = "learning"
    autoShutdown = "false" # storage has no power state; billed while it exists
    deletionDate = var.deletion_date
    managedBy    = "terraform"
  }
}

data "azurerm_resource_group" "storage" {
  name = var.storage_resource_group_name
}

data "azurerm_virtual_network" "avd" {
  name                = var.vnet_name
  resource_group_name = var.network_resource_group_name
}

data "azurerm_subnet" "storage" {
  name                 = var.storage_subnet_name
  virtual_network_name = data.azurerm_virtual_network.avd.name
  resource_group_name  = var.network_resource_group_name
}
