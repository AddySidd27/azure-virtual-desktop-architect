# Northwind Capstone, Part F: AVD Platform Architecture

> **Part of:** [Northwind Capstone Master Plan](../../appendices/capstone-northwind-master-plan.md)
> **Sequence:** Part F of A-H. The first part to build an actual AVD resource - everything before this was platform or landing zone, consumed but never occupied.
> **Terraform:** [`terraform/capstone-northwind/avd-platform/`](../../terraform/capstone-northwind/avd-platform/)
> **Diagram:** [`capstone-avd-platform-architecture.svg`](../../diagrams/architecture/capstone-avd-platform-architecture.svg)
> **Status discipline:** every component tagged with exactly one of **Architecturally designed** / **Terraform implemented** / **Structurally validated** / **Requires live Azure validation** / **Business/compliance decision required**.

---

## 0. What this part can safely consume, checked directly before writing anything

Per instruction, this section is the result of actually inspecting the repository, not assuming what exists.

| From | What's available | Confirmed by |
|---|---|---|
| `platform/identity` | Domain controller private IPs (both regions), for session host DNS | `outputs.tf` grep |
| `platform/monitoring` | Log Analytics workspace ID, for host pool diagnostics | `outputs.tf` grep |
| `platform/connectivity` | Hub VNets - not directly consumed here; session hosts live in the AVD spoke, not the hub | `outputs.tf` grep |
| `avd-landing-zone/network-spokes` | AVD spoke VNet IDs, subnet IDs, resource groups, both regions | `outputs.tf` grep |
| `avd-landing-zone/policy` | Host pool naming policy already assigned - Part F's host pools are checked against it, not re-declaring it | `outputs.tf` grep |
| `avd-landing-zone/rbac` | Platform Engineer, Session Host Operator, Service Desk roles already exist; **End User was deliberately not built** - confirmed by that module's own `roles_built` output | `outputs.tf` grep |
| `platform/security` | Key Vault holding DC admin credentials, for session host domain-join | `outputs.tf` grep |
| Chapters 1, 3, 5, 7, 12, 15, 16, 17, 20 | The fixed host pool table, OS default, sizing-by-workload-type mapping, two-layer FSLogix permission model | Direct grep against chapter text |
| `adr-shc-vs-standard-host-pools.md` | Standard host-pool management is the required implementation | Direct read |

**What this part does not recreate.** No new domain controllers, no new hub, no new AVD subscription, no new management group. Every one of those already exists from Parts B-E.

---

## 1. Traceability: Part A through Part F

| Requirement | Earlier part | Part F's consequence |
|---|---|---|
| Six personas, fixed headcounts | A (Chapter 1) | Section 2's host pool table, unchanged from the master plan |
| Chapter 15's five-pool structure | A/master plan | Built exactly, no sixth pool, per the Chapter 3/15 reconciliation already resolved | 
| SHC reconciliation | Existing ADR, master plan 2.1 | Section 3: standard host-pool management, no exception |
| Chapter 17's workload-to-size mapping | Existing chapter | Section 4's VM sizing, cited directly, not invented |
| TR-01/TR-02 (hybrid identity, no forest redesign) | A/C | Section 6: session hosts domain-join against Part C's existing DCs |
| Chapter 20's two-layer permission model | Existing chapter | Section 9's FSLogix design |
| The PIM remediation and Part E's deliberate End User deferral | Remediation/E | Section 10: End User built correctly, for the first time, now that real application groups exist |

---

## 2. Host pool architecture and type

**Status: Architecturally designed, Terraform implemented, structurally validated.**

Five host pools per region, fixed by the master plan's table, unchanged here:

| Persona | Type | Total users | VM size |
|---|---|---|---|
| Task workers | Pooled | 1,400 | `Standard_D2s_v5` |
| Knowledge workers (+ executives) | Pooled | 1,200 | `Standard_D2s_v5` |
| Finance | Pooled | 250 | `Standard_D4s_v5` |
| CAD engineers | Personal | 180 | GPU - **[VERIFY BEFORE IMPLEMENTATION]**, see section 4 |
| Developers | Personal | 170 | `Standard_D8s_v5` |

**Load-balancing strategy.** BreadthFirst for all three pooled pools - spreads sessions across available hosts rather than filling one before starting the next, matching this book's standing default for density-driven pools. Personal pools use a persistent assignment model, not a load-balancing algorithm in the pooled sense - each user's session always lands on their own assigned host.

---

## 3. Session Host Configuration reconciliation, applied, not re-argued

**Status: Architecturally designed and settled.** Standard host-pool management throughout, per [the existing ADR](../../appendices/adr-shc-vs-standard-host-pools.md) and the master plan's own reconciliation (section 2.1): Chapter 16 assumed Northwind's three pooled pools would use Session Host Configuration; the ADR found no stable Terraform resource, preview-only PowerShell, and no non-preview ARM API. This part does not re-litigate that finding - it applies it, exactly as Labs 14-20 already did for the lab environment.

---

## 4. VM sizing and placement

**Status: Architecturally designed (sizing rationale), Terraform implemented, Business/compliance decision required (CAD's exact SKU).**

Sizing follows [Chapter 17](../../chapters/ch17-session-host-sizing-compute-selection.md)'s workload-to-size mapping directly, cited not invented: task/knowledge workers are light-to-medium, finance is medium (sized up one tier for compliance-tooling headroom), developers are heavy, CAD is power-class.

**CAD's GPU size is deliberately not confidently decided.** Chapter 17 states this plainly: *"GPU sizing is a vendor conversation... ask the vendor what they support and test it, rather than choosing a GPU SKU from a size table."* The Terraform's `Standard_NV6ads_A10_v5` is a placeholder example, not a decision - marked `[VERIFY BEFORE IMPLEMENTATION]`, consistent with the chapter's own guidance rather than overriding it with false confidence.

**Placement.** All session hosts live in the AVD spoke (Part E), not the platform hub - the concrete enforcement of TR-05's platform/workload boundary at the compute layer specifically.

---

## 5. Networking and required connectivity

**Status: Terraform implemented, structurally validated. Requires live Azure validation** for actual reachability.

Session hosts sit in `avd-landing-zone/network-spokes`'s existing subnets - no new network resource created here. Connectivity to identity (Part C's DCs), FSLogix storage (section 9), and the internet (via the platform hub's Firewall, Part C) all ride existing platform and landing-zone infrastructure. Part F owns none of it.

---

## 6. Session-host identity and domain-join approach

**Status: Terraform implemented (the extension), Business/compliance decision required (the actual domain name).**

`JsonADDomainExtension`, matching every prior lab's pattern exactly (Lab 8, Lab 14). **A genuine gap found and disclosed, not hidden:** the domain name used had to be a placeholder (`northwind.local`) - no chapter or capstone part has ever stated Northwind's actual on-premises AD domain name, and this must specifically not be confused with `avdlab.local`, the separate Labs 1-20 lab environment's domain, which the master plan explicitly commits this capstone to being independent of.

DNS order matches Part C's design exactly: each region's session hosts list their own region's domain controller first, the other region's second - never a single-region-only path.

---

## 7. NSGs and security boundaries

**Status: Terraform implemented (inherited, not re-declared).**

Session hosts inherit the AVD spoke's existing NSG and UDR-to-Firewall routing from `avd-landing-zone/network-spokes` (Part E) and, transitively, the platform hub's Firewall (Part C). No new NSG rule is created in this part - a session host is a workload occupant of infrastructure Part E already secured, not a reason to add a parallel security layer.

---

## 8. Entra ID and hybrid identity dependencies

**Status: Architecturally designed. Requires live Azure validation.**

Session hosts register in Entra ID via the AVD agent (built into the DSC extension) after domain-joining. This depends on Part C's Entra Connect Sync server actually syncing - and the [implementation tracker](../implementation-tracker.md) is explicit that the sync server's software is not yet installed. **Part F's Terraform does not claim this dependency is satisfied** - it is stated here as an open prerequisite this part inherits, not one it resolves.

---

## 9. FSLogix profile architecture and storage dependency

**Status: Terraform implemented (storage), Architecturally designed (Cloud Cache), Business/compliance decision required (non-task-worker sizing).**

One storage account per region, Premium/ZRS, Private Endpoint only - [Lab 5](../../labs/lab-05-storage.md)/[Lab 13](../../labs/lab-13-regional-storage-foundation.md)'s pattern, applied to Northwind's real regions. Cross-region resilience uses Cloud Cache, but for a **genuinely different reason than Labs 11-20**: Northwind's users are geography-assigned, not active-active-eligible, so Cloud Cache here protects against a single-region storage failure, not cross-region mobility - stated explicitly in the master plan (Part F4) and not muddled with the lab environment's different use of the same mechanism.

**Sizing gap, disclosed.** Only the task-worker pool has a published worked example (Chapter 20's 32,000-peak-IOPS calculation). The other four personas' storage needs have never been separately sized in this book - the Terraform's default quota is a reasonable placeholder, not a confirmed calculation for finance, CAD, developers, or the combined knowledge/executive pool.

---

## 10. RBAC and PIM integration

**Status: Terraform implemented, structurally validated - and the specific proof the PIM lesson was retained.**

Four AVD-specific roles now exist: AVD Platform Engineer and Session Host Operator (PIM-eligible, built in Part E), Service Desk (standing, deliberately, built in Part E), and **End User** - built here, in this part, for the first time, because its correct scope (real, persona-specific application groups) did not exist until this part created them. End User is standing, not PIM-eligible - a user does not activate the ability to use their own desktop - decided deliberately and stated so, not defaulted without thought the way the original PIM gap was.

---

## 11. Intune and device-management dependencies

**Status: Architecturally designed. Business/compliance decision required.**

Following the master plan's GPO/Intune split (Part F6, adapted from [Project 04](../../scenarios/project-04-hybrid-active-directory.md)): GPO retains AD-dependent legacy settings, Intune owns FSLogix configuration and any setting genuinely new to the AVD estate. **No Intune Terraform exists in this part** - Intune configuration is Graph API/portal-managed, not a resource this document fabricates a shape for. The specific ownership split for each of the ~40 line-of-business applications is not yet worked through - a real, disclosed gap for a later pass, not claimed as solved here.

---

## 12. Monitoring and diagnostics

**Status: Terraform implemented, structurally validated.**

Each host pool gets its own diagnostic setting, pointed directly at the monitoring workspace built in the remediation pass - applied now, not waiting on the tenant-wide diagnostic-settings policy's re-application, which remains a separate, tracked follow-up per the implementation tracker.

---

## 13. Scaling strategy

**Status: Architecture documented and Terraform reference module present. Requires live Azure validation.**

The reference implementation uses power-management autoscale for standard-management host pools. The module is under `terraform/capstone-northwind/avd-platform/autoscaling/`. It still requires provider validation, a reviewed plan, and testing in an authorized Azure environment.

---

## 14. Availability and regional considerations

**Status: Architecturally designed.**

Each region's five host pools are independent - a regional failure affects that region's persona pools, not the other region's, following the same active-passive (not active-active) reasoning the master plan's Part H2 commits to for the platform overall. Detailed HA/DR design, RTO/RPO derivation, and failure-scenario testing are explicitly Part H's work, not duplicated here.

---

## 15. User and application assignment model

**Status: Terraform implemented, structurally validated.**

Non-overlapping by region: a persona's East US 2 application group and West Europe application group are assigned to disjoint Entra groups, the same discipline Labs 11-20 proved prevents the FSLogix lock-violation failure mode. Application delivery (RemoteApp vs. full desktop, App Attach for the ~40 LOB applications) follows [Chapter 25](../../chapters/ch25-application-delivery-remoteapp-design.md)'s framework - **not built in this part**: every application group created here is a Desktop type, matching the master plan's reconciliation that external-partner LOB access rides inside an existing pool's application group rather than requiring a sixth host pool, but the specific per-application RemoteApp packaging work is a disclosed, deferred item, not claimed complete.

---

## 16. Image strategy

**Status: Architecturally designed. Terraform not yet built.**

Five distinct golden images per region (one per persona), per the master plan's Part F3 - CAD needs GPU drivers and licensed software baked in, developers need local admin and tooling, finance's SOX scope argues for the smallest application footprint. Azure Compute Gallery and the drain-and-replace update pattern from [Chapter 23](../../chapters/ch23-golden-image-engineering.md) are the intended mechanism. **No Compute Gallery resource is built in this part** - stated honestly rather than rushing a partial image pipeline into a part already covering this much ground; a focused pass on image strategy specifically is a real, named follow-up, not silently assumed complete.

---

## 17. What Part F validates, and what remains

**Validated:** every design decision traced to a specific chapter, ADR, or earlier part - checked against the actual source text, not memory. Section 0's consumption inventory built from real `grep` output, not assumption. Two real errors caught during this build, not shipped: an accidental reuse of the lab environment's domain name (`avdlab.local`) instead of a Northwind-specific placeholder, and an unconfirmed `load_balancer_type` schema value, both fixed or flagged before this document was finalized.

**Not yet done, stated plainly:** live validation of every dependency this part inherits but does not resolve - Entra Connect Sync's software installation, the regional-split business decision, CAD's real GPU SKU, non-task-worker FSLogix sizing, Intune's per-application ownership split. Scaling, HA/DR, and image pipeline Terraform - all correctly deferred to Part H or a dedicated follow-up, not silently claimed done here.

---

## What comes next

[Part G - Implementation with Terraform](../../appendices/capstone-northwind-master-plan.md#part-g---implementation-with-terraform) is largely already demonstrated by the module structure built across Parts B, E, and F - platform, AVD landing zone, and AVD platform, each in its own directory, each consuming the layer below without owning it. [Part H - Operations, DR, Monitoring and FinOps](../../appendices/capstone-northwind-master-plan.md#part-h---operations-dr-monitoring-and-finops) is where autoscaling, HA/DR, and the real cost model this part deliberately deferred finally get built.
