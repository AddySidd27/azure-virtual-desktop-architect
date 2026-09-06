############################################
# Break-glass emergency access accounts
#
# Two cloud-only accounts, per Microsoft's long-standing guidance
# (Part D, section 4.4). This resource creates the ACCOUNTS only.
# The Conditional Access exclusion and the sign-in monitoring alert
# are NOT modelled here - portal/Graph API configuration, marked
# [VERIFY BEFORE IMPLEMENTATION] in the parent document, since the
# specific current-recommended alert configuration should be checked
# against Microsoft Learn at implementation time, not assumed.
############################################

resource "random_password" "break_glass" {
  count            = var.break_glass_account_count
  length           = 32
  special          = true
  override_special = "!@#$%^&*()-_=+"
}

resource "azuread_user" "break_glass" {
  count                 = var.break_glass_account_count
  user_principal_name   = "breakglass${count.index + 1}@${var.break_glass_domain}"
  display_name          = "BREAK GLASS - Emergency Access ${count.index + 1}"
  password              = random_password.break_glass[count.index].result
  force_password_change = false

  # [VERIFY BEFORE IMPLEMENTATION] confirm current guidance on
  # whether usage location or other attributes are required for this
  # account type in your tenant's licensing configuration.
}

resource "azurerm_key_vault_secret" "break_glass_password" {
  count        = var.break_glass_account_count
  name         = "break-glass-account-${count.index + 1}-password"
  value        = random_password.break_glass[count.index].result
  key_vault_id = azurerm_key_vault.platform.id
}

# NOTE: storing both break-glass credentials in the same Key Vault
# they'd need Entra ID to be healthy to reach is a real, disclosed
# tension - see Part D section 4.4. The credential SPLIT this design
# calls for (two physically separate secure locations) is an
# operational, off-platform control, not something this Terraform can
# enforce, and is documented here rather than silently assumed solved
# by the Key Vault's existence.
