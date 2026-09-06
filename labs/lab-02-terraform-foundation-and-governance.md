> **Part of:** [Azure Virtual Desktop - Architect to Hands-on Implementation](../README.md)  
> **Chapter:** [Chapter 3](../chapters/ch03-avd-object-model.md)  
> **Technical baseline:** August 2026

# LAB 2 - Terraform Foundation, Resource Groups and Governance

> **LAB ARCHITECTURE** - the environment you build across Labs 1-20. Not a Microsoft reference design.

## Objective

Build the Terraform foundation everything else in this book sits on: remote state with locking, a consistent resource group layout, and enforced tagging. Get this right once and every later lab is a small addition rather than a rebuild.

## Cost summary

| Resource | Purpose | Monthly cost |
|---|---|---|
| Storage account (Standard LRS) | Terraform remote state | Under $1.00 - the state file is a few KB |
| Resource groups | Organisation | $0.00 - resource groups are free |
| **Total** | | **Under $1.00/month** |

**Cost if left running:** under $1.00/month.
**Recommendation:** keep it. Deleting the state storage account will break every later lab.
**Safe to delete later:** nothing from this lab, until you finish the book.

## Prerequisites

- Lab 1 complete, including the naming and tagging standards
- Terraform installed, AzureRM provider pinned
- Azure CLI authenticated to the correct subscription

---

## Step 1 - Create the Terraform state backend

Remote state is not optional. Local state on your laptop means no locking, no backup, and no way to work from a second machine. Bootstrap it with the CLI, because Terraform cannot store its own state before the storage exists.

```bash
# Variables - adjust the suffix to something globally unique
LOCATION="eastus2"
RG_STATE="rg-tfstate-lab-eus2-01"
SA_STATE="sttfstateavdlab$RANDOM"
CONTAINER="tfstate"

az group create \
  --name $RG_STATE \
  --location $LOCATION \
  --tags environment=lab workload=avd owner=your.name@domain.com costCenter=learning

az storage account create \
  --name $SA_STATE \
  --resource-group $RG_STATE \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false

az storage container create \
  --name $CONTAINER \
  --account-name $SA_STATE \
  --auth-mode login

echo "Storage account name: $SA_STATE"
```

**What this does:** creates a resource group, a locally redundant v2 storage account with public blob access disabled and TLS 1.2 minimum, and a private container for state files.

**Expected output:** JSON for each resource, then the generated storage account name. **Write that name down** - you need it in the next step.

**Common errors:**
- *Storage account name already taken.* Names are globally unique. Re-run to get a new random suffix.
- *AuthorizationPermissionMismatch on container create.* Your account needs **Storage Blob Data Contributor** on the storage account when using `--auth-mode login`. Assign it, wait a minute for propagation, and retry.

**Why LRS and not GRS:** this is a lab state file that can be recreated. In production, use a redundancy level that matches how painful losing state would be, and enable soft delete and versioning on the container.

---

## Step 2 - Configure the backend in Terraform

```hcl
# backend.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-lab-eus2-01"
    storage_account_name = "REPLACE_WITH_YOUR_STORAGE_ACCOUNT"
    container_name       = "tfstate"
    key                  = "avd-lab.tfstate"
  }
}
```

```bash
terraform init
```

**Expected output:** Terraform reports the azurerm backend was successfully configured and initialised.

**State locking** works automatically with this backend using blob leases. If a run crashes and leaves a lock behind, `terraform force-unlock <lock-id>` clears it - but read the message first and be certain no one else is applying.

---

## Step 3 - Variables and locals

```hcl
# variables.tf
variable "location" {
  description = "Primary Azure region for lab resources"
  type        = string
  default     = "eastus2"
}

variable "location_short" {
  description = "Short region code used in resource names"
  type        = string
  default     = "eus2"
}

variable "environment" {
  description = "Environment code: lab, dev, tst, prd"
  type        = string
  default     = "lab"
}

variable "owner" {
  description = "Email address of the resource owner"
  type        = string
}

variable "deletion_date" {
  description = "Date after which lab resources may be deleted (YYYY-MM-DD)"
  type        = string
  default     = "2026-12-31"
}
```

```hcl
# locals.tf
locals {
  suffix = "${var.environment}-${var.location_short}-01"

  common_tags = {
    environment   = var.environment
    workload      = "avd"
    owner         = var.owner
    costCenter    = "learning"
    autoShutdown  = "true"
    deletionDate  = var.deletion_date
    managedBy     = "terraform"
  }
}
```

**Why `managedBy = terraform`:** so that anyone looking at the portal knows not to hand-edit these resources. Manual changes to Terraform-managed resources cause drift, and drift causes surprises on the next apply.

---

## Step 4 - Create the resource groups

Separate resource groups by lifecycle, not by resource type. Things that are created, updated and deleted together belong together.

```hcl
# resource-groups.tf
resource "azurerm_resource_group" "network" {
  name     = "rg-avd-network-${local.suffix}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "identity" {
  name     = "rg-avd-identity-${local.suffix}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "storage" {
  name     = "rg-avd-storage-${local.suffix}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "avd" {
  name     = "rg-avd-service-${local.suffix}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "hosts" {
  name     = "rg-avd-hosts-${local.suffix}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "monitoring" {
  name     = "rg-avd-monitoring-${local.suffix}"
  location = var.location
  tags     = local.common_tags
}
```

**Why this split:** session hosts get rebuilt often, and having them in their own resource group means you can delete and recreate them without touching the network, the profile storage or the AVD service objects. That separation is what makes Lab 8 repeatable and what makes a production re-image safe.

```hcl
# outputs.tf
output "resource_group_names" {
  description = "All lab resource group names"
  value = {
    network    = azurerm_resource_group.network.name
    identity   = azurerm_resource_group.identity.name
    storage    = azurerm_resource_group.storage.name
    avd        = azurerm_resource_group.avd.name
    hosts      = azurerm_resource_group.hosts.name
    monitoring = azurerm_resource_group.monitoring.name
  }
}
```

---

## Step 5 - Plan and apply

```bash
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

**What each command does:**
- `fmt` normalises formatting so diffs stay readable
- `validate` catches syntax and type errors without touching Azure
- `plan -out=tfplan` writes the execution plan to a file
- `apply tfplan` applies exactly that plan - nothing can change between review and apply

**Always use `-out`.** Running `terraform apply` on its own re-plans at apply time, so what you approve may not be what you reviewed. On a shared environment that is how accidents happen.

**Expected output:** `Apply complete! Resources: 6 added, 0 changed, 0 destroyed.`

---

## Step 6 - Prove that state and drift detection work

This is the part that turns Terraform from a deployment tool into an operations tool.

1. In the Azure portal, add a tag manually to `rg-avd-hosts-lab-eus2-01`. Call it `test = drift`.
2. Run `terraform plan`.
3. Terraform will show that it intends to remove your manual tag, because the code is the source of truth.
4. Run `terraform apply` to bring the resource back in line.

**Why this matters:** you have just watched drift detection work. In production this is how you find out that someone changed a session host configuration by hand at 2am. [Project 03](../scenarios/project-03-global-enterprise-governance.md) covers drift, import and state management properly, at multi-business-unit scale.

---

## Validation Checklist

- [ ] State storage account created, public blob access disabled
- [ ] `terraform init` succeeds against the azurerm backend
- [ ] State file visible in the `tfstate` container in the portal
- [ ] Six resource groups created
- [ ] Every resource group carries all seven common tags
- [ ] `terraform plan` reports no changes immediately after apply
- [ ] Manual tag change is detected as drift and corrected by apply
- [ ] `outputs.tf` returns all six resource group names

## Troubleshooting

| Problem | Likely cause | Fix |
|---|---|---|
| `Error: storage account name is not available` | Name not globally unique | Re-run with a different random suffix |
| `AuthorizationPermissionMismatch` on container | Missing data-plane role | Assign Storage Blob Data Contributor, wait, retry |
| `Error acquiring the state lock` | Previous run crashed, lease held | Confirm nobody is applying, then `terraform force-unlock <id>` |
| `terraform init` cannot reach the registry | Proxy or egress blocking | Allow `registry.terraform.io` |
| Plan shows unexpected changes right after apply | Provider version changed | Confirm your version pin from Lab 1 is present |

## Cleanup

**Do not delete anything from this lab.** Every later lab depends on the state backend and the resource groups.

Running cost is under $1.00/month, which is the cheapest insurance in the whole book.

## Lab 2 Interview Questions

**Q. Why use remote state rather than local state?**
Locking, durability and collaboration. Local state means two people can apply at once and corrupt the environment, and losing a laptop means losing the record of what Terraform manages. Remote state in Azure Storage gives blob-lease locking, redundancy, and access control on who can read it - which matters, because state files can contain sensitive values.

**Q. How do you organise resource groups for AVD?**
By lifecycle. Network, identity, storage, AVD service objects, session hosts and monitoring are separated, because session hosts get rebuilt far more often than networks do. That separation lets me destroy and recreate compute without risking profile storage or the AVD objects, and it gives clean RBAC boundaries for delegating host operations without granting network rights.

---
