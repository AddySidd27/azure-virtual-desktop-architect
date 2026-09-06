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

variable "network_resource_group_name" {
  description = "Resource group created in Lab 2 that holds network resources"
  type        = string
  default     = "rg-avd-network-lab-eus2-01"
}

variable "vnet_address_space" {
  description = "Address space for the AVD lab virtual network"
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "subnet_prefixes" {
  description = "CIDR blocks for each lab subnet. Sized for growth - see Lab 3 Step 1."
  type        = map(string)
  default = {
    identity = "10.10.1.0/24"
    hosts    = "10.10.2.0/23"
    storage  = "10.10.4.0/24"
    mgmt     = "10.10.5.0/24"
    bastion  = "10.10.250.0/26"
  }
}

variable "deploy_bastion_subnet" {
  description = "Create the AzureBastionSubnet. The subnet itself is free; Bastion is NOT deployed by this configuration."
  type        = bool
  default     = true
}
