variable "management_subscription_id" {
  description = "sub-northwind-management subscription ID, from Part B - Key Vault lives here"
  type        = string
}

variable "environment" {
  type    = string
  default = "prd"
}

variable "tenant_id" {
  type = string
}

variable "eastus2_hub_resource_group" {
  description = "Output from the connectivity module (Part C)"
  type        = string
}

variable "westeurope_hub_resource_group" {
  description = "Output from the connectivity module (Part C)"
  type        = string
}

variable "eastus2_hub_vnet_name" {
  type = string
}

variable "westeurope_hub_vnet_name" {
  type = string
}

variable "dc_admin_username" {
  description = "The admin username used for the domain controllers built in Part C - stored here, referenced there"
  type        = string
}

variable "dc_admin_password" {
  type      = string
  sensitive = true
}

variable "connect_sync_service_account_username" {
  type = string
}

variable "connect_sync_service_account_password" {
  type      = string
  sensitive = true
}

variable "owner" {
  type = string
}

variable "cost_centre" {
  type = string
}

variable "break_glass_account_count" {
  description = "Microsoft's documented guidance is two break-glass accounts, per Part D section 4.4"
  type        = number
  default     = 2
}

variable "break_glass_domain" {
  description = "Verified domain for the break-glass accounts, e.g. the tenant's onmicrosoft.com domain"
  type        = string
}
