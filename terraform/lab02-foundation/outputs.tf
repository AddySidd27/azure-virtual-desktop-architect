output "resource_group_names" {
  description = "All lab resource group names"
  value = {
    network    = azurerm_resource_group.network.name
    identity   = azurerm_resource_group.identity.name
    storage    = azurerm_resource_group.storage.name
    avd        = azurerm_resource_group.avd.name
    hosts      = azurerm_resource_group.hosts.name
    monitoring = azurerm_resource_group.monitoring.name
  }
}

output "common_tags" {
  description = "Tag map applied to all lab resources"
  value       = local.common_tags
}
