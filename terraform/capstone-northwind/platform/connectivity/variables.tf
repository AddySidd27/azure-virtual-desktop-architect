variable "connectivity_subscription_id" {
  description = "sub-northwind-connectivity subscription ID, from Part B"
  type        = string
}

variable "environment" {
  type    = string
  default = "prd"
}

variable "eastus2_hub_address_space" {
  description = "East US 2 hub VNet, serving Chicago"
  type        = list(string)
  default     = ["10.100.0.0/22"]
}

variable "westeurope_hub_address_space" {
  description = "West Europe hub VNet, serving Amsterdam"
  type        = list(string)
  default     = ["10.101.0.0/22"]
}

variable "owner" {
  type = string
}

variable "cost_centre" {
  description = "Required by Part B's tag policy"
  type        = string
}
