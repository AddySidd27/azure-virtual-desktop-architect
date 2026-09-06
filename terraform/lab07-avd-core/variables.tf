variable "location" {
  type    = string
  default = "eastus2"
}

variable "location_short" {
  type    = string
  default = "eus2"
}

variable "environment" {
  type    = string
  default = "lab"
}

variable "owner" {
  type = string
}

variable "deletion_date" {
  type    = string
  default = "2026-12-31"
}

variable "service_resource_group_name" {
  description = "Resource group created in Lab 2 for AVD control-plane objects (host pool, workspace, application group)"
  type        = string
  default     = "rg-avd-service-lab-eus2-01"
}

variable "max_session_limit" {
  description = "Sessions per host. Lab default is low deliberately; production sizing comes from measurement, see Chapter 17"
  type        = number
  default     = 4
}

variable "avd_users_group_object_id" {
  description = "Entra ID group assigned Desktop Virtualization User on the application group"
  type        = string
}
