locals {
  suffix = "${var.environment}-${var.location_short}-01"

  common_tags = {
    environment  = var.environment
    workload     = "avd"
    region       = "centralus"
    owner        = var.owner
    costCenter   = "learning"
    autoShutdown = "true"
    deletionDate = var.deletion_date
    managedBy    = "terraform"
  }
}
