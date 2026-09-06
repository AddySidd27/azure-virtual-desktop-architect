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
  type    = string
  default = "rg-avd-service-lab-eus2-01"
}
variable "host_pool_name" {
  description = "Host pool created in Lab 7. RemoteApp needs its own host pool per ch03/ch25 unless preferred_app_group_type is RemoteApp; the lab pool from Lab 7 is Desktop, so this module creates a second small pool for the RemoteApp path rather than fighting the preferred-type constraint."
  type        = string
  default     = "hp-avd-lab-eus2-01"
}
variable "avd_users_group_object_id" {
  type = string
}
