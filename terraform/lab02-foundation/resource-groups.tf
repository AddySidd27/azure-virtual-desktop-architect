resource "azurerm_resource_group" "network" {
  name     = "rg-avd-network-${local.suffix}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "identity" {
  name     = "rg-avd-identity-${local.suffix}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "storage" {
  name     = "rg-avd-storage-${local.suffix}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "avd" {
  name     = "rg-avd-service-${local.suffix}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "hosts" {
  name     = "rg-avd-hosts-${local.suffix}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "monitoring" {
  name     = "rg-avd-monitoring-${local.suffix}"
  location = var.location
  tags     = local.common_tags
}
