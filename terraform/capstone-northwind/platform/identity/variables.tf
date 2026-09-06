variable "identity_subscription_id" {
  description = "sub-northwind-identity subscription ID, from Part B"
  type        = string
}

variable "environment" {
  type    = string
  default = "prd"
}

variable "eastus2_spoke_address_space" {
  description = "East US 2 identity spoke, peered to the East US 2 hub"
  type        = list(string)
  default     = ["10.110.0.0/24"]
}

variable "westeurope_spoke_address_space" {
  description = "West Europe identity spoke, peered to the West Europe hub"
  type        = list(string)
  default     = ["10.111.0.0/24"]
}

variable "eastus2_hub_vnet_id" {
  description = "Output from the connectivity module - East US 2 hub VNet ID, for peering"
  type        = string
}

variable "westeurope_hub_vnet_id" {
  description = "Output from the connectivity module - West Europe hub VNet ID, for peering"
  type        = string
}

variable "eastus2_hub_resource_group" {
  type = string
}

variable "westeurope_hub_resource_group" {
  type = string
}

variable "eastus2_hub_vnet_name" {
  type = string
}

variable "westeurope_hub_vnet_name" {
  type = string
}

variable "eastus2_firewall_private_ip" {
  description = "Output from the connectivity module - used as the UDR next hop for spoke egress"
  type        = string
}

variable "westeurope_firewall_private_ip" {
  description = "Output from the connectivity module - used as the UDR next hop for spoke egress"
  type        = string
}

variable "dc_vm_size" {
  description = "Matches the sizing reasoning already established in Lab 4/Lab 12 - do not size a production DC this way without your own capacity review"
  type        = string
  default     = "Standard_D2s_v5"
}

variable "admin_username" {
  type    = string
  default = "northwindadmin"
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "owner" {
  type = string
}

variable "cost_centre" {
  type = string
}
