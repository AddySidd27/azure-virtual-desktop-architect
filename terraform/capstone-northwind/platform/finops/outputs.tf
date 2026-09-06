output "budget_ids" {
  value = {
    identity     = azurerm_consumption_budget_subscription.identity.id
    connectivity = azurerm_consumption_budget_subscription.connectivity.id
    management   = azurerm_consumption_budget_subscription.management.id
    avd_prod     = azurerm_consumption_budget_subscription.avd_prod.id
    avd_nonprod  = azurerm_consumption_budget_subscription.avd_nonprod.id
  }
}
