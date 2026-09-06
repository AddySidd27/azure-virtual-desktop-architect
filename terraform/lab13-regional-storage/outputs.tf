output "storage_account_name" {
  description = "centralus FSLogix storage account name"
  value       = azurerm_storage_account.fslogix.name
}

output "storage_account_id" {
  description = "centralus FSLogix storage account resource ID"
  value       = azurerm_storage_account.fslogix.id
}

output "file_share_name" {
  description = "centralus FSLogix profile share name"
  value       = azurerm_storage_share.profiles.name
}

output "private_endpoint_ip" {
  description = "Private IP address of the centralus storage private endpoint"
  value       = azurerm_private_endpoint.fslogix.private_service_connection[0].private_ip_address
}

output "smb_path" {
  description = "Full SMB UNC path to the centralus profile share, used in FSLogix registry configuration (Lab 15)"
  value       = "\\\\${azurerm_storage_account.fslogix.name}.file.core.windows.net\\${azurerm_storage_share.profiles.name}"
}
