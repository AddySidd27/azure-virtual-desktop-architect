resource "azurerm_network_interface" "host" {
  count               = var.host_count
  name                = "nic-avdlab-h${count.index + 1}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.hosts.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.hosts.id
    private_ip_address_allocation = "Dynamic"
  }

  # Session hosts resolve the domain controller directly, so AD and the
  # Lab 5 storage private endpoint resolve correctly. In production this is
  # usually set at the VNet level, not per NIC; the lab sets it per NIC so
  # Terraform apply order does not depend on a VNet-level change landing first.
  dns_servers = var.dns_servers

  tags = local.common_tags
}

resource "azurerm_windows_virtual_machine" "host" {
  count                 = var.host_count
  name                  = "vm-avdlab-h${count.index + 1}"
  computer_name         = "AVDLABH${count.index + 1}"
  location              = var.location
  resource_group_name   = data.azurerm_resource_group.hosts.name
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.host[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  # Windows 11 Enterprise multi-session, current marketplace image.
  # [VERIFY BEFORE IMPLEMENTATION] confirm the current SKU string against
  # `az vm image list --publisher MicrosoftWindowsDesktop --all -o table`,
  # marketplace SKU names are updated as new versions release.
  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-23h2-avd"
    version   = "latest"
  }

  tags = local.common_tags
}

# Domain join. This lab uses hybrid join against the Lab 4 domain
# controller for consistency with Labs 4-6; see Project 05 for the
# Entra-only variant of this same step if your environment has no domain.
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
    User    = "avdlabadmin@avdlab.local"
    Restart = "true"
    Options = "3"
  })

  protected_settings = jsonencode({
    Password = var.admin_password
  })
}

# AVD agent installation and host pool registration, using Microsoft's
# published DSC configuration package. This is the same mechanism the
# Azure portal's own "add session host" flow uses.
# [VERIFY BEFORE IMPLEMENTATION] confirm this artifact URL against the
# current Azure portal deployment template before relying on it long term;
# Microsoft has changed this URL previously without a redirect.
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
      HostPoolName = var.host_pool_name
    }
  })

  protected_settings = jsonencode({
    properties = {
      registrationInfoToken = var.registration_token
    }
  })

  depends_on = [azurerm_virtual_machine_extension.domain_join]
}
