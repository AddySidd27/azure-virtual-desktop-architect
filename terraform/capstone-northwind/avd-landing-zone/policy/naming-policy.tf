############################################
# AVD host pool naming enforcement, assigned at the subscription
# level - narrower than Part B's tenant-wide policies, per Part B
# section 2.5's own stated boundary. A CUSTOM policy definition, not
# a built-in, since no built-in Azure Policy validates an
# organisation-specific naming pattern.
############################################

resource "azurerm_policy_definition" "host_pool_naming" {
  name         = "northwind-avd-hostpool-naming"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Northwind AVD host pool naming pattern"

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.DesktopVirtualization/hostPools"
        },
        {
          not = {
            field = "name"
            match = "hp-*-*-*-##"
          }
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })

  # [VERIFY BEFORE IMPLEMENTATION] Azure Policy's "match" condition
  # uses # and ? wildcards, not full regex - the pattern above is a
  # simplified approximation of the naming rule stated in
  # variables.tf's description. Confirm the exact match syntax against
  # current Azure Policy documentation before relying on this to
  # correctly enforce the five-persona naming pattern.
}

resource "azurerm_subscription_policy_assignment" "host_pool_naming" {
  name                 = "avd-hostpool-naming"
  display_name         = "Northwind AVD host pool naming pattern"
  policy_definition_id = azurerm_policy_definition.host_pool_naming.id
  subscription_id      = "/subscriptions/${var.avd_prod_subscription_id}"
}
