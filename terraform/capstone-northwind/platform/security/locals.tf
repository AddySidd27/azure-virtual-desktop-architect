locals {
  common_tags = {
    BusinessUnit       = "Northwind"
    Environment        = var.environment
    CostCentre         = var.cost_centre
    DataClassification = "Platform-Security"
    Owner              = var.owner
  }
}
