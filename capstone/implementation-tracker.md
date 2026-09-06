# Northwind Capstone: Master Implementation Status Tracker

**Purpose:** A single, honest inventory of what actually exists versus what has only been designed or described, across Parts A-D, built by inspecting the real files - not from memory of what each part intended to deliver. Updated at the end of every part from this point forward; nothing is removed from the "open" categories until the actual file exists and has been checked.

**Last updated:** end of the Part D→E remediation pass, before Part E's own new content begins.

---

## Diagram staleness closed: Part D's governance diagram now shows platform/rbac correctly

The independent A-H audit found Part D's diagram still depicted all RBAC/PIM roles as living in `platform/security/`, the module they were originally (incorrectly) built in, before the PIM remediation moved them to `platform/rbac/`. Rebuilt: the RBAC zone is now explicitly labelled `(platform/rbac)`, a correction note sits directly beneath it, a fifth "how to read this" note restates it, and the footer's "verified against" line lists both modules by what they actually contain. Rendered, inspected, and confirmed clean before replacing the stale version - this diagram's history is not preserved as a separate file, since the prior version was inaccurate, not merely superseded by new information.

## Part H: operations, DR, monitoring, FinOps - the central finding stated plainly

Before any new design work began, Part H checked whether active-passive DR infrastructure existed anywhere in the capstone. It confirmed, by direct search: **it does not, for any of the five personas, in either direction.** Two active regions (Parts E/F) and cross-region FSLogix redundancy (Part F9) are real and built, but neither is disaster recovery - redundant data with no compute path to reach it in a surviving region is not a working recovery. This is recorded as [ADR-CAP-07](adr/adr-cap-07-dr-gap-finance-first-recommendation.md), with a finance-first recommendation explicitly conditional on Northwind's own approval, not built speculatively.

**Closed in this part:** H1 (two regional AVD monitoring workspaces, additive to the platform baseline), H3 (real Azure Backup for FSLogix - the concrete completion of the redundancy-vs-backup distinction Part F9 first raised), H4 (six autoscaling plans, West Europe's window genuinely wider to cover Bangalore), H5 extended (FinOps now covers all five subscriptions, not just the three platform ones). H6-H8 (two architecture-specific troubleshooting scenarios, five ADRs, seven interview questions) all grounded in what this capstone actually built, not generic AVD content.

**A schema error caught by checking against this book's own already-validated work, not memory.** Building the autoscaling module surfaced three real errors against Lab 17's proven Terraform: a wrong block name, a missing required argument, and a value that should have been genuinely distinct but was set equal to another. All fixed before the module was considered complete - see `avd-platform/autoscaling/README.md`.

## Part F audit, and one process anomaly disclosed rather than hidden

A dedicated Part F audit (requested separately from the remediation pass above) found `host-pools.tf` and its `variables.tf` already contained comments describing a fix - a hardcoded `maximum_sessions_allowed = 8` replaced with a per-persona `max_sessions_per_host` value - with no record of that edit having been made in this conversation. The technical fix itself was independently re-verified as correct (the `Persistent` load-balancer value was re-confirmed against Microsoft's own Azure Verified Modules documentation and the Terraform Registry, not trusted from the comment alone) and is internally consistent with the rest of the module, so it was kept rather than reverted. The anomaly - a self-referential "already audited" claim with no corresponding record - is disclosed here because a claim embedded in code comments deserves the same scrutiny as a claim in prose, not automatic trust.

That same audit found one further, undisclosed issue: the `fslogix` module builds a single shared storage account and combined RBAC group across all five personas per region, including finance - with no document anywhere reasoning about whether finance's host-pool-level compliance isolation should extend to profile storage too. See the finance FSLogix isolation entry below.

## Part G: remote-state strategy, closing a real gap found by inspection

Before writing anything, Part G checked whether the master plan's G2 design (one remote-state backend per layer) had actually been implemented anywhere in Parts B-F. It hadn't: **zero `backend.tf` files existed across all 14 modules**, and every cross-module dependency was wired by manually copying `terraform output` values into the next module's `terraform.tfvars` - functional, but not the scriptable mechanism this book proved out in Labs 11-20.

**Closed in this part:** all 14 modules now have `backend.tf` (11 full config, 3 - `host-pools`, `workspace-appgroups`, `fslogix` - deliberately partial, since they're applied per-region from identical code and a hardcoded key would let one region's state silently overwrite the other's). The four genuinely cross-layer dependencies now use real `terraform_remote_state` data sources instead of manual copy-paste: `network-spokes` reading `management-groups` and `connectivity`; `host-pools` reading `network-spokes`, `identity`, and `monitoring`; `workspace-appgroups` and `fslogix` each reading `network-spokes`.

**A categorization error caught during this part's own build, not after.** The first draft of Part G's own dependency table listed `workspace-appgroups → host-pools` as cross-layer. It isn't - both are `avd-platform`. The genuine cross-layer dependency this module has (`avd_resource_group`, from `network-spokes`) had been missed entirely. Both the code and the document were corrected in the same pass.

**Not converted, disclosed rather than left inconsistent:** within-platform-layer references (`rbac → security`, `finops → subscriptions`) still use the manual-variable pattern - a real, remaining mechanical task, not claimed done.

**One more pre-existing bug surfaced, not introduced, by this part's more thorough validation.** Running the orphaned-variable check across every module (not just the four converted in this pass) found `identity_subscription_id` in `platform/security/terraform.tfvars.example` - a stale line from Part D's own RBAC remediation, referencing a variable that module never declared. Fixed here, credited to Part G's validation reaching further than any single prior part's own review did.

## Remediation pass, completed before Part E

Per explicit instruction, the four priority items below were closed with real Terraform before Part E began, rather than carried forward as documentation debt a fourth time.

| Item | What was actually done | New module |
|---|---|---|
| PIM-eligible claims | All 6 platform roles rebuilt correctly: 5 as genuine `azurerm_pim_eligible_role_assignment` (Platform Engineer, Subscription Owner, Identity Administrator, Network Administrator, Security Administrator), 1 correctly standing (Security Reader). Part B's original 3 roles had **never** had any Terraform at all - built here for the first time. Part D's 2 standing roles were superseded and removed, with an explicit marker file explaining the move. | `platform/rbac/` (new) |
| Entra Connect Sync server | VM infrastructure built for the first time - one primary (East US 2), one staging-mode secondary (West Europe), a new architecture decision closing a regional-resilience gap the original design left open. Software installation and staging-mode configuration remain imperative post-deployment steps, matching the domain-controller pattern - not a new gap, a consistent application of an existing one. | `platform/identity/connect-sync.tf` |
| Monitoring foundation | Tenant-wide Log Analytics workspace built. The diagnostic-settings policy in `platform/policy/` still needs re-applying with this workspace's ID - stated as a manual follow-up dependency, not assumed automatic. | `platform/monitoring/` (new) |
| FinOps budgets | Per-subscription budget mechanism built (80%/100% alerts). Every budget figure is an explicit placeholder - no real on-premises baseline cost has ever been gathered for this engagement, and this remediation does not invent one. | `platform/finops/` (new) |

**A genuine, disclosed tooling risk carried into all future PIM use:** `azurerm_pim_eligible_role_assignment` is real and current, but historical provider issues (2023 GitHub reports of "Role Management Policy... couldn't find resource" on first apply) mean this should be tested in non-production before relying on it for actual break-glass-adjacent platform access.

---

## The headline finding this tracker exists to surface

**RESOLVED by the remediation pass above.** Every role assignment built in Parts B and D used `azurerm_role_assignment` (standing access), while the prose in both parts described these same roles as "PIM-eligible" eleven separate times, with no PIM eligibility rule implemented anywhere. This is now closed: five roles are genuine `azurerm_pim_eligible_role_assignment` resources in `platform/rbac/`, and Security Reader correctly remains standing. This section is kept, not deleted, so the history of the finding and its fix stays visible - a resolved gap is still worth knowing was a gap.

---

## 1. Implemented and validated

"Validated" here means: the Terraform file exists, is structurally correct (brace-balanced, internally consistent variable/output references), and has been checked against the design document that specifies it. **None of the following have been applied against a live Azure subscription** - "validated" is structural, not a deployment confirmation, consistent with every prior claim in this book.

| Item | Part | Module |
|---|---|---|
| Ten host pools (5 personas x 2 regions), standard host-pool management, diagnostic settings applied directly | F | `avd-platform/host-pools` |
| Ten session hosts (sized per Chapter 17), domain-joined via extension | F | `avd-platform/host-pools` |
| Two workspaces, ten application groups | F | `avd-platform/workspace-appgroups` |
| **End User RBAC role, all five personas, both regions - resolves Part E's deliberate deferral** | F | `avd-platform/workspace-appgroups` |
| FSLogix storage, both regions (Premium/ZRS, Private Endpoint) | F | `avd-platform/fslogix` |
| Finance-specific FSLogix RBAC group, separate from the other four personas (ADR-CAP-06) | F | `avd-platform/fslogix` |
| Dedicated finance storage account, share, private endpoint - built, gated OFF by default pending Northwind's compliance decision (ADR-CAP-06) | F | `avd-platform/fslogix` |
| Two AVD subscriptions associated into Corp | E | `avd-landing-zone/network-spokes` |
| AVD spoke VNets, both regions, peered to platform hubs | E | `avd-landing-zone/network-spokes` |
| Host pool naming policy (custom, subscription-scoped) | E | `avd-landing-zone/policy` |
| AVD Platform Engineer, Session Host Operator (PIM-eligible, built correctly from the start) | E | `avd-landing-zone/rbac` |
| Service Desk role (standing, deliberately, not a repeat of the PIM mistake) | E | `avd-landing-zone/rbac` |
| Management group hierarchy (Northwind, Platform, Identity/Management/Connectivity, Landing Zones/Corp, Decommissioned) | B | `platform/management-groups` |
| Subscription associations into that hierarchy | B | `platform/management-groups` |
| Allowed-locations policy (GUID confirmed against Microsoft Learn) | B | `platform/policy` |
| Required-tags policy (5 tags, GUID unconfirmed - see section 3) | B | `platform/policy` |
| Two regional hub VNets, GatewaySubnet, AzureFirewallSubnet | C | `platform/connectivity` |
| Hub-to-hub peering | C | `platform/connectivity` |
| ExpressRoute gateways (`ErGwScale`, SKU confirmed against Microsoft Learn) | C | `platform/connectivity` |
| Azure Firewall Standard, per hub | C | `platform/connectivity` |
| Four domain controller VMs, two per region, in their own spoke | C | `platform/identity` |
| Identity spoke NSGs (scoped to actual AD replication path) and UDRs to the regional Firewall | C | `platform/identity` |
| Platform Key Vault, RBAC-authorized, Private Endpoint only | D | `platform/security` |
| Four platform secrets stored in Key Vault (DC admin, Connect Sync service account) | D | `platform/security` |
| Azure Bastion Premium, per hub (SKU confirmed against Microsoft Learn) | D | `platform/security` |
| Two break-glass Entra ID accounts (`azuread_user`) | D | `platform/security` |
| Identity Administrator, Network Administrator, Security Administrator role **assignments** (standing - see headline finding) | D | `platform/security` |
| **Five roles as genuine `azurerm_pim_eligible_role_assignment`** (Platform Engineer, Subscription Owner, Identity Administrator, Network Administrator, Security Administrator) - closes the headline finding | Remediation | `platform/rbac` (new) |
| Security Reader role assignment (standing, correctly) | Remediation | `platform/rbac` (new) |
| Entra Connect Sync server VMs (primary + staging-mode secondary) - **infrastructure only, software installation still pending, see section 2** | Remediation | `platform/identity/connect-sync.tf` |
| Tenant-wide Log Analytics workspace | Remediation | `platform/monitoring` (new) |
| Per-subscription budgets with 80%/100% alerts - **figures are placeholders, see section 4** | Remediation | `platform/finops` (new) |
| Two regional AVD-specific Log Analytics workspaces, additive to the platform baseline | H | `avd-platform/monitoring` |
| Second diagnostic setting per host pool, routing AVD-specific telemetry to the regional workspace | H | `avd-platform/monitoring` |
| Six independent Power Management Autoscale plans (task/know/fin x 2 regions), West Europe genuinely wider | H | `avd-platform/autoscaling` |
| Azure Backup for FSLogix (Recovery Services vault, daily policy, protected file share, both regions) - closes the redundancy-vs-backup gap Part F9 first raised | H | `avd-platform/backup` |
| FinOps extended to all five subscriptions, including the two AVD ones | H | `platform/finops` |

---

## 2. Designed but not yet implemented

Described in prose, with clear reasoning, but no Terraform (or other implementation artifact) exists yet.

| Item | Part designed in | Why it's not built yet |
|---|---|---|
| Diagnostic-settings policy's actual `DeployIfNotExists` enforcement | B (section 2.5/2.9) | The workspace now exists (remediation), but the policy module has not yet been re-applied with its ID - a manual follow-up step, not automatic |
| Microsoft Defender for Cloud (free tier tenant-wide, enhanced tier scoped) | B (section 2.7) | Designed and reasoned about; no `azurerm_security_center_subscription_pricing` or equivalent resource exists |
| Microsoft Entra Connect Sync **software installation and staging-mode configuration** | C (section 3) | The VM infrastructure now exists (remediation); the software install and sync configuration remain imperative post-deployment steps, matching the domain-controller pattern |
| Azure Bastion session recording (storage account, container, auth mechanism) | D (section 3.5) | SKU decision (Premium) is made; the specific recording configuration is marked `[VERIFY BEFORE IMPLEMENTATION]`, not built |
| Break-glass Conditional Access exclusion policy | D (section 4.4) | Portal/Graph API configuration, not modelled |
| Break-glass sign-in monitoring alert | D (section 4.4) | Same - and Part D's own section 7 names "the alert doesn't fire" as an active, unmitigated failure scenario |
| Custom RBAC role for policy-exemption rights | D (section 3.1/4) | Security Administrator currently only holds Key Vault Administrator; the actual exemption-creation permission has no role definition yet |
| Automated policy-exemption expiry control | D (section 8) | A deliberate, disclosed deferral, not an oversight |
| Regional split of Northwind's 3,200 users between East US 2 and West Europe | F | Never established by any chapter or part - Chapter 1 gives per-persona totals only. `host-pools` module uses an explicit 50/50 placeholder |
| CAD host pool's actual GPU VM SKU | F | Chapter 17 states GPU sizing is a vendor conversation, not a size-table choice - a placeholder example is used, not a decision |
| FSLogix storage sizing for knowledge, finance, CAD, and developer personas | F | Only the task-worker pool has a published worked example (Chapter 20); the other four use an unconfirmed default quota |
| Cloud Cache registry configuration on the ten session hosts | F | Host-level configuration, matching Lab 15's pattern - not yet applied, since it depends on the session hosts (built) and both regions' storage (built) both existing first |
| Intune per-application ownership split for the ~40 LOB applications | F | Named as a real, disclosed gap - not worked through in this pass |
| Azure Compute Gallery and golden image pipeline | F | Architecturally designed (5 images per region), no Terraform built - a focused follow-up pass, not silently assumed done |
| Power Management Autoscale for the ten host pools | F | Explicitly Part H's scope - not reached into from Part F |
| **Finance persona's FSLogix profile storage isolation** | F audit finding | **Resolved via [ADR-CAP-06](adr/adr-cap-06-finance-fslogix-isolation.md), tiered.** RBAC split (finance gets its own share-level group, separate from the other four personas) adopted unconditionally, built in this pass. A fully dedicated storage account remains **BUSINESS/COMPLIANCE DECISION REQUIRED** - file-level isolation already exists via Chapter 20's two-layer model; the dedicated-storage Terraform is fully built and gated behind `enable_finance_dedicated_storage`, default `false`, ready to activate if Northwind's compliance function confirms it's needed |
| **Active-passive cross-region DR, for any persona, in either direction** | H | **Open implementation gap, formalized in [ADR-CAP-07](adr/adr-cap-07-dr-gap-finance-first-recommendation.md).** Lab 19 documents a reference pattern and validation procedure. No Northwind failover test is claimed. A finance-first build remains conditional on business and compliance approval. |
| Golden image cross-region replication (Azure Compute Gallery) | F/H | Still architecturally designed only - this dependency is explicitly named in Part H's own RTO/RPO table (section 2.7) as a gap affecting session-host cross-region recovery time, not newly discovered but newly connected to its DR consequence |
| A tested restore from the new Azure Backup configuration | H | **No restore has ever been performed.** A backup nobody has restored from is a hypothesis, not a capability - stated explicitly in Part H section 3.4, not implied solved by the policy existing |
| Zone-redundancy configuration, independently re-verified as applied to every relevant Part F resource type | H | Referenced as existing guidance (Chapters 17/20) but not independently re-checked against Part F's actual Terraform in this pass - a real, disclosed verification gap, not assumed correct |

---

## 3. Verify before implementation

Every distinct item currently carrying this marker in the actual Terraform or documents, deduplicated.

| Item | File |
|---|---|
| "Require a tag on resources" policy GUID - best-available candidate, not independently confirmed | `platform/policy/variables.tf`, `policy-assignments.tf` |
| Diagnostic-settings policy initiative GUID - varies by resource type, no default set | `platform/policy/variables.tf` |
| `azurerm_bastion_host` schema's current support for session-recording configuration, and the correct auth mechanism | `platform/security/bastion.tf` |
| Whether `Contributor` or a narrower custom role correctly matches Identity Administrator's intended scope | `platform/security/rbac.tf` |
| The exact management-group-scoped permission and role shape needed for policy-exemption rights | `platform/security/rbac.tf` |
| Break-glass account tenant-specific attributes (e.g. usage location) required by your licensing configuration | `platform/security/break-glass.tf` |
| Current Microsoft-recommended break-glass sign-in alert configuration | Part D, section 4.4 |
| `Install-ADDSDomainController` and Connect Sync installation steps, against current Microsoft documentation at implementation time | `platform/identity/domain-controllers.tf` |

---

## 4. Business/compliance decision required

Not Azure technical facts - decisions only Northwind's own function can make, correctly kept out of this document's guesses.

| Item | Who needs to decide | Where it's flagged |
|---|---|---|
| SOX-relevant log retention period | Northwind's compliance/audit function | Part D, section 6 |
| Whether the current on-premises VDI platform's specific vendor/contract affects migration sequencing | Northwind's procurement/IT leadership | Part A, section 3 (stated as an assumption Chapter 1 never resolved) |
| Bangalore's actual per-persona headcount split | Northwind's HR/site leadership | Part A, section 10 (10% growth figure is this document's placeholder assumption, not confirmed) |
| Whether active-passive DR is worth building, for which personas, at what cost | Northwind's business and compliance stakeholders | [ADR-CAP-07](adr/adr-cap-07-dr-gap-finance-first-recommendation.md) - the finance-first recommendation is conditional on this decision, not a substitute for it |
| Whether a dedicated finance FSLogix storage account is required | Northwind's compliance function | [ADR-CAP-06](adr/adr-cap-06-finance-fslogix-isolation.md) |
| FSLogix backup retention period | Northwind's compliance/audit function | Part H, section 3 - the same open question as the platform monitoring workspace's retention, and should be confirmed together, not independently |
| All five subscriptions' actual budget figures | Northwind's finance function | Part H, section 5 - every current figure is an explicit placeholder |

---

## 5. Open gaps, carried forward without a home yet

Distinct from "designed but not implemented" - these are things no part has yet even scoped a design for.

- No PIM eligibility implementation approach has been designed, only named as missing (section 1's headline finding names the gap; no part has yet proposed how to actually close it - a real design task for Part E or a dedicated interim pass, not yet claimed anywhere)
- No cost figure for the current on-premises baseline has been gathered, meaning Part H's eventual FinOps comparison currently has no real number to compare against

---

## 6. Dependencies Part E must not assume are resolved

Stated explicitly so Part E's own text cannot silently imply otherwise. Four of the five original items here were closed by the remediation pass - restated below with their actual current, more nuanced state, not simply deleted:

1. **PIM eligibility is now implemented for 5 platform roles** - but carries a disclosed tooling risk (historical provider issues on first apply, untested against a live subscription). If Part E introduces AVD-specific roles, it should use the same `azurerm_pim_eligible_role_assignment` pattern from `platform/rbac/`, not a fresh standing assignment - and should note the same tooling-risk caveat, not assume the pattern is risk-free just because it now exists.
2. **A monitoring workspace now exists**, but the diagnostic-settings policy has not yet been re-applied to point at it. If Part E's AVD Landing Zone needs to send diagnostics somewhere, confirm that re-application has actually happened, not just that the workspace exists.
3. **Entra Connect Sync server infrastructure now exists**, but the software itself is not installed and staging-mode is not configured. If Part E's AVD session hosts need to be hybrid-joined, the sync pipeline they'd depend on is VMs, not yet a working sync.
4. **Bastion session recording is still not actually configured** - unchanged from before the remediation pass, since this was correctly scoped to Part D's own domain, not one of the four priority items. If Part E's design references audit trails for privileged access, this gap still applies.
5. **A FinOps budget mechanism now exists, with placeholder figures.** Any cost claim Part E makes about the AVD Landing Zone should still be stated as an estimate - the budget mechanism being real does not mean the numbers in it are.

---

## How this tracker will be maintained

Updated at the close of every subsequent part. An item moves from "designed but not implemented" to "implemented and validated" only when the corresponding Terraform file exists and has been checked - not when a part's prose describes it as done.
