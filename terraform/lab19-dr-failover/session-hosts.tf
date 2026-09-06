############################################
# DR session hosts - conditionally created
#
# When deploy_active = false (the default), count = 0: no VMs exist
# at all, not even deallocated ones. This is a genuinely cheaper
# standing state than Lab 14's "deallocated but present" pattern,
# appropriate for DR (rarely activated) versus active-active
# (activated by definition, all the time). Setting deploy_active =
# true and re-applying is the infrastructure half of the failover
# runbook - see the lab markdown for the full sequence, including the
# data restore and DNS/group reassignment steps Terraform does not
# perform.
############################################

resource "azurerm_network_interface" "dr_host" {
  count               = var.deploy_active ? var.host_count : 0
  name                = "nic-avdlab-dr-h${count.index + 1}"
  location            = var.location
  resource_group_name = azurerm_resource_group.dr.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dr_hosts.id
    private_ip_address_allocation = "Dynamic"
  }

  # CORRECTED: DNS server order now lists centralus's domain controller
  # (Lab 12) first, not eastus2's. The original design listed eastus2's
  # DC only, which meant DR session hosts had no working DNS/auth path
  # during an eastus2 outage - the exact scenario this lab exists to
  # survive. centralus's domain controller is a separate, independently
  # healthy identity plane, unaffected by an eastus2 failure. eastus2's
  # DC is listed second: useful during a planned failover test or a
  # partial failure where eastus2 identity is still reachable, but
  # never the only path.
  dns_servers = [
    data.terraform_remote_state.lab12_identity.outputs.dc_private_ip, # centralus DC - primary
    "10.10.1.4",                                                      # eastus2 DC (Lab 4) - secondary, not depended on alone
  ]

  tags = local.common_tags
}

resource "azurerm_windows_virtual_machine" "dr_host" {
  count                 = var.deploy_active ? var.host_count : 0
  name                  = "vm-avdlab-dr-h${count.index + 1}"
  computer_name         = "AVDLABDRH${count.index + 1}"
  location              = var.location
  resource_group_name   = azurerm_resource_group.dr.name
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.dr_host[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  # [VERIFY BEFORE IMPLEMENTATION] confirm the current SKU string, matching
  # the same caveat Lab 8 and Lab 14 carry.
  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-23h2-avd"
    version   = "latest"
  }

  tags = local.common_tags
}

resource "azurerm_virtual_machine_extension" "dr_domain_join" {
  count                      = var.deploy_active ? var.host_count : 0
  name                       = "domainJoin"
  virtual_machine_id         = azurerm_windows_virtual_machine.dr_host[count.index].id
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    Name    = "avdlab.local"
    OUPath  = ""
    User    = "avdlabadmin@avdlab.local"
    Restart = "true"
    Options = "3"
  })

  protected_settings = jsonencode({
    Password = var.admin_password
  })
}

resource "azurerm_virtual_machine_extension" "dr_avd_agent" {
  count                      = var.deploy_active ? var.host_count : 0
  name                       = "avdAgentRegistration"
  virtual_machine_id         = azurerm_windows_virtual_machine.dr_host[count.index].id
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.83"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    modulesUrl            = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_1.0.02790.446.zip"
    configurationFunction = "Configuration.ps1\\AddSessionHost"
    properties = {
      HostPoolName = azurerm_virtual_desktop_host_pool.dr.name
    }
  })

  protected_settings = jsonencode({
    properties = {
      registrationInfoToken = azurerm_virtual_desktop_host_pool_registration_info.dr.token
    }
  })

  depends_on = [azurerm_virtual_machine_extension.dr_domain_join]
}

############################################
# On-demand capacity reservation - OFF by default
#
# Confirmed against learn.microsoft.com/azure/virtual-machines/
# capacity-reservation-overview: "Capacity reservations are priced at
# the same rate as the underlying VM size... you start getting billed
# ...even if the reservation isn't being used." Billing starts the
# moment the reservation is created and continues regardless of
# deploy_active - a reservation for 1x Standard_D2s_v5 costs the same
# per hour whether zero, one, or no session hosts currently exist.
# This is a genuinely different, ADDITIONAL cost on top of (or instead
# of) session host compute, not a variant of it. Four distinct billing
# states exist in this lab, not two:
#   1. No session-host VMs deployed (deploy_active=false): $0 compute
#   2. Session-host VMs deployed and running (deploy_active=true): full VM rate
#   3. Capacity reservation enabled (enable_capacity_reservation=true): full
#      VM-rate charge, continuously, independent of states 1 and 2
#   4. Capacity reservation removed (enable_capacity_reservation=false,
#      the default): $0 - this is what keeps state 1 genuinely free
############################################

resource "azurerm_capacity_reservation_group" "dr" {
  count               = var.enable_capacity_reservation ? 1 : 0
  name                = "crg-avd-dr-${local.suffix}"
  resource_group_name = azurerm_resource_group.dr.name
  location            = var.location
  tags                = local.common_tags
}

resource "azurerm_capacity_reservation" "dr" {
  count                         = var.enable_capacity_reservation ? 1 : 0
  name                          = "cr-avd-dr-${local.suffix}"
  capacity_reservation_group_id = azurerm_capacity_reservation_group.dr[0].id
  sku_name                      = var.vm_size
  capacity                      = var.host_count
  tags                          = local.common_tags
}
