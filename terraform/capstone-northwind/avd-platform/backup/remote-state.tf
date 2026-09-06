data "terraform_remote_state" "avdplt_fslogix" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.avdplt_state_resource_group
    storage_account_name = var.avdplt_state_storage_account
    container_name       = "tfstate"
    key                  = var.fslogix_state_key
  }
}
