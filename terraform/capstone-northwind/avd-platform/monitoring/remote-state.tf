data "terraform_remote_state" "avdplt_host_pools" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.avdplt_state_resource_group
    storage_account_name = var.avdplt_state_storage_account
    container_name       = "tfstate"
    key                  = var.host_pools_state_key
  }
}

locals {
  host_pool_ids = data.terraform_remote_state.avdplt_host_pools.outputs.host_pool_ids
}
