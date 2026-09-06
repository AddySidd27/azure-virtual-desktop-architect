############################################
# FSLogix storage - region-primary, per persona region assignment.
# Matches Lab 5/Lab 13's proven storage pattern exactly. Cross-region
# resilience (Cloud Cache) is a HOST-LEVEL registry configuration, not
# a Terraform resource - matching Lab 15's established pattern - and
# is a genuinely different use of Cloud Cache from Labs 11-20's
# active-active design, per the master plan Part F4: Northwind's
# users are geography-assigned, not active-active-eligible, so
# Cloud Cache here provides resilience against a single storage
# failure, not cross-region user mobility.
############################################

resource "azurerm_storage_account" "fslogix" {
  name                = "stfslogixnw${var.environment}${var.location_short}01"
  resource_group_name = local.avd_resource_group
  location            = var.location

  account_kind             = "FileStorage"
  account_tier             = "Premium"
  account_replication_type = "ZRS" # Premium file shares support LRS or ZRS only - matches Lab 5's documented reasoning exactly

  azure_files_authentication {
    directory_type = "AD"
  }

  public_network_access_enabled = false

  tags = {
    BusinessUnit = "Northwind"
    Environment  = var.environment
    Region       = var.location
  }
}

resource "azurerm_storage_share" "profiles" {
  name               = "profiles"
  storage_account_id = azurerm_storage_account.fslogix.id
  quota              = var.file_share_quota_gb
}

resource "azurerm_private_endpoint" "fslogix" {
  name                = "pe-stfslogix-${var.environment}-${var.location_short}-01"
  location            = var.location
  resource_group_name = local.avd_resource_group
  subnet_id           = local.avd_hosts_subnet_id

  private_service_connection {
    name                           = "psc-fslogix"
    private_connection_resource_id = azurerm_storage_account.fslogix.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  tags = {
    BusinessUnit = "Northwind"
    Environment  = var.environment
    Region       = var.location
  }
}

############################################
# Share-level RBAC - layer one of Chapter 20's two-layer permission
# model. Layer two (NTFS) is applied host-side, after domain join,
# matching Lab 5's exact documented sequence - not modelled as
# Terraform, since it requires the storage account to already be
# domain-joined for AD authentication first.
#
# Split per ADR-CAP-06: finance gets its own role assignment,
# independent of the other four personas, adopted unconditionally -
# not gated behind enable_finance_dedicated_storage, since this part
# of the decision was clear-cut regardless of the storage question.
############################################

resource "azurerm_role_assignment" "non_finance_users_share_rbac" {
  scope                = "${azurerm_storage_account.fslogix.id}/fileServices/default/fileshares/${azurerm_storage_share.profiles.name}"
  role_definition_name = "Storage File Data SMB Share Contributor"
  principal_id         = var.non_finance_users_group_object_id
}

resource "azurerm_role_assignment" "finance_users_share_rbac" {
  count                = var.enable_finance_dedicated_storage ? 0 : 1
  scope                = "${azurerm_storage_account.fslogix.id}/fileServices/default/fileshares/${azurerm_storage_share.profiles.name}"
  role_definition_name = "Storage File Data SMB Share Contributor"
  principal_id         = var.finance_users_group_object_id

  # Gated off when enable_finance_dedicated_storage = true, so finance
  # never holds RBAC on both the shared and dedicated accounts at
  # once - a clean either/or, not an accumulating grant. See
  # ADR-CAP-06.
}

############################################
# Dedicated finance storage - OPTIONAL, per ADR-CAP-06.
# BUSINESS/COMPLIANCE DECISION REQUIRED: gated behind
# enable_finance_dedicated_storage, default false. When false, finance
# continues sharing the storage account above (with its own RBAC
# group already applied, regardless of this flag). When true, finance
# gets a fully separate account, share, and private endpoint,
# reusing the exact same pattern as the shared account.
############################################

resource "azurerm_storage_account" "finance_dedicated" {
  count               = var.enable_finance_dedicated_storage ? 1 : 0
  name                = "stfslogixnwfin${var.environment}${var.location_short}01"
  resource_group_name = local.avd_resource_group
  location            = var.location

  account_kind             = "FileStorage"
  account_tier             = "Premium"
  account_replication_type = "ZRS"

  azure_files_authentication {
    directory_type = "AD"
  }

  public_network_access_enabled = false

  tags = {
    BusinessUnit       = "Northwind"
    Environment        = var.environment
    Region             = var.location
    DataClassification = "SOX-Scoped"
  }
}

resource "azurerm_storage_share" "finance_dedicated" {
  count              = var.enable_finance_dedicated_storage ? 1 : 0
  name               = "profiles"
  storage_account_id = azurerm_storage_account.finance_dedicated[0].id
  quota              = var.finance_file_share_quota_gb
}

resource "azurerm_private_endpoint" "finance_dedicated" {
  count               = var.enable_finance_dedicated_storage ? 1 : 0
  name                = "pe-stfslogix-fin-${var.environment}-${var.location_short}-01"
  location            = var.location
  resource_group_name = local.avd_resource_group
  subnet_id           = local.avd_hosts_subnet_id

  private_service_connection {
    name                           = "psc-fslogix-fin"
    private_connection_resource_id = azurerm_storage_account.finance_dedicated[0].id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  tags = {
    BusinessUnit       = "Northwind"
    Environment        = var.environment
    Region             = var.location
    DataClassification = "SOX-Scoped"
  }
}

resource "azurerm_role_assignment" "finance_dedicated_share_rbac" {
  count                = var.enable_finance_dedicated_storage ? 1 : 0
  scope                = "${azurerm_storage_account.finance_dedicated[0].id}/fileServices/default/fileshares/${azurerm_storage_share.finance_dedicated[0].name}"
  role_definition_name = "Storage File Data SMB Share Contributor"
  principal_id         = var.finance_users_group_object_id
}
