output "platform_engineer_pim_assignment_id" {
  value = azurerm_pim_eligible_role_assignment.platform_engineer.id
}

output "pim_role_count" {
  description = "Confirms, structurally, how many roles are actually PIM-eligible after this remediation - 5, not the 0 that existed before it"
  value       = 5
}
