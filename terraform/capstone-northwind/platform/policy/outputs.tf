output "allowed_locations_assignment_id" {
  value = azurerm_management_group_policy_assignment.allowed_locations.id
}

output "required_tags_assignment_ids" {
  value = { for k, v in azurerm_management_group_policy_assignment.required_tags : k => v.id }
}
