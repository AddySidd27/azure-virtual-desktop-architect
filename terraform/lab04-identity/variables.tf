variable "location" {
  description = "Primary Azure region for lab resources"
  type        = string
  default     = "eastus2"
}

variable "location_short" {
  description = "Short region code used in resource names"
  type        = string
  default     = "eus2"
}

variable "environment" {
  description = "Environment code: lab, dev, tst, prd"
  type        = string
  default     = "lab"
}

variable "owner" {
  description = "Email address of the resource owner"
  type        = string
}

variable "deletion_date" {
  description = "Date after which lab resources may be deleted (YYYY-MM-DD)"
  type        = string
  default     = "2026-12-31"
}

variable "identity_resource_group_name" {
  description = "Resource group created in Lab 2 for identity resources"
  type        = string
  default     = "rg-avd-identity-lab-eus2-01"
}

variable "network_resource_group_name" {
  description = "Resource group holding the VNet created in Lab 3"
  type        = string
  default     = "rg-avd-network-lab-eus2-01"
}

variable "vnet_name" {
  description = "Virtual network created in Lab 3"
  type        = string
  default     = "vnet-avd-lab-eus2-01"
}

variable "identity_subnet_name" {
  description = "Identity subnet created in Lab 3"
  type        = string
  default     = "snet-identity-lab-eus2-01"
}

variable "dc_private_ip" {
  description = "Static private IP for the domain controller. Becomes the VNet DNS server, so it must not change."
  type        = string
  default     = "10.10.1.4"
}

variable "dc_vm_size" {
  description = "VM size for the lab domain controller. B2s is around 30 USD per month running. Do not size a production DC this way."
  type        = string
  default     = "Standard_B2s"
}

variable "dc_admin_username" {
  description = "Local administrator username for the domain controller"
  type        = string
  default     = "avdlabadmin"
}

variable "dc_admin_password" {
  description = "Local administrator password. 12 to 123 characters, three of: lowercase, uppercase, digit, special."
  type        = string
  sensitive   = true
}
