output "host_pool_ids" {
  value = { for k, v in azurerm_virtual_desktop_host_pool.persona : k => v.id }
}

output "host_pool_names" {
  value = { for k, v in azurerm_virtual_desktop_host_pool.persona : k => v.name }
}

output "session_host_counts" {
  description = "Computed from the placeholder regional_split_percent - see variables.tf. Recompute once Northwind confirms real regional headcounts."
  value       = { for k, v in local.regional_personas : k => v.host_count }
}
