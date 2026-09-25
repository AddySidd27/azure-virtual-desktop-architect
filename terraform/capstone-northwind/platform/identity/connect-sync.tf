############################################
# REMEDIATION: Microsoft Entra Connect Sync server infrastructure
#
# The implementation tracker (capstone/implementation-tracker.md,
# section 2) found that Part C's document described Connect Sync as
# "installed on a dedicated, domain-joined server," but no such
# server - no VM, no resource of any kind - existed anywhere in this
# Terraform. Only its future credentials existed, as placeholders in
# the platform Key Vault. This file provisions that VM infrastructure.
# The Connect Sync SOFTWARE installation and configuration remains an
# imperative post-deployment step, exactly like AD DS promotion on
# the domain controllers - not a
# regression from this book's established pattern, a consistent
# application of it.
#
# Architecture decision: one primary server in East US 2, one
# staging-mode secondary in West Europe. Microsoft
# documents a "staging mode" configuration for exactly this HA
# scenario - a second server configured identically but not actively
# exporting to Entra ID until deliberately enabled. Given Part C's
# entire section 8 is about surviving a regional identity failure,
# building only a single-region Connect Sync server would leave sync
# itself as a single point of failure even though authentication
# itself is resilient - this decision closes that specific gap.
# [VERIFY BEFORE IMPLEMENTATION] confirm current Microsoft guidance
# on staging-mode configuration and failover procedure before relying
# on this in production - the VM exists here; the staging-mode
# configuration itself is not modelled as Terraform, consistent with
# every other Connect Sync configuration step in this design.
############################################

resource "azurerm_network_interface" "eastus2_sync_primary" {
  name                = "nic-sync-${var.environment}-eus2-01"
  location            = azurerm_resource_group.eastus2.location
  resource_group_name = azurerm_resource_group.eastus2.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.eastus2_dc.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.110.0.10"
  }

  tags = local.common_tags
}

resource "azurerm_windows_virtual_machine" "eastus2_sync_primary" {
  name                  = "vm-sync-eus2-01"
  computer_name         = "NWSYNCEUS2"
  location              = azurerm_resource_group.eastus2.location
  resource_group_name   = azurerm_resource_group.eastus2.name
  size                  = "Standard_D2s_v5" # [VERIFY BEFORE IMPLEMENTATION] confirm against Microsoft's current Entra Connect Sync hardware sizing guidance for Northwind's actual object count (3,200 users plus groups/devices) before committing to this size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.eastus2_sync_primary.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  tags = local.common_tags
}

resource "azurerm_network_interface" "westeurope_sync_staging" {
  name                = "nic-sync-${var.environment}-weu-01"
  location            = azurerm_resource_group.westeurope.location
  resource_group_name = azurerm_resource_group.westeurope.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.westeurope_dc.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.111.0.10"
  }

  tags = local.common_tags
}

resource "azurerm_windows_virtual_machine" "westeurope_sync_staging" {
  name                  = "vm-sync-weu-01"
  computer_name         = "NWSYNCWEU"
  location              = azurerm_resource_group.westeurope.location
  resource_group_name   = azurerm_resource_group.westeurope.name
  size                  = "Standard_D2s_v5"
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.westeurope_sync_staging.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  tags = local.common_tags
}
