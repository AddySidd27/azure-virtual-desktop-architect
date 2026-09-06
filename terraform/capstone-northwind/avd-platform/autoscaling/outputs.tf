output "scaling_plan_ids" {
  value = { for k, v in azurerm_virtual_desktop_scaling_plan.persona : k => v.id }
}

output "autoscale_exclusion_tag_name" {
  description = "Matches Lab 17's pattern: informational only. A VM tagged with this value is skipped by that region's scaling plan - applied manually as a VM tag, not enforced by this Terraform."
  value       = var.exclusion_tag_name
}
