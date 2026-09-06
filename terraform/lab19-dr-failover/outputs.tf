output "dr_host_pool_id" {
  value = azurerm_virtual_desktop_host_pool.dr.id
}

output "dr_application_group_id" {
  value = azurerm_virtual_desktop_application_group.dr_desktop.id
}

output "dr_session_host_names" {
  description = "Empty list when deploy_active = false, since count = 0 in that state"
  value       = azurerm_windows_virtual_machine.dr_host[*].name
}

output "eastus2_workspace_id_for_failover" {
  description = "The existing eastus2 workspace's application-group association is what the failover runbook re-points during a declared DR event"
  value       = "See terraform/lab07-avd-core outputs.workspace_name - not duplicated here to avoid a second, possibly stale copy of the same value"
}

output "capacity_reservation_group_id" {
  description = "Null when enable_capacity_reservation = false (the default). When set, this reservation bills continuously regardless of deploy_active - see session-hosts.tf's billing-states comment."
  value       = var.enable_capacity_reservation ? azurerm_capacity_reservation_group.dr[0].id : null
}

output "billing_state_summary" {
  description = "Human-readable summary of this apply's actual billing state, since deploy_active and enable_capacity_reservation combine into four distinct outcomes"
  value = format(
    "session hosts: %s | capacity reservation: %s",
    var.deploy_active ? "${var.host_count} deployed and running" : "0 deployed",
    var.enable_capacity_reservation ? "ENABLED - billing continuously" : "disabled - $0"
  )
}
