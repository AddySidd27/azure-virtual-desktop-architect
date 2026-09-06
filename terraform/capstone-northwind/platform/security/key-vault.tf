############################################
# Platform Key Vault
#
# Closes the gap Part C's terraform.tfvars.example files left open:
# domain controller and Entra Connect Sync credentials need a real,
# scoped, auditable home, not just a sensitive Terraform variable.
# RBAC-authorized, not the older access-policy model, so the same
# PIM-eligible roles from Part D section 4 govern secret access.
############################################

resource "azurerm_resource_group" "security" {
  name     = "rg-security-${var.environment}-eus2-01"
  location = "eastus2"
  tags     = local.common_tags
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "platform" {
  name                       = "kv-northwind-platform-${var.environment}"
  location                   = azurerm_resource_group.security.location
  resource_group_name        = azurerm_resource_group.security.name
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"
  enable_rbac_authorization  = true
  purge_protection_enabled   = true
  soft_delete_retention_days = 90

  public_network_access_enabled = false

  tags = local.common_tags
}

resource "azurerm_key_vault_secret" "dc_admin_username" {
  name         = "dc-admin-username"
  value        = var.dc_admin_username
  key_vault_id = azurerm_key_vault.platform.id
}

resource "azurerm_key_vault_secret" "dc_admin_password" {
  name         = "dc-admin-password"
  value        = var.dc_admin_password
  key_vault_id = azurerm_key_vault.platform.id
}

resource "azurerm_key_vault_secret" "connect_sync_service_account_username" {
  name         = "connect-sync-service-account-username"
  value        = var.connect_sync_service_account_username
  key_vault_id = azurerm_key_vault.platform.id
}

resource "azurerm_key_vault_secret" "connect_sync_service_account_password" {
  name         = "connect-sync-service-account-password"
  value        = var.connect_sync_service_account_password
  key_vault_id = azurerm_key_vault.platform.id
}
