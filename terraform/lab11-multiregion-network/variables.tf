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

  validation {
    condition     = contains(["lab", "dev", "tst", "prd"], var.environment)
    error_message = "environment must be one of: lab, dev, tst, prd."
  }
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

variable "vnet_address_space" {
  description = "Address space for the centralus VNet. Must not overlap the eastus2 VNet (10.10.0.0/16, Lab 3) - peered VNets cannot have overlapping ranges."
  type        = list(string)
  default     = ["10.20.0.0/16"]
}

variable "subnet_prefixes" {
  description = "Subnet CIDR blocks inside the centralus VNet, mirroring Lab 3's eastus2 layout at the 10.20.0.0/16 offset"
  type        = map(string)
  default = {
    identity = "10.20.1.0/24"
    hosts    = "10.20.2.0/23"
    storage  = "10.20.4.0/24"
    mgmt     = "10.20.5.0/24"
  }
}

variable "primary_state_resource_group" {
  description = "Resource group holding the Terraform state storage account used by every lab's backend"
  type        = string
  default     = "rg-tfstate-lab-eus2-01"
}

variable "primary_state_storage_account" {
  description = "Storage account name holding Terraform state for Labs 1-10 and 11-20. Set this to match your own backend.tf values."
  type        = string
}
