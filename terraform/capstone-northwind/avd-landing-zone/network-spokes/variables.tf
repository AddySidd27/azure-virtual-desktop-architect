############################################
# corp_management_group_id, the eastus2/westeurope hub VNet IDs,
# resource groups, and names are now resolved via
# terraform_remote_state (remote-state.tf), per Part G section 2.
############################################

variable "platform_state_resource_group" {
  type    = string
  default = "rg-tfstate-platform-01"
}

variable "platform_state_storage_account" {
  type    = string
  default = "sttfstatenwplat01"
}

variable "avd_prod_subscription_id" {
  description = "sub-northwind-avd-prod. Assumed to already exist as a billing entity - this module associates it, does not create it. See Part E, section 3."
  type        = string
}

variable "avd_nonprod_subscription_id" {
  type = string
}

variable "environment" {
  type    = string
  default = "prd"
}

variable "eastus2_avd_address_space" {
  description = "AVD spoke, East US 2"
  type        = list(string)
  default     = ["10.120.0.0/22"]
}

variable "westeurope_avd_address_space" {
  type    = list(string)
  default = ["10.121.0.0/22"]
}

variable "owner" {
  type = string
}

variable "cost_centre" {
  type = string
}
