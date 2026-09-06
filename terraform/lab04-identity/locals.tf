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

data "azurerm_subnet" "identity" {
  name                 = var.identity_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.network_resource_group_name
}
