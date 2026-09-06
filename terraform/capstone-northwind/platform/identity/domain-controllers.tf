############################################
# Domain controllers - two per region, per Part A/Chapter 7's existing
# decision. Joins the EXISTING on-premises forest - does not create a
# new forest or a new domain. Matches Lab 4/Lab 12's proven pattern.
############################################

resource "azurerm_network_interface" "eastus2_dc" {
  count               = 2
  name                = "nic-dc-${var.environment}-eus2-0${count.index + 1}"
  location            = azurerm_resource_group.eastus2.location
  resource_group_name = azurerm_resource_group.eastus2.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.eastus2_dc.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.110.0.${4 + count.index}"
  }

  tags = local.common_tags
}

resource "azurerm_windows_virtual_machine" "eastus2_dc" {
  count                 = 2
  name                  = "vm-dc-eus2-0${count.index + 1}"
  computer_name         = "NWDCEUS2${count.index + 1}"
  location              = azurerm_resource_group.eastus2.location
  resource_group_name   = azurerm_resource_group.eastus2.name
  size                  = var.dc_vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.eastus2_dc[count.index].id]

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

resource "azurerm_network_interface" "westeurope_dc" {
  count               = 2
  name                = "nic-dc-${var.environment}-weu-0${count.index + 1}"
  location            = azurerm_resource_group.westeurope.location
  resource_group_name = azurerm_resource_group.westeurope.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.westeurope_dc.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.111.0.${4 + count.index}"
  }

  tags = local.common_tags
}

resource "azurerm_windows_virtual_machine" "westeurope_dc" {
  count                 = 2
  name                  = "vm-dc-weu-0${count.index + 1}"
  computer_name         = "NWDCWEU${count.index + 1}"
  location              = azurerm_resource_group.westeurope.location
  resource_group_name   = azurerm_resource_group.westeurope.name
  size                  = var.dc_vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.westeurope_dc[count.index].id]

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

# [VERIFY BEFORE IMPLEMENTATION] Install-ADDSDomainController and
# Microsoft Entra Connect Sync installation are imperative
# post-deployment actions, matching Lab 4/Lab 12's pattern exactly -
# not declared here as Terraform resources. See Part C section 3-4
# for the documented steps.
