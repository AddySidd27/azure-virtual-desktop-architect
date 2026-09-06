output "northwind_management_group_id" {
  description = "The Northwind intermediate root management group ID - the scope the policy module (../policy) assigns its initiative to"
  value       = azurerm_management_group.northwind.id
}

output "corp_management_group_id" {
  description = "The reserved, empty Corp landing zone management group. Part E associates AVD subscriptions here once built."
  value       = azurerm_management_group.corp.id
}

output "platform_management_group_ids" {
  description = "Identity, Management, and Connectivity management group IDs, for Part C to deploy into"
  value = {
    identity     = azurerm_management_group.identity.id
    management   = azurerm_management_group.management.id
    connectivity = azurerm_management_group.connectivity.id
  }
}
