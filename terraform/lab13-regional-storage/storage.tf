# Storage account for FSLogix profile containers - centralus.
# Premium file shares require FileStorage kind, not StorageV2, matching
# Lab 5's reasoning exactly. This is a separate storage account from Lab 5's,
# not a replica of it - Lab 15 configures FSLogix Cloud Cache to replicate
# profile data between the two independently-created accounts.
resource "azurerm_storage_account" "fslogix" {
  name                = "stfslogix${var.environment}${var.location_short}01"
  resource_group_name = data.terraform_remote_state.lab11_network.outputs.resource_group_names.storage
  location            = var.location

  account_kind             = "FileStorage" # required for premium file shares
  account_tier             = "Premium"
  account_replication_type = "ZRS" # premium file shares support LRS or ZRS only, never GRS/GZRS - same constraint Lab 5 documents

  min_tls_version               = "TLS1_2"
  public_network_access_enabled = false # reached only via private endpoint
  shared_access_key_enabled     = true  # required until AD/Entra Kerberos is fully configured; disable after Step 4 if desired

  azure_files_authentication {
    directory_type = "AD" # centralus session hosts authenticate via vm-avdlab-dc02 (Lab 12), same AD-based model as Lab 5
  }

  tags = local.common_tags
}

resource "azurerm_storage_share" "profiles" {
  name               = "profiles"
  storage_account_id = azurerm_storage_account.fslogix.id
  quota              = var.file_share_quota_gb
  enabled_protocol   = "SMB"
}

# Private endpoint so the share is never reachable over the public internet.
resource "azurerm_private_endpoint" "fslogix" {
  name                = "pe-stfslogix-${local.suffix}"
  location            = var.location
  resource_group_name = data.terraform_remote_state.lab11_network.outputs.resource_group_names.storage
  subnet_id           = data.terraform_remote_state.lab11_network.outputs.subnet_ids.storage

  private_service_connection {
    name                           = "psc-stfslogix-${local.suffix}"
    private_connection_resource_id = azurerm_storage_account.fslogix.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  tags = local.common_tags
}

# Private DNS zone for privatelink.file.core.windows.net, linked to the
# centralus VNet. This is a SEPARATE zone from Lab 5's eastus2 zone of the
# same name - Azure private DNS zone names are not globally unique, and each
# region's zone only needs to resolve that region's own private endpoint.
# A session host only ever talks to its own region's storage account
# directly; cross-region profile access goes through Cloud Cache (Lab 15),
# not through cross-region DNS resolution of the other region's endpoint.
resource "azurerm_private_dns_zone" "files" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = data.terraform_remote_state.lab11_network.outputs.resource_group_names.storage
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "files" {
  name                  = "link-files-${local.suffix}"
  resource_group_name   = data.terraform_remote_state.lab11_network.outputs.resource_group_names.storage
  private_dns_zone_name = azurerm_private_dns_zone.files.name
  virtual_network_id    = data.terraform_remote_state.lab11_network.outputs.vnet_id
  registration_enabled  = false
  tags                  = local.common_tags
}

resource "azurerm_private_dns_a_record" "files" {
  name                = azurerm_storage_account.fslogix.name
  zone_name           = azurerm_private_dns_zone.files.name
  resource_group_name = data.terraform_remote_state.lab11_network.outputs.resource_group_names.storage
  ttl                 = 300
  records             = [azurerm_private_endpoint.fslogix.private_service_connection[0].private_ip_address]
}
