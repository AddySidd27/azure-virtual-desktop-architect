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

variable "log_retention_days" {
  description = "Log Analytics retention, matching Lab 10's default"
  type        = number
  default     = 30
}

variable "deploy_firewall" {
  description = "Deploy a full Azure Firewall for centralus egress control. Costs roughly 900 USD/month running regardless of traffic. Default false: this lab uses NSG-only egress control for lab purposes, matching the pattern already established in Lab 11's NSGs. Set true only if you specifically want to exercise the Firewall pattern and understand the cost."
  type        = bool
  default     = false
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
