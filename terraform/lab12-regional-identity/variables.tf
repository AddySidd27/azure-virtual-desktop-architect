variable "location" {
  description = "Secondary Azure region for the multi-region build"
  type        = string
  default     = "centralus"
}

variable "location_short" {
  description = "Short region code used in resource names"
  type        = string
  default     = "cus"
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

variable "dc_private_ip" {
  description = "Static private IP for the centralus domain controller. Becomes the centralus VNet's primary DNS server, and eastus2's secondary. Must not change once set."
  type        = string
  default     = "10.20.1.4"
}

variable "dc_vm_size" {
  description = "VM size for the lab domain controller. B2s is around 30 USD per month running, matching Lab 4's sizing. Do not size a production DC this way."
  type        = string
  default     = "Standard_B2s"
}

variable "dc_admin_username" {
  description = "Local administrator username for the domain controller"
  type        = string
  default     = "avdlabadmin"
}

variable "dc_admin_password" {
  description = "Local administrator password. 12 to 123 characters, three of: lowercase, uppercase, digit, special. Use the same value you used in Lab 4 if you want one credential to remember, though the two VMs' local accounts are independent."
  type        = string
  sensitive   = true
}

variable "primary_state_resource_group" {
  description = "Resource group holding the Terraform state storage account used by every lab's backend"
  type        = string
  default     = "rg-tfstate-lab-eus2-01"
}

variable "primary_state_storage_account" {
  description = "Storage account name holding Terraform state for every lab in this book"
  type        = string
}
