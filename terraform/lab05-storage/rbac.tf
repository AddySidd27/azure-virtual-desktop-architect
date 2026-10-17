# NOTE: this assignment only takes effect for identities that exist in Microsoft
# Entra ID (hybrid synced or cloud-only with Entra Kerberos). Lab 4 does not sync
# its .local domain, so for AD-only test users use a default share-level
# permission instead (labs/lab-05-storage.md Step 3). See U30.
# Share-level RBAC. This is layer one of the two-layer permission model
# covered in the lab and in ch20. Layer two (NTFS) is applied inside the
# share after the domain controller can authenticate to it, in Step 4.
resource "azurerm_role_assignment" "avd_users_share_rbac" {
  scope                = "${azurerm_storage_account.fslogix.id}/fileServices/default/fileshares/${azurerm_storage_share.profiles.name}"
  role_definition_name = "Storage File Data SMB Share Contributor"
  principal_id         = var.avd_users_group_object_id
}
