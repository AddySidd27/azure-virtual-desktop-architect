provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
provider "azapi" {
  subscription_id = var.subscription_id
}
variable "subscription_id" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "storage_account_name" {
  type = string
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Use a globally unique lowercase alphanumeric name, 3-24 characters."
  }
}
variable "location" {
  type = string
}
variable "private_endpoint_subnet_id" {
  type = string
}
variable "private_dns_zone_id" {
  type        = string
  description = "Existing central privatelink.file.core.windows.net zone. Its VNet links/forwarding are prerequisites."
}
variable "shares" {
  type = map(object({
    capacity_gib     = number
    iops             = number
    throughput_mibps = number
    user_group_id    = string
  }))
  description = "Approved sizes/performance, checked against regional provisioning limits. No production defaults."
  validation {
    condition = length(var.shares) > 0 && alltrue([
      for share in values(var.shares) : share.capacity_gib > 0 && share.iops > 0 && share.throughput_mibps > 0
    ])
    error_message = "Replace every zero with approved positive provisioning values. Check Azure regional minimum/maximum limits."
  }
}
resource "azurerm_storage_account" "profiles" {
  name                              = var.storage_account_name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  account_kind                      = "FileStorage"
  account_tier                      = "Premium"
  account_replication_type          = "ZRS"
  provisioned_billing_model_version = "V2"
  public_network_access             = "Disabled"
  min_tls_version                   = "TLS1_2"
  https_traffic_only_enabled        = true
  allow_nested_items_to_be_public   = false
  azure_files_authentication {
    directory_type = "AADKERB"
  }
  tags = {
    Workload    = "AVD profile storage"
    Environment = "validation"
    ManagedBy   = "Terraform"
  }
  lifecycle {
    prevent_destroy = true
  }
}
# Management-plane share creation avoids requiring public data-plane access
# from the Terraform runner. SMB testing still needs the private network path.
resource "azapi_resource" "share" {
  for_each  = var.shares
  type      = "Microsoft.Storage/storageAccounts/fileServices/shares@2025-06-01"
  parent_id = "${azurerm_storage_account.profiles.id}/fileServices/default"
  name      = each.key
  body = {
    properties = {
      enabledProtocols          = "SMB"
      shareQuota                = each.value.capacity_gib
      provisionedIops           = each.value.iops
      provisionedBandwidthMibps = each.value.throughput_mibps
    }
  }
  lifecycle {
    prevent_destroy = true
  }
}
resource "azurerm_private_endpoint" "profiles" {
  name                = "pe-${var.storage_account_name}-file"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_subnet_id
  private_service_connection {
    name                           = "psc-${var.storage_account_name}-file"
    private_connection_resource_id = azurerm_storage_account.profiles.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "file"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
}
resource "azurerm_role_assignment" "profile_users" {
  for_each             = var.shares
  scope                = azapi_resource.share[each.key].id
  role_definition_name = "Storage File Data SMB Share Contributor"
  principal_id         = each.value.user_group_id
}
output "profile_paths" {
  value = { for name, share in azapi_resource.share : name => "\\\\${azurerm_storage_account.profiles.name}.file.core.windows.net\\${name}" }
}
output "private_endpoint_id" {
  value = azurerm_private_endpoint.profiles.id
}
