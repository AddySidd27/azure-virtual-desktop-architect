variable "tenant_root_management_group_id" {
  description = "The Azure AD tenant's root management group ID (usually the tenant ID itself, or found via 'az account management-group list')"
  type        = string
}

# Subscription IDs are taken as INPUT, not created by this module.
# Subscription creation is a billing-account action (Enterprise Agreement
# or Microsoft Customer Agreement) outside Terraform's scope in a real
# tenant. This module's job is placing existing subscriptions into the
# correct governance position, not creating them. See Part B, section 2.2.
variable "identity_subscription_id" {
  description = "Subscription ID for sub-northwind-identity. Must already exist."
  type        = string
}

variable "management_subscription_id" {
  description = "Subscription ID for sub-northwind-management. Must already exist."
  type        = string
}

variable "connectivity_subscription_id" {
  description = "Subscription ID for sub-northwind-connectivity. Must already exist."
  type        = string
}
