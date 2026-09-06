variable "avd_prod_subscription_id" {
  type = string
}

variable "environment" {
  type    = string
  default = "prd"
}

variable "location" {
  type = string
}

variable "location_short" {
  type = string
}

variable "friendly_region_name" {
  description = "Human-readable region name for the workspace, matching Chapter 3's 'location rule' - a user's workspace matches their region, not a shared global one"
  type        = string
}

############################################
# host_pool_ids is now resolved via terraform_remote_state
# (remote-state.tf), per Part G section 2. Since host-pools uses a
# PARTIAL backend config (applied per-region, key supplied at init
# time), this module needs to know which key to read - hence
# host_pools_state_key below, not a hardcoded value.
############################################

variable "avdplt_state_resource_group" {
  type    = string
  default = "rg-tfstate-avdplt-01"
}

variable "avdplt_state_storage_account" {
  type    = string
  default = "sttfstatenwavdplt01"
}

variable "host_pools_state_key" {
  description = "Must match the key used for THIS region's host-pools apply, e.g. avdplt-host-pools-eastus2.tfstate - see host-pools/backend.tf"
  type        = string
}

############################################
# avd_resource_group is the genuine cross-layer dependency this
# module has (avd-landing-zone -> avd-platform) - resolved via
# terraform_remote_state below, per Part G section 2.
############################################

variable "avdlz_state_resource_group" {
  type    = string
  default = "rg-tfstate-avdlz-01"
}

variable "avdlz_state_storage_account" {
  type    = string
  default = "sttfstatenwavdlz01"
}

variable "personas" {
  description = "Must match the host-pools module's persona keys exactly"
  type        = list(string)
  default     = ["task", "know", "fin", "cad", "dev"]
}

variable "end_user_principal_ids" {
  description = "Map of persona key to the Entra group object ID assigned as End User for that persona's application group, in THIS region only - the non-overlapping assignment model from Labs 11-20, applied here for the first time to a real workload"
  type        = map(string)
}
