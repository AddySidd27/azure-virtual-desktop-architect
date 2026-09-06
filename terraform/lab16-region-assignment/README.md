# Lab 16 - User-to-Region Assignment

Terraform for [Lab 16](../../labs/lab-16-user-region-assignment.md).

Creates two Entra security groups per user population (`grp-avdlab-<population>-eus2`
and `grp-avdlab-<population>-cus`), each scoped via role assignment to exactly one
region's desktop application group. Deliberately builds the group *objects* and the
*scoping*, not membership - who belongs in which region is a business decision this
lab does not automate.

## Cost

**$0.00.** Entra ID group objects and role assignments carry no direct Azure charge
at this scale.

## Dependency on Labs 7 and 14

Reads Lab 7's state for the `eastus2` application group ID (added as a new output -
see the note in `terraform/lab07-avd-core/README.md` if you built Lab 7 before this
lab existed) and Lab 14's state for the `centralus` application group ID.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # edit owner, populations, primary_state_storage_account
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

## Adding a population

Edit the `populations` variable and re-apply. `local.region_groups` builds both
regions' groups from that list automatically via `setproduct`, so adding
`"engineering"` creates `grp-avdlab-engineering-eus2` and
`grp-avdlab-engineering-cus` without touching any resource block.
