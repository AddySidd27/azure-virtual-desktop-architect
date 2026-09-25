# Capstone Part F - FSLogix Storage

Terraform for [Part F](../../../../capstone/parts/part-f-avd-platform-architecture.md).

One FSLogix storage account per region, Premium tier, ZRS replication (the
only two options Premium file shares support), Private Endpoint only,
matching [Lab 5](../../../../labs/lab-05-storage.md)/[Lab 13](../../../../labs/lab-13-regional-storage-foundation.md)'s
proven pattern exactly.

## Finance isolation, per ADR-CAP-06

A design review found finance
sharing one storage account, share, and RBAC group with the other four
personas, despite Chapter 15's host-pool-level isolation requirement. See
[ADR-CAP-06](../../../../capstone/adr/adr-cap-06-finance-fslogix-isolation.md)
for the full decision:

- **RBAC split - adopted unconditionally, built in this pass.** Finance now
  has its own share-level RBAC group (`finance_users_group_object_id`),
  separate from the other four personas' combined group
  (`non_finance_users_group_object_id`).
- **Dedicated storage account - BUSINESS/COMPLIANCE DECISION REQUIRED, not
  adopted by default.** File-level isolation (Chapter 20's two-layer
  permission model) already protects individual profiles regardless of
  storage layout. `enable_finance_dedicated_storage` defaults `false`. If
  Northwind's compliance function confirms storage-account-level segregation
  is required beyond SOX's technical ITGC scope, set this `true` - the
  Terraform is fully built and ready, gated behind one variable.

## What this does NOT build

**Cloud Cache registry configuration** - host-level, applied after session
hosts exist (Part F's `host-pools` module), matching
[Lab 15](../../../../labs/lab-15-cloud-cache-replication.md)'s established
pattern. **NTFS permissions** (layer two of Chapter 20's two-layer model) -
also a host-side, post-domain-join step, not Terraform.

## A genuinely different Cloud Cache design from Labs 11-20

Labs 11-20 used Cloud Cache for active-active user mobility - the same user
eligible to sign in from either region. Northwind's users are
geography-assigned (Part C's whole design), not active-active-eligible, so
here Cloud Cache provides resilience against a single-region storage
failure only. This is a real design difference, not a smaller version of the
same thing - see the master plan, Part F4.

## Disclosed accuracy gap

`file_share_quota_gb` is sized only from Chapter 20's task-worker worked
example (32,000 peak IOPS at the sign-in burst). The other four personas
(knowledge, finance, CAD, developers) have never had a published sizing
worked example in this book - the default here is a reasonable placeholder,
not a confirmed calculation for those four personas specifically.

## Cost

Premium file share billed on provisioned capacity - confirm current pricing
via the Azure Pricing Calculator at the quota you actually set.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # edit for eastus2 first
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

> This Terraform has not been run against a live Azure subscription.
