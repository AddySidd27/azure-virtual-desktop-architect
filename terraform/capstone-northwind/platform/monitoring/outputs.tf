output "workspace_id" {
  description = "Feed this into the policy module's log_analytics_workspace_id variable to complete the diagnostic-settings policy's target"
  value       = azurerm_log_analytics_workspace.platform.id
}

output "workspace_customer_id" {
  value = azurerm_log_analytics_workspace.platform.workspace_id
}
