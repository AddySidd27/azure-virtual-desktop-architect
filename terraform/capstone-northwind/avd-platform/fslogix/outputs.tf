output "storage_account_name" {
  value = azurerm_storage_account.fslogix.name
}

output "storage_account_id" {
  value = azurerm_storage_account.fslogix.id
}

output "finance_dedicated_storage_account_id" {
  description = "Null when enable_finance_dedicated_storage = false (the default) - see ADR-CAP-06"
  value       = var.enable_finance_dedicated_storage ? azurerm_storage_account.finance_dedicated[0].id : null
}
