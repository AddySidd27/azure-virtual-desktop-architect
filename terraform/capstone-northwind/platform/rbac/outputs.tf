output "platform_engineer_pim_assignment_id" {
  value = azurerm_pim_eligible_role_assignment.platform_engineer.id
}

output "pim_role_count" {
  description = "Number of platform roles that are PIM-eligible rather than standing assignments"
  value       = 5
}
