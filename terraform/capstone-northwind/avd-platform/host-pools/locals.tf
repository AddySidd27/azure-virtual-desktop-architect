locals {
  common_tags = {
    BusinessUnit = "Northwind"
    Environment  = var.environment
    Region       = var.location
  }

  # Resolved via terraform_remote_state (remote-state.tf), per Part G
  # section 2 - region-specific outputs picked from network-spokes'
  # single, both-regions state.
  avd_resource_group      = var.location == "eastus2" ? data.terraform_remote_state.avdlz_network_spokes.outputs.eastus2_avd_resource_group : data.terraform_remote_state.avdlz_network_spokes.outputs.westeurope_avd_resource_group
  avd_hosts_subnet_id     = var.location == "eastus2" ? data.terraform_remote_state.avdlz_network_spokes.outputs.eastus2_avd_hosts_subnet_id : data.terraform_remote_state.avdlz_network_spokes.outputs.westeurope_avd_hosts_subnet_id
  eastus2_dc_ip           = data.terraform_remote_state.platform_identity.outputs.eastus2_dc_private_ips[0]
  westeurope_dc_ip        = data.terraform_remote_state.platform_identity.outputs.westeurope_dc_private_ips[0]
  monitoring_workspace_id = data.terraform_remote_state.platform_monitoring.outputs.workspace_id

  # Regional user count and host count, derived from the placeholder
  # split above. ceil() ensures a persona with a small regional
  # allocation still gets at least one host, not zero.
  regional_personas = {
    for k, v in var.personas : k => {
      type           = v.type
      vm_size        = v.vm_size
      regional_users = ceil(v.total_users * var.regional_split_percent / 100)
      host_count     = max(1, ceil(ceil(v.total_users * var.regional_split_percent / 100) / v.users_per_host))
    }
  }

  # DNS order: this region's DC primary, the other region's DC
  # secondary - matching Part C's identity design exactly, never a
  # single-region-only DNS path.
  dns_servers = var.location == "eastus2" ? [local.eastus2_dc_ip, local.westeurope_dc_ip] : [local.westeurope_dc_ip, local.eastus2_dc_ip]
}
