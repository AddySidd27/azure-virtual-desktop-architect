output "recovery_vault_id" {
  value = azurerm_recovery_services_vault.fslogix.id
}

output "backup_policy_id" {
  value = azurerm_backup_policy_file_share.fslogix.id
}

output "protected_file_share_id" {
  value = azurerm_backup_protected_file_share.fslogix.id
}
