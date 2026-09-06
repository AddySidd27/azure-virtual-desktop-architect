output "region_groups" {
  description = "Every group created, with its population and region, for the audit script in the lab's validation section"
  value = {
    for k, v in azuread_group.region : k => {
      object_id  = v.object_id
      population = local.region_groups[k].population
      region     = local.region_groups[k].region
    }
  }
}
