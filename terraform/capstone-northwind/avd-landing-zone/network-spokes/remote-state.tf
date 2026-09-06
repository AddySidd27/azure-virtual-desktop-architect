data "terraform_remote_state" "platform_management_groups" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.platform_state_resource_group
    storage_account_name = var.platform_state_storage_account
    container_name       = "tfstate"
    key                  = "platform-management-groups.tfstate"
  }
}

data "terraform_remote_state" "platform_connectivity" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.platform_state_resource_group
    storage_account_name = var.platform_state_storage_account
    container_name       = "tfstate"
    key                  = "platform-connectivity.tfstate"
  }
}

locals {
  corp_management_group_id      = data.terraform_remote_state.platform_management_groups.outputs.corp_management_group_id
  eastus2_hub_vnet_id           = data.terraform_remote_state.platform_connectivity.outputs.eastus2_hub_vnet_id
  westeurope_hub_vnet_id        = data.terraform_remote_state.platform_connectivity.outputs.westeurope_hub_vnet_id
  eastus2_hub_resource_group    = data.terraform_remote_state.platform_connectivity.outputs.eastus2_hub_resource_group
  westeurope_hub_resource_group = data.terraform_remote_state.platform_connectivity.outputs.westeurope_hub_resource_group
  eastus2_hub_vnet_name         = data.terraform_remote_state.platform_connectivity.outputs.eastus2_hub_vnet_name
  westeurope_hub_vnet_name      = data.terraform_remote_state.platform_connectivity.outputs.westeurope_hub_vnet_name
}
