output "key_vault_id" {
  value = azurerm_key_vault.platform.id
}

output "key_vault_uri" {
  value = azurerm_key_vault.platform.vault_uri
}

output "eastus2_bastion_id" {
  value = azurerm_bastion_host.eastus2.id
}

output "westeurope_bastion_id" {
  value = azurerm_bastion_host.westeurope.id
}

output "break_glass_upns" {
  value = azuread_user.break_glass[*].user_principal_name
}
