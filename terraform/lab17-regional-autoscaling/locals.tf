locals {
  common_tags = {
    environment  = var.environment
    workload     = "avd"
    owner        = var.owner
    costCenter   = "learning"
    deletionDate = var.deletion_date
    managedBy    = "terraform"
  }
}
