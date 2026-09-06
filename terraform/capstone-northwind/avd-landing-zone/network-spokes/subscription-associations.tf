############################################
# Associates the two AVD subscriptions into the Corp management
# group Part B reserved, empty, for exactly this. This is the step
# that makes Part B's tenant-wide policies (tags, allowed regions,
# diagnostics) apply to these subscriptions automatically, per ARM's
# own inheritance mechanism - see Part E, section 3.
#
# Does NOT create the subscriptions themselves - same boundary as
# platform/management-groups for the three platform subscriptions.
############################################

resource "azurerm_management_group_subscription_association" "avd_prod" {
  management_group_id = local.corp_management_group_id
  subscription_id     = "/subscriptions/${var.avd_prod_subscription_id}"
}

resource "azurerm_management_group_subscription_association" "avd_nonprod" {
  management_group_id = local.corp_management_group_id
  subscription_id     = "/subscriptions/${var.avd_nonprod_subscription_id}"
}
