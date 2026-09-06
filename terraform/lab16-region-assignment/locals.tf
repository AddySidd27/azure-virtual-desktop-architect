locals {
  suffix = "${var.environment}-01"

  common_tags = {
    environment  = var.environment
    workload     = "avd"
    owner        = var.owner
    costCenter   = "learning"
    deletionDate = var.deletion_date
    managedBy    = "terraform"
  }

  # One eastus2 group and one centralus group per population. Built from
  # var.populations so adding a population (e.g. "engineering") only
  # requires editing the list, not adding new resource blocks.
  region_groups = {
    for pair in setproduct(var.populations, ["eus2", "cus"]) :
    "${pair[0]}-${pair[1]}" => {
      population = pair[0]
      region     = pair[1]
    }
  }
}
