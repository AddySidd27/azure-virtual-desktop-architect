############################################
# One workspace per region - Chapter 3's "location rule": a user's
# workspace matches their region, not a shared global one. This is
# the same reasoning Lab 14 already proved at lab scale, applied here
# to Northwind's real regions for the first time.
############################################

resource "azurerm_virtual_desktop_workspace" "regional" {
  name                = "ws-northwind-${var.environment}-${var.location_short}-01"
  location            = var.location
  resource_group_name = local.avd_resource_group
  friendly_name       = "Northwind - ${var.friendly_region_name}"
  description         = "Northwind desktop feed for ${var.friendly_region_name}. Distinct per region by design - see Chapter 3's location rule."

  tags = {
    BusinessUnit = "Northwind"
    Environment  = var.environment
    Region       = var.location
  }
}

############################################
# One Desktop application group per persona, per region
############################################

resource "azurerm_virtual_desktop_application_group" "persona" {
  for_each = toset(var.personas)

  name                = "ag-${each.value}-${var.environment}-${var.location_short}-01"
  location            = var.location
  resource_group_name = local.avd_resource_group
  host_pool_id        = local.host_pool_ids[each.value]
  type                = "Desktop"
  friendly_name       = "${each.value} desktop - ${var.friendly_region_name}"

  tags = {
    BusinessUnit = "Northwind"
    Environment  = var.environment
    Region       = var.location
  }
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "persona" {
  for_each = toset(var.personas)

  workspace_id         = azurerm_virtual_desktop_workspace.regional.id
  application_group_id = azurerm_virtual_desktop_application_group.persona[each.value].id
}

############################################
# End User role - explicitly deferred from Part E (avd-landing-zone/rbac),
# because its correct scope (these specific, persona-specific
# application groups) did not exist until now. Built here, standing,
# not PIM-eligible - a user does not "activate" the ability to use
# their own desktop, per Part E section 7's stated reasoning, applied
# here for the first time to a real application group rather than a
# forward reference.
############################################

resource "azurerm_role_assignment" "end_user" {
  for_each = toset(var.personas)

  scope                = azurerm_virtual_desktop_application_group.persona[each.value].id
  role_definition_name = "Desktop Virtualization User"
  principal_id         = var.end_user_principal_ids[each.value]
}
