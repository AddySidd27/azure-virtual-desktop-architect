############################################
# Session hosts, one set per persona, count derived from
# local.regional_personas (which itself depends on the placeholder
# regional split - see variables.tf).
#
# Flattened for_each: Terraform's for_each needs a flat map, not
# nested loops, so this builds one "persona-index" key per host
# across all personas in one pass.
############################################

locals {
  session_host_instances = merge([
    for persona_key, persona in local.regional_personas : {
      for i in range(persona.host_count) : "${persona_key}-${i + 1}" => {
        persona_key = persona_key
        vm_size     = persona.vm_size
        index       = i + 1
      }
    }
  ]...)
}

resource "azurerm_network_interface" "session_host" {
  for_each = local.session_host_instances

  name                = "nic-${each.value.persona_key}-${var.environment}-${var.location_short}-${format("%02d", each.value.index)}"
  location            = var.location
  resource_group_name = local.avd_resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = local.avd_hosts_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  dns_servers = local.dns_servers

  tags = local.common_tags
}

resource "azurerm_windows_virtual_machine" "session_host" {
  for_each = local.session_host_instances

  name                  = "vm-${each.value.persona_key}-${var.location_short}-${format("%02d", each.value.index)}"
  computer_name         = upper("${each.value.persona_key}${var.location_short}${format("%02d", each.value.index)}")
  location              = var.location
  resource_group_name   = local.avd_resource_group
  size                  = each.value.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.session_host[each.key].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  # Windows 11 multi-session, per Chapter 5's fixed default. Windows
  # Server is a scoped exception only if a specific vendor requires
  # it - not applied here, since no such requirement has been raised
  # for any of the five personas.
  # [VERIFY BEFORE IMPLEMENTATION] confirm the current marketplace SKU
  # string, matching the same caveat already carried since Lab 8 -
  # these strings are not guaranteed stable over time.
  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-23h2-avd"
    version   = "latest"
  }

  tags = local.common_tags
}

resource "azurerm_virtual_machine_extension" "domain_join" {
  for_each = local.session_host_instances

  name                       = "domainJoin"
  virtual_machine_id         = azurerm_windows_virtual_machine.session_host[each.key].id
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    Name    = "northwind.local" # [VERIFY BEFORE IMPLEMENTATION] placeholder domain name - no chapter or capstone part has ever stated Northwind's actual on-premises AD domain name. This must NOT be "avdlab.local" (the separate Labs 1-20 lab environment's domain) - the master plan (section 2.2) explicitly commits this capstone to its own domain and Terraform state, independent of that lab environment.
    OUPath  = ""
    User    = var.admin_username
    Restart = "true"
    Options = "3"
  })

  protected_settings = jsonencode({
    Password = var.admin_password
  })
}

resource "azurerm_virtual_machine_extension" "avd_agent" {
  for_each = local.session_host_instances

  name                       = "avdAgentRegistration"
  virtual_machine_id         = azurerm_windows_virtual_machine.session_host[each.key].id
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.83"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    modulesUrl            = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_1.0.02790.446.zip" # [VERIFY BEFORE IMPLEMENTATION] same caveat carried since Lab 8 - Microsoft has changed this URL before without a redirect
    configurationFunction = "Configuration.ps1\\AddSessionHost"
    properties = {
      HostPoolName = azurerm_virtual_desktop_host_pool.persona[each.value.persona_key].name
    }
  })

  protected_settings = jsonencode({
    properties = {
      registrationInfoToken = azurerm_virtual_desktop_host_pool_registration_info.persona[each.value.persona_key].token
    }
  })

  depends_on = [azurerm_virtual_machine_extension.domain_join]
}
