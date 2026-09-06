variable "location" {
  description = "DR region - deliberately a THIRD region, not centralus. centralus already hosts Lab 14's active production host pool; a DR target for eastus2 must live somewhere that does not share eastus2's or centralus's own regional failure domain. See the lab markdown for the full reasoning."
  type        = string
  default     = "westus2"
}

variable "location_short" {
  description = "Short region code used in resource names"
  type        = string
  default     = "wus2"
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

variable "deploy_active" {
  description = "Whether the DR session hosts are created in a running state. False (default) matches the warm-standby cost model: hosts exist but are deallocated until a failover is actually declared. Set true only during an active failover exercise."
  type        = bool
  default     = false
}

variable "host_count" {
  description = "Number of DR session hosts. Deliberately smaller than Lab 14's active pools - a capacity reservation for the SKU covers the gap during a real failover, matching Project 14's reduced-capacity DR reasoning."
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "DR session host VM size, matching Lab 8/14's sizing so a failed-over user's experience is comparable, not degraded by a smaller SKU"
  type        = string
  default     = "Standard_D2s_v5"
}

variable "admin_username" {
  description = "Local administrator username for DR session hosts"
  type        = string
  default     = "avdlabadmin"
}

variable "admin_password" {
  description = "Local administrator password for DR session hosts. 12 to 123 characters, three of: lowercase, uppercase, digit, special."
  type        = string
  sensitive   = true
}

variable "enable_capacity_reservation" {
  description = "Whether to create an on-demand capacity reservation for the DR VM SKU in westus2. Default false: cost-conscious by default, matching this lab set's general posture. An on-demand capacity reservation bills at the full rate of the reserved VM size continuously from the moment it is created, whether or not a matching VM is ever deployed against it (confirmed against learn.microsoft.com/azure/virtual-machines/capacity-reservation-overview) - this is a real, ongoing cost, not a contingent one, and is not enabled by default for that reason. Set true only if your organisation has assessed and accepted that cost in exchange for improved capacity assurance during a real regional-capacity-constrained failover. See the lab markdown's capacity reservation section for the full cost breakdown."
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
