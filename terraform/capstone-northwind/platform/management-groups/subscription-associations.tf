############################################
# Subscription associations
#
# Moves the three EXISTING platform subscriptions into their correct
# management group. Does not create subscriptions - see variables.tf.
############################################

resource "azurerm_management_group_subscription_association" "identity" {
  management_group_id = azurerm_management_group.identity.id
  subscription_id     = "/subscriptions/${var.identity_subscription_id}"
}

resource "azurerm_management_group_subscription_association" "management" {
  management_group_id = azurerm_management_group.management.id
  subscription_id     = "/subscriptions/${var.management_subscription_id}"
}

resource "azurerm_management_group_subscription_association" "connectivity" {
  management_group_id = azurerm_management_group.connectivity.id
  subscription_id     = "/subscriptions/${var.connectivity_subscription_id}"
}

# NOT created: an association for sub-northwind-avd-prod or
# sub-northwind-avd-nonprod into Corp. Those subscriptions do not
# exist yet - they are Part E's deliverable. See Part B, section 2.2.
