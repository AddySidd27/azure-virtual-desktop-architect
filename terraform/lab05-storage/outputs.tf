output "storage_account_name" {
  description = "FSLogix storage account name, used in Lab 6 FSLogix configuration"
  value       = azurerm_storage_account.fslogix.name
}

output "file_share_name" {
  description = "Profile share name"
  value       = azurerm_storage_share.profiles.name
}

output "vhd_location_unc_path" {
  description = "The UNC path to set as VHDLocations in Lab 6. Uses the private endpoint FQDN, resolved via the private DNS zone."
  value       = "\\\\${azurerm_storage_account.fslogix.name}.file.core.windows.net\\${azurerm_storage_share.profiles.name}"
}

output "private_endpoint_ip" {
  description = "Private IP of the storage private endpoint. Confirm this is what the DNS zone resolves to before Lab 6."
  value       = azurerm_private_endpoint.fslogix.private_service_connection[0].private_ip_address
  sensitive   = false
}
