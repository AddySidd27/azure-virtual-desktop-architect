> **Part of:** [Azure Virtual Desktop - Architect to Hands-on Implementation](../README.md)  
> **Chapter:** [Chapter 2](../chapters/ch02-control-plane-management-plane-data-plane.md)  
> **Technical baseline:** August 2026

# LAB 1 - Azure Prerequisites, Subscription, Quota and Tooling

> **LAB ARCHITECTURE** - this is the environment you build across Labs 1-20. It is not a Microsoft reference design.

## Objective

Prepare your Azure subscription and your workstation so that every later lab runs without surprises. Fix the naming standard and the cost guardrails now, so that the Terraform code stays consistent for the rest of the book.

## Cost summary

| Item | Cost |
|---|---|
| Resource providers registered | $0.00 |
| Quota checks | $0.00 |
| Tooling installed locally | $0.00 |
| Azure budget + alert created | $0.00 |
| **Total for Lab 1** | **$0.00** |
| **Cost if left running** | **$0.00** - nothing billable is created |

Later labs do create billable resources. Lab 3 (network) is a few dollars a month. **Lab 8 (session hosts) is the first genuinely expensive lab** and will carry a clear warning before you start it.

## Prerequisites

- An Azure subscription where you can create resources and assign roles. Owner on a subscription, or Contributor plus User Access Administrator.
- A Microsoft Entra ID tenant you can create users and groups in.
- A Windows, macOS or Linux workstation with admin rights to install tools.

---

## Step 1 - Confirm which subscription you are in

Getting this wrong later is a common and expensive mistake.

```bash
az login
az account show --output table
az account list --output table
```

Set the correct one explicitly:

```bash
az account set --subscription "<your-subscription-id>"
```

**What this does:** authenticates the Azure CLI and pins the active subscription for every subsequent command.
**Expected output:** a table showing the subscription name, ID and tenant ID.
**Common error:** multiple subscriptions in the tenant and the default is the wrong one. Always set it explicitly rather than relying on the default.

---

## Step 2 - Register the required resource providers

AVD resources cannot be created until the provider is registered on the subscription. Registration is free and takes a few minutes.

```bash
az provider register --namespace Microsoft.DesktopVirtualization
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.Insights
```

Check progress:

```bash
az provider show --namespace Microsoft.DesktopVirtualization --query registrationState --output tsv
```

**Expected output:** `Registered`. If it says `Registering`, wait a couple of minutes and run it again.
**Common error:** insufficient permissions. Provider registration needs subscription-level rights.

---

## Step 3 - Check your compute quota

This is the step people skip, and it is the reason deployments fail at the worst moment.

```bash
az vm list-usage --location eastus2 --output table
```

Look at the rows for **Total Regional vCPUs** and for the specific VM family you intend to use. This book's labs use the D-series v5 family by default, so check **Standard DSv5 Family vCPUs** as well.

**Rough guidance for this book's labs:** budget for at least 20 vCPUs of headroom in your chosen region. A domain controller, two to three session hosts and a management VM will fit comfortably inside that.

If the quota is too low, request an increase in the portal: **Subscriptions → your subscription → Usage + quotas → request increase**. Approval for small increases is usually quick, but do it now rather than in Lab 8.

**Common error:** quota is per region *and* per VM family. Plenty of Total Regional vCPUs does not mean you have quota for the specific family you want.

---

## Step 4 - Install the tooling

### Azure CLI and the AVD extension

```bash
az --version
az extension add --name desktopvirtualization
az extension update --name desktopvirtualization
```

### Azure PowerShell

```powershell
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
Install-Module -Name Az.DesktopVirtualization -Scope CurrentUser -Repository PSGallery -Force
Get-Module -Name Az.DesktopVirtualization -ListAvailable | Select-Object Name, Version
```

**Note on versions:** AVD cmdlets change with the module. Record the version you are running and state it in any documentation you produce. Some features - App Attach in particular - require a recent module version. `[VERIFY BEFORE IMPLEMENTATION]` Check the current minimum version on Microsoft Learn for the specific feature you are configuring.

### Terraform

```bash
terraform -version
```

Install from the official HashiCorp instructions if it is missing. This book uses Terraform with the AzureRM provider as the primary IaC tool from Lab 3 onwards.

**Provider version:** the AzureRM provider's current major version is **5.x** (5.0.1 was published 30 July 2026). Major version changes in this provider have historically included breaking changes to resource schemas, so **pin your version** and read the upgrade guide before moving between majors. `[VERIFY BEFORE IMPLEMENTATION]`

Create a working folder and a provider pin file now:

```hcl
# versions.tf
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

**What this does:** pins the providers so that a later provider release cannot silently change the behaviour of your code. This is not optional discipline - it is the difference between reproducible infrastructure and a surprise on a Friday afternoon.

Verify it initialises:

```bash
terraform init
```

**Expected output:** Terraform reports that the azurerm and azuread providers were installed, and that it has been successfully initialised.

---

## Step 5 - Fix the naming standard now

Every lab and every Terraform module in this book uses this standard. Consistency here is what makes the code readable across 20 labs.

**Pattern:** `<resource-abbreviation>-<workload>-<environment>-<region>-<instance>`

| Resource | Abbreviation | Example |
|---|---|---|
| Resource group | `rg` | `rg-avd-lab-eus2-01` |
| Virtual network | `vnet` | `vnet-avd-lab-eus2-01` |
| Subnet | `snet` | `snet-hosts-lab-eus2-01` |
| Network security group | `nsg` | `nsg-hosts-lab-eus2-01` |
| Host pool | `hp` | `hp-avd-lab-eus2-01` |
| Application group | `ag` | `ag-desktop-lab-eus2-01` |
| Workspace | `ws` | `ws-avd-lab-eus2-01` |
| Storage account | `st` | `stavdlabeus201` (no hyphens, lowercase, max 24 chars) |
| Session host VM | `vm` | `vm-avdlab-01` (15-char NetBIOS limit) |
| Log Analytics workspace | `log` | `log-avd-lab-eus2-01` |
| Key vault | `kv` | `kv-avd-lab-eus2-01` |

**Region abbreviations used in this book:** `eus2` (East US 2), `weu` (West Europe), `cus` (Central US).

**Environment values:** `lab`, `dev`, `tst`, `prd`.

**Watch the constraints.** Storage account names allow no hyphens and no capitals. Windows computer names are capped at 15 characters. Design your prefix so both still fit at the end of the book, not just today.

## Step 6 - Fix the tagging standard

Apply these to every resource group in every lab.

| Tag | Example value | Why |
|---|---|---|
| `environment` | `lab` | Filtering and policy |
| `workload` | `avd` | Cost attribution |
| `owner` | `your.name@domain.com` | Accountability |
| `costCenter` | `learning` | Cost reporting |
| `autoShutdown` | `true` | Marks resources safe to power off |
| `deletionDate` | `2026-12-31` | Prevents lab sprawl |

The `autoShutdown` and `deletionDate` tags are not decoration. They are how you will keep the lab bill under control when you have 12 labs' worth of resources sitting around.

---

## Step 7 - Create a budget and cost alert

Do this before you create a single billable resource.

**Portal steps:**

1. Go to **Cost Management + Billing**.
2. Select your subscription, then **Budgets**.
3. Select **+ Add**.
4. Scope: your subscription. Name: `budget-avd-lab`.
5. Reset period: **Monthly**. Expiration: 12 months out.
6. Budget amount: set a figure you are genuinely comfortable with. **$150/month** is a reasonable starting point for this book's labs if you shut down compute between sessions.
7. Add alert conditions at **50%**, **80%** and **100%** of budget.
8. Enter your email address as the alert recipient.
9. Create.

**Why the portal and not CLI here:** budget creation via CLI has moved between command groups across CLI versions. The portal path is stable and this is a one-time action. `[VERIFY BEFORE IMPLEMENTATION]` if you want to automate it.

**This does not stop spending.** It tells you. Actual cost control comes from shutting resources down, which every subsequent lab will show you how to do.

---

## Validation Checklist

Do not move to Chapter 3 until every box is ticked.

- [ ] `az account show` returns the correct subscription
- [ ] `Microsoft.DesktopVirtualization` provider shows `Registered`
- [ ] `Microsoft.Compute`, `Microsoft.Network`, `Microsoft.Storage`, `Microsoft.Insights` show `Registered`
- [ ] `az vm list-usage` shows at least 20 vCPUs of available quota in your chosen region
- [ ] Azure CLI installed and `desktopvirtualization` extension added
- [ ] `Az` and `Az.DesktopVirtualization` PowerShell modules installed, versions recorded
- [ ] `terraform init` succeeds against your `versions.tf`
- [ ] AzureRM provider version pinned in code
- [ ] Naming standard written down where you will actually see it
- [ ] Tagging standard written down
- [ ] Budget created with alerts at 50/80/100%
- [ ] Alert email confirmed as one you check

## Troubleshooting

| Problem | Likely cause | Fix |
|---|---|---|
| `az login` opens the wrong tenant | Multiple tenants | `az login --tenant <tenant-id>` |
| Provider stuck on `Registering` | Normal propagation delay | Wait 5 minutes and re-check |
| Provider registration denied | Insufficient rights | You need subscription-level permissions, not just resource group Contributor |
| `az vm list-usage` returns nothing | Wrong region name | Use `az account list-locations --output table` to get exact names |
| `terraform init` fails on provider download | Network or proxy blocking the registry | Check egress to `registry.terraform.io` |
| PowerShell module install fails | PSGallery not trusted | `Set-PSRepository -Name PSGallery -InstallationPolicy Trusted` |

## Cleanup

Nothing to clean up. No billable resources were created.

**Keep for later labs:** all of it - tooling, naming standard, tagging standard, budget, and your Terraform working folder.

## Lab 1 Interview Questions

**Q. How do you prepare an Azure subscription for an AVD deployment?**
Register the required resource providers, confirm regional and VM-family quota against your sizing model, agree naming and tagging standards, set up cost guardrails, and confirm the identity model before anything else. Mention quota specifically - it is the most common cause of a deployment stalling on day one, and mentioning it signals you have actually done this.

**Q. Why pin your Terraform provider version?**
Because an unpinned provider can pull a new major version with breaking schema changes, and your next `terraform apply` then proposes changes you did not ask for. In a shared environment that is how a routine change becomes an incident. Pin the version, upgrade deliberately, read the upgrade guide, and test in a non-production workspace first.

---
