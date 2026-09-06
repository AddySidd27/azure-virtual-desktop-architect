############################################
# Session hosts - centralus
#
# Standard management: Terraform-created VMs, domain-joined via the
# JsonADDomainExtension, registered to the host pool via the AVD agent
# DSC extension. Identical mechanism to Lab 8, at the centralus address,
# domain-joining against vm-avdlab-dc02 (Lab 12) rather than dc01.
############################################

resource "azurerm_network_interface" "host" {
  count               = var.host_count
  name                = "nic-avdlab-cus-h${count.index + 1}"
  location            = var.location
  resource_group_name = data.terraform_remote_state.lab11_network.outputs.resource_group_names.hosts

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.lab11_network.outputs.subnet_ids.hosts
    private_ip_address_allocation = "Dynamic"
  }

  # Points at the local centralus DC first, eastus2 DC second - the DNS
  # order Lab 12 Step 5 established for the centralus VNet.
  dns_servers = [
    data.terraform_remote_state.lab12_identity.outputs.dc_private_ip,
    "10.10.1.4",
  ]

  tags = local.common_tags
}

resource "azurerm_windows_virtual_machine" "host" {
  count                 = var.host_count
  name                  = "vm-avdlab-cus-h${count.index + 1}"
  computer_name         = "AVDLABCUSH${count.index + 1}"
  location              = var.location
  resource_group_name   = data.terraform_remote_state.lab11_network.outputs.resource_group_names.hosts
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.host[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  # [VERIFY BEFORE IMPLEMENTATION] confirm the current SKU string against
  # `az vm image list --publisher MicrosoftWindowsDesktop --all -o table`,
  # matching Lab 8's own caveat - marketplace SKU names change over time.
  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-23h2-avd"
    version   = "latest"
  }

  tags = local.common_tags
}

resource "azurerm_virtual_machine_extension" "domain_join" {
  count                      = var.host_count
  name                       = "domainJoin"
  virtual_machine_id         = azurerm_windows_virtual_machine.host[count.index].id
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    Name    = "avdlab.local"
    OUPath  = ""
    User    = var.domain_join_username
    Restart = "true"
    Options = "3"
  })

  protected_settings = jsonencode({
    Password = var.admin_password
  })
}

# AVD agent installation and host pool registration, same DSC package
# Lab 8 uses. [VERIFY BEFORE IMPLEMENTATION] confirm this artifact URL
# against the current Azure portal deployment template before relying on
# it long term - Microsoft has changed this URL previously without a redirect.
resource "azurerm_virtual_machine_extension" "avd_agent" {
  count                      = var.host_count
  name                       = "avdAgentRegistration"
  virtual_machine_id         = azurerm_windows_virtual_machine.host[count.index].id
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.83"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    modulesUrl            = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_1.0.02790.446.zip"
    configurationFunction = "Configuration.ps1\\AddSessionHost"
    properties = {
      HostPoolName = azurerm_virtual_desktop_host_pool.centralus.name
    }
  })

  protected_settings = jsonencode({
    properties = {
      registrationInfoToken = azurerm_virtual_desktop_host_pool_registration_info.centralus.token
    }
  })

  depends_on = [azurerm_virtual_machine_extension.domain_join]
}
