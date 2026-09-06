############################################
# Domain controller - centralus
#
# An additional domain controller for the existing avdlab.local forest,
# not a new domain and not a new forest. Lab 4 already ran
# Install-ADDSForest; this VM runs Install-ADDSDomainController instead,
# joining the forest Lab 4 created.
############################################

resource "azurerm_network_interface" "dc" {
  name                = "nic-avdlab-dc02"
  location            = var.location
  resource_group_name = data.terraform_remote_state.lab11_network.outputs.resource_group_names.identity

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.lab11_network.outputs.subnet_ids.identity
    private_ip_address_allocation = "Static"
    private_ip_address            = var.dc_private_ip
  }

  tags = local.common_tags
}

resource "azurerm_windows_virtual_machine" "dc" {
  name                  = "vm-avdlab-dc02"
  computer_name         = "AVDLAB-DC02" # 15 character NetBIOS limit, same constraint as Lab 4's DC01
  location              = var.location
  resource_group_name   = data.terraform_remote_state.lab11_network.outputs.resource_group_names.identity
  size                  = var.dc_vm_size
  admin_username        = var.dc_admin_username
  admin_password        = var.dc_admin_password
  network_interface_ids = [azurerm_network_interface.dc.id]

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
