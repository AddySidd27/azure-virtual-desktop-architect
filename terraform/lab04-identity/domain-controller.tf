############################################
# Lab domain controller
#
# No public IP. All configuration is done with
# az vm run-command. See Lab 4 for the commands.
############################################

resource "azurerm_network_interface" "dc" {
  name                = "nic-avdlab-dc01"
  location            = var.location
  resource_group_name = var.identity_resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.identity.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.dc_private_ip
  }

  tags = local.common_tags
}

resource "azurerm_windows_virtual_machine" "dc" {
  name                = "vm-avdlab-dc01"
  computer_name       = "AVDLAB-DC01" # 15 character NetBIOS limit
  location            = var.location
  resource_group_name = var.identity_resource_group_name
  size                = var.dc_vm_size
  admin_username      = var.dc_admin_username
  admin_password      = var.dc_admin_password

  network_interface_ids = [
    azurerm_network_interface.dc.id,
  ]

  os_disk {
    name                 = "osdisk-avdlab-dc01"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS" # Premium is unnecessary for a lab DC
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  # Keep the VM stable across applies. Image version changes should be a
  # deliberate decision, not a side effect of running terraform apply.
  lifecycle {
    ignore_changes = [
      source_image_reference,
    ]
  }

  tags = local.common_tags
}
