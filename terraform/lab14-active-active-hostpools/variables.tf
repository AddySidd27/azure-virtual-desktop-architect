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

variable "host_count" {
  description = "Number of session hosts to deploy in this region"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "Session host VM size, matching Lab 8's sizing"
  type        = string
  default     = "Standard_D2s_v5"
}

variable "admin_username" {
  description = "Local administrator username for session hosts"
  type        = string
  default     = "avdlabadmin"
}

variable "admin_password" {
  description = "Local administrator password for session hosts. 12 to 123 characters, three of: lowercase, uppercase, digit, special."
  type        = string
  sensitive   = true
}

variable "domain_join_username" {
  description = "Domain account used for the JsonADDomainExtension domain join, in UPN format"
  type        = string
  default     = "avdlabadmin@avdlab.local"
}

variable "max_session_limit" {
  description = "Maximum concurrent sessions per session host in this pool"
  type        = number
  default     = 8
}

variable "avd_users_group_object_id" {
  description = "Entra ID object ID of the group assigned to the centralus desktop application group. See Lab 16 for the non-overlapping group design this feeds into."
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
