# Terraform - Lab 5: Profile Storage

Creates the Azure Files premium share used for FSLogix profile containers, following the two-layer permission model and the redundancy decision covered in [Chapter 20](../../chapters/ch20-profile-storage-architecture.md).

**Depends on:** Lab 2 (resource groups), Lab 3 (VNet, storage subnet), Lab 4 (domain controller, used for AD-based Kerberos authentication and DNS).

**Creates:** one Premium `FileStorage` account (ZRS), one file share, one private endpoint, one private DNS zone linked to the lab VNet.

**Consumed by:** Lab 6 (FSLogix configuration points at `vhd_location_unc_path`).

```bash
cd terraform/lab05-storage
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

See [labs/lab-05-storage.md](../../labs/lab-05-storage.md) for the full walkthrough, validation steps, and the manual AD-join step this Terraform cannot perform for you (`Join-AzStorageAccountForAuth` requires a domain-joined session, not the Terraform provider).
