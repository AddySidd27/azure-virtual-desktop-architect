############################################
# Management group hierarchy
#
# Minimal by design - see Part B, section 4, for what Microsoft's
# reference structure includes that this deliberately does not build
# (Sandbox, Online) and why Decommissioned is kept despite that same
# discipline.
############################################

resource "azurerm_management_group" "northwind" {
  display_name               = "Northwind"
  parent_management_group_id = "/providers/Microsoft.Management/managementGroups/${var.tenant_root_management_group_id}"
}

resource "azurerm_management_group" "platform" {
  display_name               = "Platform"
  parent_management_group_id = azurerm_management_group.northwind.id
}

resource "azurerm_management_group" "identity" {
  display_name               = "Identity"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "management" {
  display_name               = "Management"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "connectivity" {
  display_name               = "Connectivity"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "landing_zones" {
  display_name               = "Landing Zones"
  parent_management_group_id = azurerm_management_group.northwind.id
}

# Reserved, empty. The AVD Landing Zone (Part E) associates its
# subscriptions here once it is built. No subscription is associated
# with this management group in this part - see Part B, section 2.2.
resource "azurerm_management_group" "corp" {
  display_name               = "Corp"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

# Kept, for the one specific reason stated in Part B section 4:
# a real place for pre-existing, ungoverned subscriptions related to
# the on-premises platform being replaced. Not a reference-architecture
# default - a documented, minimal exception to this design's own
# discipline against unused structure.
resource "azurerm_management_group" "decommissioned" {
  display_name               = "Decommissioned"
  parent_management_group_id = azurerm_management_group.northwind.id
}

# NOT created: "Online" landing zone, "Sandbox" management group.
# See Part B, section 4, for the reasoning.
