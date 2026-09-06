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

variable "storage_resource_group_name" {
  description = "Resource group created in Lab 2 for storage resources"
  type        = string
  default     = "rg-avd-storage-lab-eus2-01"
}

variable "network_resource_group_name" {
  description = "Resource group holding the VNet created in Lab 3"
  type        = string
  default     = "rg-avd-network-lab-eus2-01"
}

variable "vnet_name" {
  description = "VNet created in Lab 3"
  type        = string
  default     = "vnet-avd-lab-eus2-01"
}

variable "storage_subnet_name" {
  description = "Subnet created in Lab 3 for storage private endpoints"
  type        = string
  default     = "snet-storage-lab-eus2-01"
}

variable "file_share_quota_gb" {
  description = "Provisioned quota for the FSLogix profile share, in GiB. Sized small deliberately for the lab; see the chapter for production sizing from the sign-in burst."
  type        = number
  default     = 100
}

variable "avd_users_group_object_id" {
  description = "Entra ID object ID of the group whose members will store profiles on this share. Created in Lab 4 or your own tenant."
  type        = string
}
