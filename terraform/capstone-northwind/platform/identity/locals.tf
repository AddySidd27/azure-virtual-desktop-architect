locals {
  common_tags = {
    BusinessUnit       = "Northwind"
    Environment        = var.environment
    CostCentre         = var.cost_centre
    DataClassification = "Platform-Identity"
    Owner              = var.owner
  }
}
