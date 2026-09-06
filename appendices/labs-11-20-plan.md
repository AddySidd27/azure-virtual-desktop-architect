# Labs 11-20 Plan: Active-Active Multi-Region Azure Virtual Desktop

**Status:** **CLOSED.** All 10 labs built and validated per section 7's sequencing, with two approved corrections applied: (1) the architecture correction to standard host-pool management and Power Management Autoscale, not Session Host Configuration and Dynamic Autoscaling, see [the ADR](adr-shc-vs-standard-host-pools.md); (2) the Lab 19 identity and capacity-reservation correction, see [the correction report](lab-19-correction-report.md). Formally closed August 2026. No further work is planned against Labs 11-20 unless a future live-Azure validation pass finds a genuine defect.
**Date:** August 2026
**Extends:** Labs 1-10 (single-region, `eastus2`, domain `avdlab.local`, resource prefix `avdlab`)
**New region:** `centralus`, region-short code `cus` (Labs 1-10 used `eus2`)

---

## 1. Product-accuracy findings, verified against current Microsoft Learn documentation

Every technical claim below was checked against Microsoft Learn and the Azure Architecture Center directly, not against chapter content or memory, per the explicit instruction for this phase. Sources are cited by URL. Where a conflict existed between third-party commentary and Microsoft's own documentation, Microsoft's documentation wins.

### 1.1 Microsoft Regional Host Pools - Preview, not GA, and explicitly ruled out for these labs

[learn.microsoft.com/azure/virtual-desktop/regional-host-pools](https://learn.microsoft.com/en-us/azure/virtual-desktop/regional-host-pools) states plainly: **"Regional host pools in Azure Virtual Desktop are currently in PREVIEW."** The same page states that while in preview, regional host pools do **not** support Session Host Update, Dynamic Autoscaling, Private Link, or App Attach, and that errors and checkpoints are not reported into Log Analytics for regional session hosts. The Azure Architecture Center's own multiregion BCDR guidance confirms this and adds that geographical and regional host pools are not interoperable during the preview period: a workspace or application group built against one deployment scope cannot associate with a host pool of the other scope.

**Decision for these labs: use geographical (classic) host pools, not regional host pools.** This is not a stylistic choice. The lab plan requires both true multi-region autoscaling (item 6) and dynamic autoscaling specifically, and regional host pools cannot do the latter during preview. Building production-pattern labs on a preview feature with a documented gap in exactly the capability the labs need to demonstrate would be the wrong call, and would also violate the instruction not to present preview functionality as if it were a safe, current default. Regional host pools are flagged in Lab 11 as an emerging pattern worth watching, with a link to Microsoft's own migration-guidance placeholder, but they are not the foundation of the build.

> **Correction, approved and applied during the Lab 14 build:** Sections 1.2 and 1.3 below reflect this plan's original research into Azure-side feature status only. Verifying *tooling* support (Terraform, PowerShell, AzAPI) during the actual Lab 14 build found that none of the three paths into Session Host Configuration are production-ready: no stable Terraform resource exists, the PowerShell cmdlets are explicitly marked preview by Microsoft, and the ARM API has never had a non-preview version. Labs 14-20 use standard host-pool management and Power Management Autoscale instead, with SHC and Dynamic Autoscaling covered only as clearly labelled optional sections. See [the ADR](adr-shc-vs-standard-host-pools.md) for the full reasoning, sourced directly against Microsoft Learn.

### 1.2 Automated Host Pools (Session Host Configuration) - GA on the Azure side, tooling not yet production-ready

Microsoft's Azure Virtual Desktop deployment and session host update guidance place Automated Host Pools, built on Session Host Configuration (SHC), at general availability on the Azure service side. Verifying the tooling gives a different result: no native AzureRM resource is documented, Microsoft marks the supporting PowerShell cmdlets as preview, and the ARM resource `Microsoft.DesktopVirtualization/hostPools/sessionHostConfigurations` has no non-preview version in the version list. The newest API checked on 6 September 2026 is `2026-04-01-preview`. **Labs 14-20 do not use SHC as a required dependency.** See [the ADR](adr-shc-vs-standard-host-pools.md) for the decision and Microsoft sources.

**Session Host Update itself remains in preview** ([learn.microsoft.com/azure/virtual-desktop/session-host-update-configure](https://learn.microsoft.com/en-us/azure/virtual-desktop/session-host-update-configure), fetched directly, still shows the PREVIEW banner). Labs 14-20 use this book's established golden-image, drain-and-replace pattern (Chapter 23) for any image-level change instead, which works regardless of Session Host Update's preview status.

### 1.3 Dynamic Autoscaling - requires SHC, therefore out of the required lab path; Power Management Autoscale used instead

Three independent, dated sources place Dynamic Autoscaling at GA in June 2026 on the Azure side. It requires an SHC-based pool to attach to. Since Labs 14-20 use standard host-pool management (section 1.2), Dynamic Autoscaling is not reachable as a required dependency regardless of its own GA status. **Lab 17 uses Power Management Autoscale** (`azurerm_virtual_desktop_scaling_plan`), unambiguously GA and fully Terraform-supported for every host pool type, as the required, production-safe implementation. Dynamic Autoscaling is covered in Lab 17 as a clearly labelled optional upgrade path, with the explicit instruction to re-check `learn.microsoft.com/azure/virtual-desktop/autoscale-glossary` and the SHC tooling status in section 1.2 before relying on it.

### 1.4 Active-active multi-region AVD - confirmed pattern, and what it actually requires

The Azure Architecture Center's `azure-virtual-desktop-multi-region-bcdr` article is the canonical source and was fetched in full. Confirmed, load-bearing facts for this lab set:

- **Active-active means a complete second host pool in the second region**, not a single host pool spanning two regions. A single host pool with session hosts in multiple regions is documented but explicitly discouraged for this use case: Microsoft states you cannot enforce regional connection preferences for users in that model, and profile-storage assignment across regions becomes complex. Lab 14 builds two separate host pools.
- **Users see duplicate feed entries in an active-active design.** Microsoft's own guidance states this plainly and recommends separate, clearly labelled workspaces per region specifically because of it. Lab 14 builds two workspaces, not one, and Lab 16 documents the user-facing naming convention that makes the duplication legible rather than confusing.
- **FSLogix Cloud Cache is the documented mechanism for active-active profile replication**, not simple regional storage isolation. Concurrent access to the same profile from both regions produces `ERROR_LOCK_VIOLATION 33 (0x21)` and fails the second sign-in. Microsoft's mitigation is administrative: keep each user's access restricted to one region's application groups at a time via non-overlapping Active Directory or Entra security groups. Lab 15 builds Cloud Cache with the documented `CCDLocations` provider-order reversal per region; Lab 16 builds the non-overlapping group assignment that prevents the lock-violation failure mode in the first place.
- **The control plane (web, broker, gateway, resource directory, diagnostics) is Microsoft-managed and fails over automatically.** No lab in this set builds control-plane redundancy, because none is possible or necessary; this is stated explicitly in Lab 11 so it is not mistaken for a gap.
- **Azure Compute Gallery is regional.** Cross-region image consistency requires either gallery replicas (the mechanism this book's existing projects already use) or an explicit image-version copy between regional galleries. Lab 18 uses gallery replicas, consistent with Chapter 23 and the existing Project 13, and documents the manual `az sig image-version create` cross-region copy as the alternative Microsoft's own architecture guide describes, for readers whose gallery design doesn't use replicas.

### 1.5 Disaster recovery is a distinct pattern from active-active, and Lab 19 is built to make that distinction explicit, not implicit

Microsoft's own comparison table gives active-active near-zero RTO with no admin intervention and high steady-state cost (dual compute, dual storage, always on), against active-passive's 15-60 minute RTO, admin-triggered group reassignment, and lower steady-state cost. Lab 19 does not reuse Lab 14's host pools in a "failover mode." It builds a genuinely different configuration: a secondary host pool with minimal standing compute, a documented failover runbook requiring administrative action (removing and reassigning Entra group membership, matching Microsoft's documented failover steps exactly), and an explicit cost and RTO comparison table against Labs 11-18's active-active design, so a reader finishing Lab 20 can state correctly which pattern they built and why it is not the same thing.

---

## 2. Cross-lab Terraform and naming conventions

**Region and naming.** Region A (existing, `eastus2`, short code `eus2`) is unchanged from Labs 1-10. Region B is `centralus`, short code `cus`. Resource naming follows the existing pattern (`<type>-avdlab-<purpose>-<region-short>-<instance>`), extended with the region-short code everywhere it was previously implicit, since Labs 1-10 never needed to distinguish a region in a resource name.

**Terraform module layout.** Each lab gets its own `terraform/lab1N-<name>/` directory, consistent with Labs 1-10. Labs that touch both regions (14 onward) parameterise region via a `region` variable taking `"eastus2"` or `"centralus"`, applied twice by the reader (once per region) rather than looping inside one module, matching this book's established teaching pattern of explicit, visible repetition over hidden abstraction during the labs, with the option to collapse into a `for_each` shown afterward as a "how you'd do this in production" note.

**Cross-lab references.** Labs 12 onward consume prior labs' outputs via Terraform remote state data sources (`terraform_remote_state`), the same mechanism Labs 1-10 already use. Lab 11's outputs (`vnet_id_eastus2`, `vnet_id_centralus`, `dns_resolver_ip_eastus2`, `dns_resolver_ip_centralus`) are the foundation every later lab reads from.

**PowerShell/CLI, not Terraform, is used for:** AVD workspace feed validation (no supported Terraform read-back for client-visible feed state), FSLogix registry configuration on session hosts (registry keys are not Azure Resource Manager objects), Azure Compute Gallery cross-region image-version copy where replicas aren't used (a one-time operational action, not declared infrastructure), and DR failover/failback execution (an operational runbook action, deliberately not automated into `terraform apply` so that a failover always requires the explicit human decision Microsoft's own guidance calls for).

---

## 3. The ten labs

### Lab 11 - Multi-Region Landing Zone Foundation

| Field | Detail |
|---|---|
| **Purpose** | Build the second region's network foundation and connect it to the first, so every later lab has somewhere to deploy into. Establish hub-to-hub connectivity and cross-region DNS resolution before any AVD object exists. |
| **Dependencies** | Labs 1-3 (existing `eastus2` VNet, subnets, NSGs, DNS). |
| **Azure resources** | `centralus` resource group, VNet, four subnets (identity, hosts, storage, mgmt) matching Lab 3's `eastus2` pattern, NSGs matching Lab 3's rule set, VNet peering between `eastus2` and `centralus` VNets (both directions), a private DNS resolver or conditional forwarder configuration so each region's session hosts can resolve the other region's private endpoints and domain controller. |
| **Terraform deliverables** | `terraform/lab11-multiregion-network/`: `main.tf`, `variables.tf` (region-parameterised), `outputs.tf` exposing both regions' VNet IDs, subnet IDs, and NSG IDs for consumption by Labs 12+. |
| **Diagram deliverables** | `lab11-multiregion-network-topology.drawio` + `.svg`: both regions' hub-spoke layout, the peering connection, and DNS resolution paths, self-contained per this book's diagram standard. |
| **Validation evidence** | `az network vnet peering show` confirming both peering links report `Connected`. A DNS resolution test from a temporary test VM in `centralus` resolving a record hosted in `eastus2`'s private DNS zone, and the reverse. |
| **Estimated Azure cost** | VNets, subnets, NSGs, peering: no direct charge. Peering data transfer: negligible at lab scale (under $1/month for validation traffic). No compute deployed in this lab. |
| **Topics and existing projects covered** | Extends Chapter 12 (topology and IP planning) and Chapter 13 (egress control) to two regions. Directly parallels [Project 13](../scenarios/project-13-multi-region-architecture.md)'s hub-spoke-per-region decision, but built hands-on here rather than only decided on paper. |

### Lab 12 - Regional Identity

| Field | Detail |
|---|---|
| **Purpose** | Give `centralus` its own domain controller so session hosts in that region authenticate locally rather than across the region pair, exactly as Chapter 17's Azure Architecture Center guidance requires for AD DS-joined active-active designs. |
| **Dependencies** | Lab 11 (network), Lab 4 (existing `eastus2` domain controller, `avdlab.local`). |
| **Azure resources** | A second domain controller VM in `centralus`'s identity subnet, promoted as an additional domain controller (not a new domain) for `avdlab.local`, with AD Sites and Services configured so each region's subnet maps to its own AD site. |
| **Terraform deliverables** | `terraform/lab12-regional-identity/`: VM, NIC (static IP), managed disk, matching Lab 4's Terraform shape with `region = "centralus"`. PowerShell/CLI deliverable (not Terraform): the `dcpromo`-equivalent `Install-ADDSDomainController` step and AD Sites and Services subnet mapping, since domain promotion is not a Terraform-manageable action. |
| **Diagram deliverables** | `lab12-regional-identity-topology.drawio` + `.svg`: both domain controllers, the replication link between them, and the AD site boundary. |
| **Validation evidence** | `repadmin /showrepl` confirming successful replication between the two domain controllers. A session host placed (temporarily, for this test) in `centralus`'s subnet authenticating against the local DC, confirmed via `nltest /dsgetdc:avdlab.local` returning the `centralus` DC, not the `eastus2` one. |
| **Estimated Azure cost** | Domain controller VM (Standard_B2s, matching Lab 4's sizing): ~$30/month running, ~$10/month deallocated (disk only). Identical cost shape to Lab 4. |
| **Topics and existing projects covered** | Extends Chapter 7 (identity architecture) and Lab 4 to a second region. Directly implements the AD DS high-availability requirement from the Architecture Center's BCDR guide (two DCs per region, matching global catalog and DNS roles), cross-referenced against [Project 13](../scenarios/project-13-multi-region-architecture.md)'s identity design. |

### Lab 13 - Regional Storage Foundation

| Field | Detail |
|---|---|
| **Purpose** | Build `centralus`'s storage account and private endpoint, mirroring Lab 5, as the prerequisite both Lab 14 (host pools need somewhere for profiles eventually) and Lab 15 (Cloud Cache needs two storage accounts to replicate between) depend on. |
| **Dependencies** | Lab 11 (network), Lab 12 (identity, for share-level RBAC against the `centralus` DC). |
| **Azure resources** | `centralus` storage account (`FileStorage`, Premium tier, matching Lab 5's kind selection and its documented reasoning), private endpoint into the storage subnet, private DNS zone group registration, share-level RBAC and NTFS permissions matching Lab 5's two-layer pattern. |
| **Terraform deliverables** | `terraform/lab13-regional-storage/`: mirrors `terraform/lab05-storage/` with `region = "centralus"`, outputs the storage account name and private endpoint FQDN for Lab 15 to consume. |
| **Diagram deliverables** | `lab13-regional-storage-topology.drawio` + `.svg`: both regions' storage accounts and private endpoints side by side, explicitly not yet connected (Cloud Cache replication is Lab 15's job, not this lab's). |
| **Validation evidence** | Repeats Lab 5's own validation exactly (Step 5's expected Access Denied before NTFS permissions, Step 6's expected success after) against the `centralus` account, confirming the two-layer permission model holds identically in the second region. |
| **Estimated Azure cost** | Matches Lab 5: Premium file share billed on provisioned capacity, ~$20-30/month for a small lab-sized share, private endpoint ~$7/month. |
| **Topics and existing projects covered** | Extends Chapter 20 (profile storage architecture) to a second region. Prerequisite groundwork for the FSLogix Cloud Cache pattern in [Project 13](../scenarios/project-13-multi-region-architecture.md), though Project 13 deliberately chose region-siloed storage for data-residency reasons; this lab set's default is Cloud Cache replication, and Lab 15 states explicitly why that's a different, equally valid choice for a business without Project 13's residency constraint. |

### Lab 14 - Active-Active Host Pools, Workspaces and Application Groups

| Field | Detail |
|---|---|
| **Purpose** | Build the second, fully independent host pool in `centralus`, using standard host-pool management (see [the ADR](adr-shc-vs-standard-host-pools.md)), and the separate, clearly-labelled workspace Microsoft's own guidance requires for the duplicate-feed active-active pattern. This is the lab that makes the environment genuinely active-active rather than single-region-plus-standby. |
| **Dependencies** | Labs 11-13. |
| **Azure resources** | `centralus` host pool (Pooled, standard management type), registration info, two session hosts with the AVD agent and bootloader VM extensions, `centralus` workspace (named distinctly, e.g. `ws-avdlab-cus-01`, against the existing `eastus2` workspace), desktop application group. |
| **Terraform deliverables** | `terraform/lab14-active-active-hostpools/`: host pool, registration info, session hosts, AVD agent extension, workspace, application group, for `centralus`, following the same resource shape as `terraform/lab07-avd-core/` and `terraform/lab08-session-hosts/` exactly, at the `centralus` address. An optional, clearly separated section documents Automated Host Pools/SHC as a non-required upgrade path, sourced to current Microsoft Learn documentation and flagged preview throughout. |
| **Diagram deliverables** | `lab14-active-active-workspaces.drawio` + `.svg`: both regions' host pools, workspaces, and application groups, explicitly showing the duplicate feed a user sees, labelled to show why that's expected, not a bug. |
| **Validation evidence** | Both host pools show `Available` session hosts in the Azure portal. A test user's Windows App client shows two distinct, clearly labelled desktop entries, one per region, confirmed by screenshot description in the lab's validation section. |
| **Estimated Azure cost** | Two session hosts (Standard_D2s_v5, matching Lab 8's sizing): ~$140/month running per region if left on continuously, ~$20/month if deallocated between lab sessions (disks only). |
| **Topics and existing projects covered** | Extends Chapter 15 (host pool design) to a second, simultaneously active region, using the same standard management pattern Chapter 16 covers. Directly builds what [Project 13](../scenarios/project-13-multi-region-architecture.md) designed on paper as active/active, but Project 13 explicitly chose no cross-region failover and region-siloed everything for a trading firm's specific residency needs; this lab set builds the more general Microsoft-documented active-active pattern with Cloud Cache, which is a different, equally legitimate design point, and the plan states this distinction so a reader doesn't mistake one for a correction of the other. |

### Lab 15 - FSLogix Cloud Cache Active-Active Replication and User Affinity

| Field | Detail |
|---|---|
| **Purpose** | Configure FSLogix Cloud Cache so a profile created in one region replicates to the other, using Microsoft's documented `CCDLocations` reversed-order pattern per region, and demonstrate the profile-lock failure mode Microsoft's own documentation describes, so the reader sees the actual error before Lab 16 builds the control that prevents it. |
| **Dependencies** | Labs 13 (both regions' storage) and 14 (both regions' session hosts). |
| **Azure resources** | No new Azure resources; this lab configures FSLogix registry settings on the session hosts built in Lab 14, pointing at the storage accounts built in Lab 13. |
| **Terraform deliverables** | None directly deployable via Terraform (registry configuration is host-level, not an ARM object). Terraform deliverable is a documented Custom Script Extension or DSC configuration (added to Lab 14's session host Terraform, referenced here) that applies the registry keys at host-creation time, consistent with `terraform/lab06-fslogix`'s existing pattern extended to two regions with the `CCDLocations` provider order reversed per region as Microsoft's guide specifies. |
| **PowerShell/CLI deliverable** | The registry key set for both Profile and Office containers, per region, matching the exact `CCDLocations` syntax from Microsoft's architecture guide, applied via `Invoke-AzVMRunCommand` for the lab's manual validation pass before it's folded into the Terraform-driven extension. |
| **Diagram deliverables** | `lab15-cloud-cache-replication.drawio` + `.svg`: the exact replication flow diagram pattern Microsoft's own architecture guide uses (first session locks the profile in region A, second session to region B fails with `ERROR_LOCK_VIOLATION`), redrawn as a self-contained original diagram for this lab. |
| **Validation evidence** | A profile created via sign-in in `eastus2` is confirmed present (via `Get-AzStorageFile` or a direct share browse) in `centralus`'s storage account within the expected replication window. The lock-violation failure is deliberately reproduced once, by signing the same test user into both regions concurrently, with the exact FSLogix log error captured as evidence, before Lab 16's group-based access restriction is applied to prevent it going forward. |
| **Estimated Azure cost** | No new resources; cost is Lab 13's and Lab 14's storage and compute, already counted. |
| **Topics and existing projects covered** | Extends Chapter 21 (FSLogix production implementation) and Chapter 22 (profile operations, Cloud Cache) to genuine cross-region replication, which Chapter 22 covers conceptually but Labs 1-10 never built hands-on (Lab 6 uses a single storage provider). Contrasts directly with [Project 13](../scenarios/project-13-multi-region-architecture.md)'s explicit decision *not* to use Cloud Cache across regions, with the reasoning for each choice stated in both places. |

### Lab 16 - User-to-Region Assignment and Routing Strategy

| Field | Detail |
|---|---|
| **Purpose** | Build the non-overlapping Active Directory group structure that gives each user access to exactly one region's application group at a time, the documented mitigation for Lab 15's lock-violation failure mode, and the routing/assignment strategy a reader can defend as a design decision. |
| **Dependencies** | Lab 14 (application groups in both regions), Lab 15 (the failure mode this lab prevents). |
| **Azure resources** | Two Entra ID (or AD, synced) security groups per user population (`grp-avdlab-<population>-eus2`, `grp-avdlab-<population>-cus`), application group assignments scoped to each region's group only, with a documented process for the (rare, deliberate) exception of moving a user's primary region assignment. |
| **Terraform deliverables** | `terraform/lab16-region-assignment/`: `azuread_group` resources for both regions' groups, `azurerm_role_assignment`-equivalent AVD application group assignment resources, parameterised by population. |
| **Diagram deliverables** | `lab16-user-region-assignment.drawio` + `.svg`: the group-to-application-group mapping, explicitly showing no user group has membership spanning both regions. |
| **Validation evidence** | A scripted audit (PowerShell, `Get-AzWvdApplicationGroup` plus Entra group membership queries) confirming zero users hold membership in both a `eus2` and a `cus` group for the same population. The lock-violation failure from Lab 15, re-attempted after this lab's controls are in place, correctly fails at the assignment layer (user simply doesn't see the other region's desktop in their feed) rather than at the FSLogix layer. |
| **Estimated Azure cost** | No new billable resources; Entra ID group objects carry no direct Azure charge at this scale. |
| **Topics and existing projects covered** | New ground for this book's labs; the closest prior treatment is [Project 13](../scenarios/project-13-multi-region-architecture.md)'s static, desk-based assignment reasoning (Section 7), built here as working Terraform and Entra groups rather than only described in prose. |

### Lab 17 - Regional Autoscaling with Power Management Autoscale

| Field | Detail |
|---|---|
| **Purpose** | Give each region's host pool its own autoscaling, tuned to that region's own demand pattern, using Power Management Autoscale (GA, required implementation, matches the standard host pools built in Lab 14). Dynamic Autoscaling is covered as an optional, non-required upgrade path. |
| **Dependencies** | Lab 14 (standard host pools in both regions). |
| **Azure resources** | Two scaling plans (one per region, matching the requirement that scaling plan configuration data lives in the same region as its host pool), each with ramp-up/peak/ramp-down/off-peak schedules, assigned to that region's host pool only. |
| **Terraform deliverables** | `terraform/lab17-regional-autoscaling/`: `azurerm_virtual_desktop_scaling_plan` resources for both regions, with exclusion tags, drain-mode handling, capacity thresholds, and Start VM on Connect configured per region. |
| **Diagram deliverables** | `lab17-regional-autoscaling-schedules.drawio` + `.svg`: both regions' scaling phases on a shared timeline, showing that each region scales to its own local demand curve independently, not synchronised to the other region's schedule. |
| **Validation evidence** | An observed scaling action in each region (a session host started or stopped, matching Lab 10's existing validation pattern) triggered independently, with timestamps showing the two regions' scaling events are not correlated to each other. `Get-AzWvdScalingPlan` confirming the assigned plan and schedule per region. |
| **Estimated Azure cost** | No direct charge for the scaling plan object itself; cost impact is a reduction against Lab 14's baseline, since Power Management Autoscale deallocates idle VMs during off-peak windows rather than leaving them running. Estimated saving: 30-50% against Lab 14's always-on baseline for a typical business-hours demand pattern, consistent with this book's existing scaling economics in [Project 07](../scenarios/project-07-call-centre-high-density.md). |
| **Topics and existing projects covered** | Extends [Project 07](../scenarios/project-07-call-centre-high-density.md) and Lab 10's Power Management Autoscale pattern to two independently-scaling regions, which no existing project or lab covers. Dynamic Autoscaling's current tooling status is covered as an optional comparison, sourced to Microsoft Learn, per [the ADR](adr-shc-vs-standard-host-pools.md). |

### Lab 18 - Regional Security and Monitoring

| Field | Detail |
|---|---|
| **Purpose** | Give `centralus` its own security controls (NSGs already built in Lab 11, plus egress control matching Chapter 13's pattern) and its own Log Analytics workspace, joined by a cross-workspace dashboard, following the same reasoning [Project 13](../scenarios/project-13-multi-region-architecture.md) used: shared monitoring infrastructure would undermine the independence the whole design is built around. |
| **Dependencies** | Lab 11 (network), Lab 14 (session hosts to monitor). |
| **Azure resources** | `centralus` Log Analytics workspace, AVD diagnostic settings pointing each region's host pool at its own regional workspace, an Azure Workbook built on a cross-workspace KQL query for the unified view, `centralus` Azure Firewall or equivalent egress control matching Lab 3/Chapter 13's pattern. |
| **Terraform deliverables** | `terraform/lab18-regional-security-monitoring/`: Log Analytics workspace, diagnostic settings, firewall/NSG rules for `centralus`, parameterised identically to the `eastus2` equivalents from Labs 3 and 10. |
| **Diagram deliverables** | `lab18-regional-monitoring-topology.drawio` + `.svg`: two regional workspaces feeding one cross-workspace dashboard, explicitly showing what happens to the dashboard if one region's workspace becomes unreachable (a gap for that region, not a total dashboard failure). |
| **Validation evidence** | AVD diagnostics confirmed flowing into the correct regional workspace for each region (not cross-contaminated). The cross-workspace dashboard validated by temporarily blocking query access to one workspace and confirming graceful degradation, the same test used in [Project 13](../scenarios/project-13-multi-region-architecture.md). |
| **Estimated Azure cost** | Log Analytics: ingestion-based, ~$5-15/month at lab scale per region. Firewall (if a full Azure Firewall instance is used rather than NSG-only egress control): ~$900/month running, which this lab explicitly recommends deallocating/deleting between sessions or substituting NSG-only egress control for lab purposes, with the cost trade-off stated plainly rather than defaulting to the expensive option silently. |
| **Topics and existing projects covered** | Extends Chapter 13 (egress control) and [Project 02](../scenarios/project-02-enterprise-850-users.md)'s monitoring architecture to two independently-monitored regions, following [Project 13](../scenarios/project-13-multi-region-architecture.md)'s per-region-workspace reasoning built hands-on. |

### Lab 19 - Disaster Recovery and Failover (Active-Passive), Contrasted Against Active-Active

| Field | Detail |
|---|---|
| **Purpose** | Build a genuinely different pattern from Labs 11-18, active-passive DR, so the reader has hands-on evidence of what changes between the two models, not just a written comparison. This lab does not reuse Lab 14's host pools as a "failover target"; it builds the lower-cost, admin-triggered pattern Microsoft's own comparison table describes, and executes a real, documented failover and failback. |
| **Dependencies** | Labs 11-13 (network, identity, storage foundation only; this lab deliberately does not depend on Lab 14's active-active host pools, to keep the two patterns genuinely separable). |
| **Azure resources** | A third host pool configuration (in `centralus`, but configured as a passive DR target: minimal standing session hosts, deallocated by default), a single shared workspace (not a second one, matching Microsoft's documented active-passive user experience of no duplicate feed), an on-demand capacity reservation for the DR region's session host SKU. |
| **Terraform deliverables** | `terraform/lab19-dr-failover/`: the passive host pool and its session hosts (created but deallocated by default via a `deploy_active` variable), capacity reservation, kept structurally distinct from `terraform/lab14-active-active-hostpools/` rather than a flag on the same module, so the two patterns remain genuinely comparable side by side rather than merged into one confusing option set. |
| **PowerShell/CLI deliverable** | The documented failover runbook script: remove user group assignment from the primary application group, force-disconnect connected sessions, assign the same group to the secondary host pool's application group, start the deallocated session hosts. And the matching failback script, run as a distinct, later exercise, not assumed symmetrical. |
| **Diagram deliverables** | `lab19-active-passive-dr.drawio` + `.svg`: the passive host pool's standing-versus-activated resource split, and a second diagram, `lab19-active-active-vs-active-passive-comparison.drawio` + `.svg`, placing Lab 14's and Lab 19's architectures side by side with the RTO, cost, and admin-intervention differences labelled directly on the diagram. |
| **Validation evidence** | A real, timed failover exercise: group reassignment executed, session hosts started from deallocated state, time from runbook start to first successful sign-in in the DR region measured and recorded, compared against the 15-60 minute range Microsoft's own guidance gives as the expected active-passive RTO. A failback exercise run as a second, separate timed test. |
| **Estimated Azure cost** | Deallocated session hosts: disk cost only, ~$10-15/month per host. Capacity reservation: billed as if the reserved VMs were running, which is the explicit cost of the capacity guarantee, matching [Project 14](../scenarios/project-14-disaster-recovery.md)'s reasoning for why this cost is worth paying. Total materially lower than Lab 14's always-on active-active baseline, consistent with Microsoft's own cost comparison table. |
| **Topics and existing projects covered** | Directly extends [Project 14](../scenarios/project-14-disaster-recovery.md)'s business-impact-analysis-driven DR design and [Project 13](../scenarios/project-13-multi-region-architecture.md)'s explicit active-active-versus-active-passive reasoning, built hands-on here for the first time rather than only decided on paper. Chapter 20's profile storage redundancy concepts apply directly to this lab's storage failover behaviour. |

### Lab 20 - End-to-End Validation, Cost Control and Teardown

| Field | Detail |
|---|---|
| **Purpose** | Validate the complete ten-lab environment as one system, produce a single cost dashboard across both regions and both patterns (active-active and DR), and provide a safe, ordered teardown so the environment doesn't silently keep billing after the reader is done. This is the capstone validation lab for Labs 11-19, matching Lab 10's role for Labs 1-9. |
| **Dependencies** | Labs 11-19, all of them. |
| **Azure resources** | No new resources created; this lab queries and validates what Labs 11-19 built, and adds one Cost Management view/export scoped to both regions' resource groups. |
| **Terraform deliverables** | `terraform/lab20-validation-teardown/`: no new infrastructure; a `destroy` runbook documenting the exact, dependency-safe order to `terraform destroy` Labs 11-19's modules in reverse dependency order (19 and 20 first, since they depend on 11-13 but not on 14-18; then 14-18; then 12-13; then 11 last), since destroying out of order produces avoidable errors from dangling dependencies. |
| **Diagram deliverables** | `lab20-full-environment-topology.drawio` + `.svg`: the complete ten-lab environment in one diagram, both regions, both patterns (active-active and DR), following this book's diagram standard at hero-diagram scale, since this is the single diagram a reader would use to explain the whole build. |
| **Validation evidence** | A full end-to-end sign-in test in each region's active-active desktop, a full failover-and-failback cycle re-run as final confirmation (not just Lab 19's original test), a Cost Management report confirming actual spend against this plan's estimates for each lab, and a completed teardown confirmed by `az resource list` returning zero resources in both regions' resource groups. |
| **Estimated Azure cost** | No new cost; this lab's value is confirming and then eliminating Labs 11-19's combined running cost, estimated at $250-350/month if every lab's resources are left running continuously (see the cost roll-up in section 4), reducible to under $50/month with disciplined deallocation between sessions, consistent with the cost-consciousness this book's labs have maintained since Lab 4. |
| **Topics and existing projects covered** | Mirrors Lab 10's role for Labs 1-9: the operational validation and teardown discipline established there, applied at the scale of a ten-lab, two-region environment. Ties together every project referenced across Labs 11-19. |

---

## 4. Cost roll-up across Labs 11-20

| Lab | Running cost/month (both regions where applicable) | Deallocated/minimal cost/month |
|---|---|---|
| 11 | ~$1 (peering data only) | ~$1 |
| 12 | ~$30 | ~$10 |
| 13 | ~$35 | ~$35 (storage doesn't deallocate) |
| 14 | ~$140 | ~$20 |
| 15 | $0 (config only) | $0 |
| 16 | $0 (Entra objects) | $0 |
| 17 | Net negative (reduces Lab 14's cost) | Net negative |
| 18 | ~$15-915 (Firewall optional, flagged) | ~$15 (NSG-only egress) |
| 19 | ~$25 (deallocated DR hosts + capacity reservation) | ~$25 |
| 20 | $0 | $0 |
| **Total, disciplined lab use** | | **~$106-121/month** |
| **Total, everything left running continuously, Firewall included** | **~$1,146/month** | |

The wide range in Lab 18 is stated deliberately rather than smoothed over: a full Azure Firewall deployment costs roughly $900/month running regardless of traffic, which is disproportionate for lab purposes, and the lab explicitly recommends NSG-only egress control for lab use with the Firewall pattern documented for readers building toward a production design.

---

## 5. What this plan does not cover, stated honestly

This is a plan, not validated content. Every Terraform snippet, PowerShell command, and diagram described above is a deliverable commitment for the next phase, not something already built or tested. The product-accuracy findings in section 1 are current as of this research pass (August 2026) and are explicitly flagged in Lab 17 as something to re-verify at deployment time, because Dynamic Autoscaling's GA status showed genuine transitional ambiguity in Microsoft's own documentation during this research. No lab in this plan has been deployed against a live Azure subscription; validation evidence descriptions above state what a successful deployment would show, not a confirmed result.

---

## 6. Interview scenario coverage, planned

Each lab closes with interview questions in this book's established format, covering (at minimum): why geographical host pools were chosen over regional host pools given the latter's preview status (Lab 11 or 14), why active-active requires two workspaces and how to explain the duplicate feed to a stakeholder (Lab 14), what `ERROR_LOCK_VIOLATION 33` means and how to prevent it (Lab 15), how to design non-overlapping group assignment (Lab 16), the real difference between Dynamic Autoscaling and Power Management autoscaling and when each applies (Lab 17), why monitoring is regionally siloed with a dashboard on top rather than a shared workspace (Lab 18), and the specific, defensible difference between what Lab 14 and Lab 19 each built (Lab 19 or 20, likely the capstone question for the whole set).

---

## 7. Sequencing confirmation

Labs 11-20 are planned to be built and validated in the order listed above, one at a time, each with its own render-inspect-fix diagram pass and its own real (not asserted) validation evidence, matching the standard already established across Labs 1-10 and Projects 01-15. No lab begins until the plan for it, as stated in this document, is confirmed. No capstone work and no Part XV-XVII assembly begins until Labs 11-20 are complete and validated.
