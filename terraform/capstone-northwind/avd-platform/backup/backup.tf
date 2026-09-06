############################################
# Azure Backup for FSLogix profile storage - Part H3.
#
# The real, concrete answer to Project 14's core lesson, applied to
# Northwind specifically: Cloud Cache (Part F9) is REDUNDANCY, not
# backup. It protects against a single region's storage account
# failing outright - it does NOT protect against corruption or
# accidental/malicious deletion propagating to both regions' copies,
# and it provides no point-in-time restore. Before this module,
# Northwind's FSLogix estate had redundancy and nothing else -
# exactly Corrigan's original mistake in Project 14, now found and
# corrected here rather than left unnoticed.
#
# Schema confirmed against a real, published Terraform example
# specifically for FSLogix profile backup (not assumed from generic
# Azure Backup familiarity) before use.
############################################

resource "azurerm_resource_group" "backup" {
  name     = "rg-avd-backup-${var.environment}-${var.location_short}-01"
  location = var.location
}

resource "azurerm_recovery_services_vault" "fslogix" {
  name                = "rsv-fslogix-${var.environment}-${var.location_short}-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.backup.name
  sku                 = "Standard"

  soft_delete_enabled = true
}

resource "azurerm_backup_container_storage_account" "fslogix" {
  resource_group_name = azurerm_resource_group.backup.name
  recovery_vault_name = azurerm_recovery_services_vault.fslogix.name
  storage_account_id  = data.terraform_remote_state.avdplt_fslogix.outputs.storage_account_id
}

resource "azurerm_backup_policy_file_share" "fslogix" {
  name                = "policy-fslogix-${var.environment}-${var.location_short}-01"
  resource_group_name = azurerm_resource_group.backup.name
  recovery_vault_name = azurerm_recovery_services_vault.fslogix.name
  timezone            = "UTC"

  backup {
    frequency = "Daily"
    time      = var.backup_time_utc
  }

  retention_daily {
    count = var.retention_daily_count
  }
}

resource "azurerm_backup_protected_file_share" "fslogix" {
  resource_group_name       = azurerm_resource_group.backup.name
  recovery_vault_name       = azurerm_recovery_services_vault.fslogix.name
  source_storage_account_id = azurerm_backup_container_storage_account.fslogix.storage_account_id
  source_file_share_name    = "profiles"
  backup_policy_id          = azurerm_backup_policy_file_share.fslogix.id
}
