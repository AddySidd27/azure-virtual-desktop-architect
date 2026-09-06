output "roles_built" {
  description = "Confirms which AVD-specific roles have actual Terraform, and their correct type - see Part E section 7 for End User's deliberate exclusion"
  value = {
    avd_platform_engineer = "PIM-eligible"
    session_host_operator = "PIM-eligible"
    service_desk          = "standing (deliberate)"
    end_user              = "not built - Part F"
  }
}
