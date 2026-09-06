# Storage account for FSLogix profile containers.
# Premium file shares require FileStorage kind, not StorageV2.
resource "azurerm_storage_account" "fslogix" {
  name                = "stfslogix${var.environment}${var.location_short}01"
  resource_group_name = data.azurerm_resource_group.storage.name
  location            = var.location

  account_kind             = "FileStorage" # required for premium file shares
  account_tier             = "Premium"
  account_replication_type = "ZRS" # premium file shares support LRS or ZRS only, never GRS/GZRS

  min_tls_version               = "TLS1_2"
  public_network_access_enabled = false # reached only via private endpoint
  shared_access_key_enabled     = true  # required until AD/Entra Kerberos is fully configured; disable after Step 4 if desired

  azure_files_authentication {
    directory_type = "AD" # switches to Entra Kerberos in the Entra-only variant; see the chapter cross-reference in the lab notes
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
  resource_group_name = data.azurerm_resource_group.storage.name
  subnet_id           = data.azurerm_subnet.storage.id

  private_service_connection {
    name                           = "psc-stfslogix-${local.suffix}"
    private_connection_resource_id = azurerm_storage_account.fslogix.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  tags = local.common_tags
}

# Private DNS zone for privatelink.file.core.windows.net, linked to the AVD VNet.
resource "azurerm_private_dns_zone" "files" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = data.azurerm_resource_group.storage.name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "files" {
  name                  = "link-files-${local.suffix}"
  resource_group_name   = data.azurerm_resource_group.storage.name
  private_dns_zone_name = azurerm_private_dns_zone.files.name
  virtual_network_id    = data.azurerm_virtual_network.avd.id
  registration_enabled  = false
  tags                  = local.common_tags
}

resource "azurerm_private_dns_a_record" "files" {
  name                = azurerm_storage_account.fslogix.name
  zone_name           = azurerm_private_dns_zone.files.name
  resource_group_name = data.azurerm_resource_group.storage.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.fslogix.private_service_connection[0].private_ip_address]
}
