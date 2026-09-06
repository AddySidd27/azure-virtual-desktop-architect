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

variable "autoscale_exclusion_tag_name" {
  description = "Tag name AVD's scaling plan checks to skip a session host. Any VM carrying this tag (any value) is never started, stopped, or otherwise touched by either region's scaling plan. Documented Microsoft behaviour, not a dedicated Terraform field - apply this tag directly to a VM resource when you need to exclude one."
  type        = string
  default     = "avd-autoscale-exclude"
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
