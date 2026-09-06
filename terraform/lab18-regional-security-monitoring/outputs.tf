output "workspace_name" {
  description = "centralus Log Analytics workspace name"
  value       = azurerm_log_analytics_workspace.centralus.name
}

output "workspace_id" {
  description = "centralus Log Analytics workspace resource ID, used by the cross-workspace dashboard query"
  value       = azurerm_log_analytics_workspace.centralus.id
}

output "workspace_customer_id" {
  description = "centralus workspace Customer ID (GUID), used in the KQL cross-workspace() function"
  value       = azurerm_log_analytics_workspace.centralus.workspace_id
}

output "firewall_deployed" {
  description = "Whether the optional, cost-heavy Firewall was deployed this apply"
  value       = var.deploy_firewall
}
