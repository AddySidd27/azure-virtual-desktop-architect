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

variable "file_share_quota_gb" {
  description = "Provisioned quota for the centralus FSLogix profile share, in GiB. Matches Lab 5's size for consistency; Lab 15 sizes this properly once Cloud Cache replication behaviour is understood."
  type        = number
  default     = 100
}

variable "avd_users_group_object_id" {
  description = "Entra ID object ID of the group whose members will store profiles on this share. Same group as Lab 5 - profiles replicate between regions in Lab 15, so the same users need access to both shares."
  type        = string
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
