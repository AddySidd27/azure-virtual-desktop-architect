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
