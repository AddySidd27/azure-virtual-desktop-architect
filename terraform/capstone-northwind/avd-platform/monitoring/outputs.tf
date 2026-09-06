output "workspace_id" {
  value = azurerm_log_analytics_workspace.avd_regional.id
}

output "workspace_customer_id" {
  value = azurerm_log_analytics_workspace.avd_regional.workspace_id
}
