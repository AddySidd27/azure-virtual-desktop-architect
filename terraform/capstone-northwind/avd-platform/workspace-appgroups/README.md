# Capstone Part F - Workspace and Application Groups

Terraform for [Part F](../../../../capstone/parts/part-f-avd-platform-architecture.md).

One workspace per region (Chapter 3's location rule), five application groups
per region (one per persona), and the **End User RBAC role** - explicitly
deferred from [`avd-landing-zone/rbac`](../../avd-landing-zone/rbac/) in Part E
because its correct scope, these specific application groups, did not exist
until now.

## Apply once per region

Matches `host-pools`'s own pattern exactly - this is not a `for_each` over
regions, it's the same module applied twice with different variables, so the
two regions' workspaces and application groups stay structurally independent.

## Dependency

Requires `host-pools`'s `host_pool_ids` output for the same region, and real
Entra group object IDs for each persona's End User assignment - **these must
be non-overlapping between regions**, the same discipline Labs 11-20 already
proved: a user assigned to both regions' application groups for the same
persona would see a duplicate feed and risk the FSLogix lock-violation
failure mode Lab 15 documented.

## Cost

**$0.00.** Workspaces, application groups, and role assignments carry no
direct charge.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # edit for eastus2 first, with real host pool IDs and group object IDs
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

> This Terraform has not been run against a live Azure subscription.
