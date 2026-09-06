output "log_analytics_workspace_name" {
  value = azurerm_log_analytics_workspace.avd.name
}
output "scaling_plan_name" {
  value = azurerm_virtual_desktop_scaling_plan.lab.name
}
