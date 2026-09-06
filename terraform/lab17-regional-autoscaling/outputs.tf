output "eastus2_scaling_plan_name" {
  value = azurerm_virtual_desktop_scaling_plan.eastus2.name
}

output "centralus_scaling_plan_name" {
  value = azurerm_virtual_desktop_scaling_plan.centralus.name
}

output "autoscale_exclusion_tag_name" {
  description = "Apply this tag (any value) directly to a session host VM resource to exclude it from either region's scaling plan actions"
  value       = var.autoscale_exclusion_tag_name
}
