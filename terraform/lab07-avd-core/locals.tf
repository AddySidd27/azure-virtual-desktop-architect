locals {
  suffix = "${var.environment}-${var.location_short}-01"

  common_tags = {
    environment  = var.environment
    workload     = "avd"
    owner        = var.owner
    costCenter   = "learning"
    deletionDate = var.deletion_date
    managedBy    = "terraform"
  }
}

data "azurerm_resource_group" "service" {
  name = var.service_resource_group_name
}
