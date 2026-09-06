############################################
# One budget per platform subscription, per Part B section 2.9's
# original design. Every figure here is a PLACEHOLDER - see the
# variables.tf note and Part A's open-gaps disclosure: no real
# on-premises baseline cost has ever been gathered for this
# engagement, so there is no real number to size these against yet.
# Building the budget MECHANISM now, with honest placeholder figures,
# is what lets Northwind correct the numbers later without having to
# build the governance capability from scratch when they do.
############################################

resource "azurerm_consumption_budget_subscription" "identity" {
  name            = "budget-identity-${var.identity_subscription_id}"
  subscription_id = "/subscriptions/${var.identity_subscription_id}"
  amount          = var.identity_monthly_budget
  time_grain      = "Monthly"

  time_period {
    start_date = var.budget_start_date
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThan"
    contact_emails = [var.budget_alert_email]
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    contact_emails = [var.budget_alert_email]
  }
}

resource "azurerm_consumption_budget_subscription" "connectivity" {
  name            = "budget-connectivity-${var.connectivity_subscription_id}"
  subscription_id = "/subscriptions/${var.connectivity_subscription_id}"
  amount          = var.connectivity_monthly_budget
  time_grain      = "Monthly"

  time_period {
    start_date = var.budget_start_date
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThan"
    contact_emails = [var.budget_alert_email]
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    contact_emails = [var.budget_alert_email]
  }
}

resource "azurerm_consumption_budget_subscription" "management" {
  name            = "budget-management-${var.management_subscription_id}"
  subscription_id = "/subscriptions/${var.management_subscription_id}"
  amount          = var.management_monthly_budget
  time_grain      = "Monthly"

  time_period {
    start_date = var.budget_start_date
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThan"
    contact_emails = [var.budget_alert_email]
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    contact_emails = [var.budget_alert_email]
  }
}

############################################
# AVD subscription budgets - added in Part H5, closing the "rolling
# up into B10" requirement the master plan states for FinOps. Until
# now, only the three platform subscriptions had budgets; the two AVD
# subscriptions Part F/E actually built resources in had none.
############################################

resource "azurerm_consumption_budget_subscription" "avd_prod" {
  name            = "budget-avd-prod-${var.avd_prod_subscription_id}"
  subscription_id = "/subscriptions/${var.avd_prod_subscription_id}"
  amount          = var.avd_prod_monthly_budget
  time_grain      = "Monthly"

  time_period {
    start_date = var.budget_start_date
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThan"
    contact_emails = [var.budget_alert_email]
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    contact_emails = [var.budget_alert_email]
  }
}

resource "azurerm_consumption_budget_subscription" "avd_nonprod" {
  name            = "budget-avd-nonprod-${var.avd_nonprod_subscription_id}"
  subscription_id = "/subscriptions/${var.avd_nonprod_subscription_id}"
  amount          = var.avd_nonprod_monthly_budget
  time_grain      = "Monthly"

  time_period {
    start_date = var.budget_start_date
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThan"
    contact_emails = [var.budget_alert_email]
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    contact_emails = [var.budget_alert_email]
  }
}
