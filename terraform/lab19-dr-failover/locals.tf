locals {
  suffix = "${var.environment}-${var.location_short}-01"

  common_tags = {
    environment  = var.environment
    workload     = "avd-dr"
    region       = var.location
    owner        = var.owner
    costCenter   = "learning"
    deletionDate = var.deletion_date
    managedBy    = "terraform"
  }
}
