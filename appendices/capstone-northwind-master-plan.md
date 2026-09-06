# Northwind Global Manufacturing: Capstone Master Plan

**Status:** Planning document, revision 2. Scope expanded on explicit instruction to start one level above AVD: Enterprise Azure Landing Zone first, AVD Landing Zone as a distinct, subordinate layer within it, then the AVD platform itself. No capstone content has been written yet. This plan is reviewed and approved before any capstone file, diagram, or Terraform module is created.
**Date:** August 2026
**Customer:** Northwind Global Manufacturing, established in [Chapter 1, section 4](../chapters/ch01-what-avd-actually-is.md#4-meet-the-capstone-customer-northwind-global-manufacturing)
**Position in the book:** The final synthesis. Every chapter, lab, and project this book has built exists so that this document can be a design defence, not a fresh design exercise.

---

## 0. What changed in this revision, and why

Revision 1 of this plan treated Northwind's Azure estate as a given - an **[ASSUMPTION]** that Northwind already had a Cloud Adoption Framework-aligned landing zone, and the AVD platform simply landed into it. That assumption is now removed. This revision builds the Enterprise Azure Landing Zone from scratch, as its own architectural layer, before any AVD-specific decision is made, and then builds a distinct, clearly-separated AVD Landing Zone on top of it. The two are never conflated: every section below states which layer it belongs to.

The eight-stage journey requested, and how this plan is now structured around it:

```text
1. Enterprise Discovery and Requirements       -> Part A
2. Azure Enterprise Landing Zone               -> Part B
3. Identity and Connectivity Foundation        -> Part C
4. Governance and Security Foundation          -> Part D
5. Dedicated AVD Landing Zone                  -> Part E
6. AVD Platform Architecture                   -> Part F
7. Implementation with Terraform               -> Part G
8. Operations, DR, Monitoring and FinOps       -> Part H
```

Everything already validated in revision 1 - the Northwind facts pulled directly from 11 chapters, the reconciliation with the Labs 11-20 ADR - is preserved and carried into this structure, not redone. Every major decision throughout is still tagged **[EXISTING]**, **[NEW]**, **[RECONCILED]**, or **[ASSUMPTION]**.

---

## PART A - Enterprise Discovery and Requirements

### A1. Business requirements [EXISTING, Chapter 1, restated as a discovery output]

3,200 users, three sites, six personas, SOX scope, 99.5% availability, budget must not exceed current on-premises VDI run cost. Full detail in section 1.1 below.

### A2. Technical requirements [NEW]

- A single Azure tenant, one Enterprise Landing Zone, hosting both platform services and the AVD workload
- Two Azure regions for compute and identity (East US 2, West Europe) - the region decision itself belongs to Part C, but the requirement that Northwind's design must state a clear regional strategy is captured here
- Hybrid identity: on-premises AD, fifteen years of GPO, synced to Entra ID - carried forward unchanged, this is not re-decided
- A network design that supports ExpressRoute at two sites and a documented, secured internet path for a third site with no ExpressRoute
- A governance model that enforces naming, tagging, and policy as code, not as a document nobody re-reads after week one (the standard this book has held every project to since Project 03)

### A3. Current-state assessment [ASSUMPTION, stated as such]

Chapter 1 does not describe Northwind's current Azure footprint, if any, beyond referencing "the current on-premises VDI run cost." This plan assumes, and states as an assumption rather than fact: Northwind has some existing Azure presence (at minimum, the Entra ID tenant that on-premises AD already syncs to, per Chapter 7), but **no existing enterprise-scale landing zone** - no management group hierarchy beyond the tenant default, no platform subscriptions, no centrally enforced policy. This is the deliberate scope decision that makes Part B genuine, real architectural work rather than a formality: the capstone builds the landing zone Northwind does not yet have, rather than assuming one into existence.

### A4. Assumptions and constraints, consolidated

| # | Statement | Type |
|---|---|---|
| 1 | Northwind's current on-premises VDI platform is a legacy, Windows Server-based estate reaching hardware end-of-life | [ASSUMPTION] - Chapter 1 is deliberately silent on the specific vendor |
| 2 | Northwind has an Entra ID tenant already, via AD sync, but no enterprise-scale landing zone | [ASSUMPTION] |
| 3 | The AVD workload must not increase Northwind's steady-state run cost versus the current on-premises platform | [EXISTING], Chapter 1 |
| 4 | Bangalore's specific persona headcount split is not stated in Chapter 1 | [ASSUMPTION] - reasoned in Part E |
| 5 | Northwind's board has approved this as a platform replacement project, not a pilot | [ASSUMPTION], implicit in the scale (3,200 users, all personas) |

### A5. Compliance [EXISTING, Chapter 1, elaborated]

Financial data in SOX scope. This plan's compliance posture for the finance persona (250 users) reuses [Project 11](../scenarios/project-11-highly-secure-regulated.md)'s control catalogue and evidence-query pattern directly, adapted from healthcare/patient-data framing to SOX/financial-controls framing - see Part F, section F7.

### A6. Availability, RTO and RPO [EXISTING target, NEW derivation]

99.5% availability is the stated target ([Chapter 1](../chapters/ch01-what-avd-actually-is.md#4-meet-the-capstone-customer-northwind-global-manufacturing)). This plan derives the RTO/RPO that actually satisfies that target using [Project 14](../scenarios/project-14-disaster-recovery.md)'s business-impact-analysis method, not a number chosen to sound appropriately serious - see Part H, section H2.

### A7. Capacity planning [EXISTING, Chapter 12 and 20 worked examples]

Task worker subnet and storage sizing already worked through with real numbers in Chapters 12 and 20 (section 1 below). Extended in Part F to the remaining four personas, none of which have a published worked example yet.

### A8. Regional strategy [EXISTING, Chapters 3/7/12/15, extended for Bangalore in Part E]

East US 2 and West Europe are the two Azure regions, already fixed across four chapters. Bangalore's connectivity path is the one genuine open question, resolved in Part E once the AVD Landing Zone's network spokes are defined, not before - Bangalore is a workload-level connectivity decision, not a platform-level one.

### A9. Risks, identified at the discovery stage

| Risk | Type | Mitigation approach |
|---|---|---|
| Building a full enterprise landing zone is a materially larger scope than an AVD-only project and could balloon past what a single capstone should cover | Delivery | Part B is scoped deliberately narrow: the specific platform subscriptions and policies AVD actually needs, not a speculative full enterprise landing zone covering workloads Northwind hasn't asked for |
| Reconciling Chapter 16's SHC-based design with the Labs 11-20 ADR could be missed if not called out explicitly | Consistency | Already handled in section 2.1, carried forward unchanged |
| Cost ceiling constraint could be treated as a slogan rather than a real design driver | Rigor | Part H's FinOps section requires a stated baseline figure and traceable trade-offs, not a general cost-consciousness gesture |

### A10. Stakeholder requirements [NEW]

| Stakeholder | Requirement |
|---|---|
| CFO | Steady-state Azure cost at or below current on-premises run cost; auditable SOX controls for finance persona |
| CISO | Hybrid identity preserved, Conditional Access and PIM enforced tenant-wide, not just for AVD |
| Site leads (Chicago, Amsterdam, Bangalore) | Consistent user experience; Bangalore's lack of ExpressRoute must not mean a second-class experience |
| Platform/infrastructure team | A landing zone they can operate and extend to future workloads, not a one-off AVD-shaped subscription |
| AVD operations team | The same operational discipline (monitoring, autoscaling, DR) this book has built for every prior lab and project |

---

## PART B - Azure Enterprise Landing Zone

This part is genuinely new and is not an AVD topic. It exists because a real Senior Cloud Architect engagement of this shape starts here, and because Part E cannot honestly claim to be "a dedicated AVD Landing Zone distinct from the enterprise landing zone" unless the enterprise landing zone is actually built first, on its own terms.

Grounded directly in Microsoft's Cloud Adoption Framework enterprise-scale landing zone architecture, already partially cited in this book at [Chapter 2](../chapters/ch02-control-plane-management-plane-data-plane.md) and [Chapter 12](../chapters/ch12-enterprise-topologies-ip-planning.md).

### B1. Management group hierarchy [NEW]

```text
Tenant Root Group
  Northwind (Intermediate Root)
    Platform
      Identity          <- domain controllers, Entra Connect, PIM administration
      Management        <- central Log Analytics, Azure Automation, Sentinel
      Connectivity       <- hub VNets, ExpressRoute circuits, Azure Firewall, private DNS zones
    Landing Zones
      Corp               <- workloads requiring on-premises/hybrid connectivity - AVD lands here
      Online              <- internet-facing workloads with no corp connectivity requirement
    Decommissioned
    Sandbox
```

**Why AVD lands in Corp, not Online.** Chapter 12 already states this precisely: *"AVD is deployed into an application landing zone... The hub, firewall, ExpressRoute and central DNS belong to the platform team."* AVD requires hybrid AD (Chapter 7) and ExpressRoute connectivity at two of three sites, which is the exact definition of a Corp-connected workload in Microsoft's model. This is not a fresh decision - it is Chapter 12's existing guidance, applied.

### B2. Subscription strategy: platform vs workload [NEW]

| Subscription | Management group | Purpose |
|---|---|---|
| `sub-northwind-identity` | Platform/Identity | Domain controllers (both regions), Entra Connect servers, PIM-eligible role definitions |
| `sub-northwind-management` | Platform/Management | Tenant-wide Log Analytics, Azure Automation, Microsoft Sentinel |
| `sub-northwind-connectivity` | Platform/Connectivity | Hub VNets (both regions), ExpressRoute circuits, Azure Firewall, private DNS zones |
| `sub-northwind-avd-prod` | Landing Zones/Corp | The AVD platform itself - see Part E |
| `sub-northwind-avd-nonprod` | Landing Zones/Corp | AVD test/pilot environment, kept genuinely separate from production |

**Why separate platform subscriptions rather than one shared subscription.** The same reasoning [Project 03](../scenarios/project-03-global-enterprise-governance.md) already established for a different customer: subscriptions are the real boundary for budget, blast radius, and Azure Policy scope. A misconfigured policy or a runaway automation script in the AVD workload subscription should not be able to reach the identity or connectivity subscriptions, and vice versa.

### B3. Production vs non-production separation [NEW]

A separate `sub-northwind-avd-nonprod` subscription, not a resource-group-level split inside one subscription, for the same blast-radius reasoning as B2. Non-production is where golden-image builds are validated (Chapter 23's discipline) and where a new host pool configuration is piloted before it touches the 3,200-user production estate.

### B4. Naming and tagging [NEW at the enterprise level, extending the AVD-specific convention already fixed]

Enterprise-wide tag schema, enforced by Azure Policy (B6), not convention:

| Tag | Purpose |
|---|---|
| `BusinessUnit` | Northwind is a single enterprise, so this is fixed to `Northwind` tenant-wide, reserved for future multi-BU growth |
| `Environment` | `prod` / `nonprod` |
| `CostCentre` | Finance chargeback code |
| `DataClassification` | Flags SOX-scope resources specifically (the finance persona's pool and storage) |
| `Owner` | Named accountable role |

AVD's own resource naming (`hp-task-prd-eus2-01`, already fixed across four chapters) sits inside this enterprise tagging scheme, not in competition with it.

### B5. Identity, connectivity, and management, at the platform layer [NEW]

Detailed in Part C. This section only states the ownership boundary: platform subscriptions in B2 own the domain controllers, the hub networks, and the central monitoring; the AVD Landing Zone (Part E) consumes them and states its requirements, exactly as Chapter 12 frames the platform/workload split.

### B6. Azure Policy [NEW]

An enterprise-wide policy initiative assigned at the `Northwind` intermediate root management group, covering: mandatory tags (B4), allowed regions (East US 2 and West Europe only, at the platform level - a workload wanting a third region would need an explicit, reviewed exception), and a mandatory diagnostic-settings policy ensuring every resource, in every subscription, sends logs to the platform Management subscription's Log Analytics workspace by default. AVD-specific policies (host pool configuration standards, session host baseline) are assigned at the `Landing Zones/Corp` level or narrower, not tenant-wide, following [Project 03](../scenarios/project-03-global-enterprise-governance.md)'s pattern of universal-versus-exception policy scoping.

### B7. RBAC and privileged access, at the enterprise level [NEW]

Enterprise-wide roles, distinct from and broader than the AVD-specific roles in Part E:

| Role | Scope | Standing or PIM-eligible |
|---|---|---|
| Platform Engineer | Platform management group | PIM-eligible |
| Subscription Owner (per landing zone subscription) | That subscription only | PIM-eligible |
| Security Reader (CISO's team) | Tenant root, read-only | Standing - visibility should never require activation friction |

AVD's own operational roles (Session Host Operator, Service Desk, End User - matching [Project 03](../scenarios/project-03-global-enterprise-governance.md)'s established model) are scoped inside `sub-northwind-avd-prod` only, and are covered in Part E, not here.

### B8. Security baseline [NEW]

Microsoft Defender for Cloud enabled tenant-wide at the `Northwind` management group, with the enhanced (paid) plan scoped specifically to the subscriptions holding SOX-relevant data - a deliberate, cost-aware scoping decision rather than enabling the most expensive tier everywhere by default, consistent with this book's general cost-consciousness.

### B9. Monitoring and logging, at the platform level [NEW]

One tenant-wide Log Analytics workspace in `sub-northwind-management`, receiving platform-level diagnostics (Azure Policy compliance, Microsoft Defender for Cloud alerts, Entra ID sign-in logs). AVD's own workload-specific monitoring (Part H) uses its own regional workspaces, following the Labs 11-20 pattern of not sharing a single workspace across independently-important components - the platform workspace and the AVD workspaces are related but distinct, and this plan states that distinction rather than blurring platform and workload monitoring into one.

### B10. FinOps, at the enterprise level [NEW]

Cost Management scoped at the `Northwind` management group, with budgets and alerts configured per subscription (B2). This is the enterprise-level cost visibility Northwind's CFO stakeholder requirement (A10) needs; the AVD-specific cost optimization work (autoscaling economics, the cost-ceiling trade-off) lives in Part H and rolls up into this enterprise view, not the other way around.

---

## PART C - Identity and Connectivity Foundation

This is the platform-layer infrastructure that both the enterprise landing zone and, later, the AVD workload depend on. Built once, in the platform subscriptions from Part B, before any AVD-specific resource exists.

### C1. Hub-and-spoke vs Virtual WAN [EXISTING decision trigger, Chapter 12; NEW application to Northwind]

**Already established, Chapter 12, citing Microsoft directly:** *"the trigger is more than two regions plus a need for global transit, not spoke count on its own."*

**Applied to Northwind:** two Azure regions (East US 2, West Europe), no third region (Bangalore connects over the internet, per Part E - not a third Azure region requiring transit). Northwind does not meet Microsoft's own stated trigger for Virtual WAN. **Decision: hub-and-spoke, one hub per region**, matching the exact pattern this book already built and validated in [Labs 11-20](../appendices/labs-11-20-plan.md), reused here at the platform layer rather than re-derived.

### C2. ExpressRoute [EXISTING, Chapter 1 and 7]

ExpressRoute circuits at Chicago (terminating into the East US 2 hub) and Amsterdam (terminating into the West Europe hub). No ExpressRoute at Bangalore - carried forward unchanged from Chapter 1.

### C3. Regional connectivity [NEW, built on C1]

Each region's hub holds the ExpressRoute gateway, Azure Firewall, and central DNS resolution. The two hubs are peered directly to each other (not through a third, shared transit component - hub-and-spoke at this scale doesn't need one), carrying AD replication traffic (C7) and any cross-region platform monitoring traffic.

### C4. DNS [EXISTING pattern, Chapter 11; NEW application]

Following this book's established pattern (Labs 11-12): each region's domain controllers serve as that region's primary DNS, with the other region's domain controllers as secondary - never a single region as the only DNS path for the other.

### C5. Private Endpoints [EXISTING, Chapter 11 and 13]

FSLogix storage and any platform PaaS service (Key Vault, the central Log Analytics workspace) reachable only via Private Endpoint, no public network access - this book's standing default since Chapter 13, not a new decision for Northwind.

### C6. Azure Firewall, NSGs, and UDRs [EXISTING pattern, NEW scoping decision]

Azure Firewall at each regional hub for centralized egress control and logging, following the cost-aware pattern [Lab 18](../labs/lab-18-regional-security-monitoring.md) already established: Firewall is a real, ongoing cost (~$900/month per instance running continuously), justified here because it's a *platform-shared* resource across every future workload landing in Corp, not a cost this plan should discourage the way Lab 18 discouraged it for a single lab environment's egress control. NSGs at every spoke subnet boundary regardless, matching this book's defence-in-depth default. UDRs route spoke-to-spoke and spoke-to-on-premises traffic through the regional firewall, not direct peering bypass.

### C7. Inter-region connectivity [NEW, built on C3]

Hub-to-hub peering (C3) carries the two traffic types this book already knows how to handle: AD replication (Chapter 7's two-region DC design) and any future cross-region platform traffic. AVD-specific cross-region traffic (Cloud Cache replication) is a workload concern, addressed in Part F, riding on this platform connectivity rather than building its own.

### C8. Hybrid AD and Microsoft Entra ID [EXISTING, Chapter 7, unchanged]

Full detail in section 1.2 below. This is platform-layer identity infrastructure - it lives in `sub-northwind-identity` (B2), not inside the AVD workload subscription, which is itself a meaningful clarification this revision adds: the domain controllers are platform infrastructure Northwind's whole enterprise depends on, and AVD is one consumer of them, not their owner.

### C9. Domain controller strategy [EXISTING, Chapter 7]

Two DCs in East US 2, two in West Europe, synced with the on-premises forest. Unchanged.

### C10. AD Sites and Services [NEW, extending the existing DC placement]

Two AD sites matching the two Azure regions, plus Bangalore's subnet (once defined in Part E) mapped to whichever region's site actually serves it - resolved concretely once Part E's Bangalore decision is finalized, following the exact mapping method already proven in [Lab 12](../labs/lab-12-regional-identity.md).

### C11. Authentication resilience [EXISTING, Chapter 7's validation method]

Already specified: measure logon time per region separately, then deliberately break the ExpressRoute path in a test window to confirm regional DCs keep local logons working without it. This plan adopts this test unchanged as part of Part H's validation requirements.

### C12. Conditional Access and MFA [EXISTING tenant-wide, Chapter 9; NEW for Bangalore]

Tenant-wide Conditional Access and MFA already assumed as baseline hygiene per Chapter 9. The Bangalore-specific policy (compliant device required, given no ExpressRoute-secured network path) is genuinely new, detailed in Part E once Bangalore's connectivity decision is made.

### C13. PIM and RBAC, platform layer [NEW, covered in B7]

Cross-referenced from B7 - stated here for completeness in the requested sequence, not duplicated.

---

## PART D - Governance and Security Foundation

Largely a restatement and cross-reference of Part B's governance content (B6-B9), placed here explicitly because the requested journey separates "landing zone" from "governance and security foundation" as distinct stages even though this plan implements them together in Part B for practical reasons - they are the same Terraform and the same Azure Policy initiative, not two separate builds.

### D1. Why governance is not a separate build phase from the landing zone [NEW, a stated design position]

Azure Policy, RBAC, and the security baseline are properties of the management group and subscription structure, not resources bolted on afterward. Building them as a nominally separate "phase" would mean either deploying the landing zone once without policy and once with it (wasteful and risks resources existing briefly out of compliance), or artificially splitting one Terraform apply into two for no architectural reason. This plan's phase list (Part 26, revised) reflects this: Phase 1 delivers Part B and Part D together, as one governed landing zone, not landing zone then governance as sequential afterthoughts.

### D2. What this section adds beyond Part B [NEW]

**Governance exceptions process.** Following [Project 03](../scenarios/project-03-global-enterprise-governance.md)'s exact discipline: every exception to the enterprise policy baseline is documented, has a named accountable owner, and has either an end date or an annual review date. Applied here specifically to the one exception this plan already anticipates: `sub-northwind-avd-nonprod`'s pilot environment may need a temporarily relaxed image-approval policy during initial build, time-boxed and reviewed.

**Compliance evidence, tenant-wide.** The Sentinel-backed evidence query pattern from [Project 11](../scenarios/project-11-highly-secure-regulated.md) is deployed at the platform Management subscription level (B9), with the AVD-specific query (Part F, F7) as one saved query among others the platform will accumulate over time - stated so the AVD-specific compliance work is visibly an instance of a general platform capability, not a one-off.

---

## PART E - Dedicated AVD Landing Zone

**This is the layer the previous revision of this plan did not clearly separate from the platform, and the distinction the user's instruction specifically requires: the Enterprise Azure Landing Zone (Parts B-D) is not the AVD Landing Zone. The AVD Landing Zone is a workload landing zone, living inside `Landing Zones/Corp`, consuming the platform's identity, connectivity, and governance, and adding only what AVD specifically needs.**

### E1. What lives in the AVD Landing Zone, and what does not [NEW]

| Lives in the AVD Landing Zone (`sub-northwind-avd-prod` / `-nonprod`) | Lives in the Platform, consumed not owned |
|---|---|
| Host pools, workspaces, application groups | Domain controllers (`sub-northwind-identity`) |
| AVD session host VMs and their spoke VNets | Hub VNets, ExpressRoute, Azure Firewall (`sub-northwind-connectivity`) |
| FSLogix storage accounts | Tenant-wide Log Analytics baseline (`sub-northwind-management`) - AVD's own regional workspaces are additional, not a replacement |
| AVD-specific Azure Policy (host pool naming, session host baseline) | Enterprise-wide tagging and allowed-region policy (inherited, not re-defined) |
| AVD-specific RBAC (Session Host Operator, Service Desk, End User) | Platform Engineer, Subscription Owner roles |

### E2. AVD Landing Zone network spokes [NEW, built on C1]

One spoke VNet per region, peered to that region's platform hub (not to each other directly - cross-region AVD traffic, such as Cloud Cache replication, routes through the two hubs' peering from C3, matching how every other workload in Corp would also reach another region). This mirrors the Labs 11-20 spoke pattern exactly, now correctly positioned as a workload spoke under a platform hub rather than a lab environment's only network.

### E3. Bangalore's connectivity, decided here [NEW, resolving the Part A open question]

**Two options considered**, matching revision 1's reasoning, now correctly framed as an AVD Landing Zone (workload) decision, not a platform one:

- **Option A: internet-based access to the West Europe AVD spoke.** No new platform region, no new hub. Bangalore users connect over the public internet to West Europe's AVD workspace, secured by Conditional Access (C12) requiring a compliant device and MFA.
- **Option B: a third platform region.** Would require a new hub in Part B/C, a new ExpressRoute circuit or equivalent, and a new AD site - a platform-level change, not a workload-level one, directly working against the cost ceiling (A2, A4).

**Decision: Option A**, unchanged from revision 1, now correctly stated as a workload-landing-zone decision that does not require touching the platform tier at all - which is itself the point of separating these two layers: Bangalore's entire resolution lives inside the AVD Landing Zone's Conditional Access policy and workspace assignment, with zero platform-level change required.

### E4. AVD-specific Azure Policy [NEW, distinct from B6]

Assigned at the `sub-northwind-avd-prod` subscription, not the management group: host pool and session host naming pattern enforcement (`hp-<persona>-<env>-<region>-<instance>`, already fixed by existing chapters), mandatory diagnostic settings pointing at the AVD Landing Zone's own regional workspace (Part H) in addition to the inherited platform baseline (B9).

### E5. AVD-specific RBAC [NEW, distinct from B7]

The five-role model already proven in [Project 03](../scenarios/project-03-global-enterprise-governance.md) - Platform Engineer (here, scoped to the AVD Landing Zone specifically, distinct from the enterprise Platform Engineer in B7), Business Unit AVD Admin (Northwind has one business unit, so this collapses to a single AVD Admin role), Session Host Operator, Service Desk, End User.

---

## PART F - AVD Platform Architecture

This part is the direct continuation of revision 1's sections 5-14, now explicitly positioned as living inside the AVD Landing Zone (Part E), consuming the platform (Parts B-D), rather than floating independently.

### F1. Identity and authentication, as consumed by AVD [EXISTING, section C8-C11 cross-referenced]

AVD session hosts domain-join against the platform's domain controllers (C8-C9) and register in Entra ID. No AVD-specific identity infrastructure - this is the concrete demonstration of "AVD is a workload, not a platform," Chapter 12's framing, now structurally true in this plan rather than just stated.

### F2. Host pool strategy and user personas [EXISTING, Chapter 15, section 1.4 below]

Five host pools per region, unchanged from revision 1.

### F3. Session host image strategy [EXISTING + NEW, unchanged from revision 1 section 8]

Five distinct images per region, golden-image discipline per Chapter 23.

### F4. FSLogix architecture and profile resilience [EXISTING + NEW, unchanged from revision 1 section 9]

Region-primary storage with Cloud Cache cross-region resilience, adapted from Lab 15's mechanism for Northwind's geography-assigned (not active-active-eligible) user base.

### F5. Application delivery and RemoteApp strategy [RECONCILED + NEW, unchanged from revision 1 section 10]

The Chapter 3/Chapter 15 pool-count reconciliation, LOB-apps-for-partners delivered as RemoteApp inside an existing pool's application group rather than a sixth host pool.

### F6. Intune and endpoint management [EXISTING + NEW, unchanged from revision 1 section 11]

GPO/Intune ownership split, adapted from Project 04's pattern.

### F7. Security, compliance, and SOX considerations [NEW, unchanged from revision 1 section 12]

Project 11's control catalogue and evidence-query pattern, applied to the finance persona.

### F8. Session Host Configuration reconciliation [RECONCILED, unchanged from revision 1 section 2.1]

Standard host-pool management is the capstone's required Terraform implementation, for the same reasons as the existing ADR; Chapter 16's SHC-based design intent is preserved as the architectural rationale for *why* these three pools are large and homogeneous, not as the literal implementation.

---

## PART G - Implementation with Terraform

### G1. Module structure, reflecting the four-layer architecture [NEW, structurally different from revision 1]

Revision 1 proposed one `terraform/capstone-northwind/` tree. This revision splits it to mirror the architecture's actual layering, so the Terraform structure itself demonstrates the enterprise/AVD landing zone distinction, not just the prose:

```text
terraform/capstone-northwind/
  platform/
    management-groups/     <- Part B1
    identity/               <- Part B2, C8-C11 (sub-northwind-identity)
    connectivity/           <- Part B2, C1-C7 (sub-northwind-connectivity)
    management/             <- Part B2, B9 (sub-northwind-management)
    policy/                 <- Part B6, D
  avd-landing-zone/
    network-spokes/         <- Part E2
    policy/                 <- Part E4
    rbac/                   <- Part E5
  avd-platform/
    host-pools-eastus2/     <- Part F2
    host-pools-westeurope/  <- Part F2
    fslogix/                <- Part F4
    monitoring/             <- Part H3
    autoscaling/            <- Part H4
```

**Why this split matters beyond tidiness.** A reader (or a future engineer) working in `avd-platform/` should never need write access to `platform/` - the directory structure enforces the same separation of concerns the management group hierarchy enforces in Azure itself. This is a genuinely new structural decision this revision makes that revision 1's single-tree proposal did not.

### G2. Remote state strategy [NEW]

One remote state backend per layer (platform, AVD landing zone, AVD platform), not per individual module within a layer where they share a natural lifecycle - platform components change rarely and together; AVD platform components (host pools, autoscaling) change more frequently and independently, following this book's established `terraform_remote_state` cross-referencing pattern throughout Labs 11-20.

---

## PART H - Operations, DR, Monitoring and FinOps

### H1. Monitoring, logging, and operational model [EXISTING + NEW, unchanged from revision 1 section 13]

Two regional AVD-specific Log Analytics workspaces, additional to the platform baseline (B9), joined by one cross-workspace dashboard per Lab 18's pattern.

### H2. High availability and disaster recovery [NEW, unchanged from revision 1 section 15]

Active-passive cross-region relationship, RTO/RPO derived via Project 14's business-impact-analysis method against the 99.5% target (A6).

**Post-build correction, added when Part H was actually delivered:** building this found that no active-passive infrastructure had been implemented anywhere in Parts E-F - two independently active regions and cross-region data redundancy exist, but no cross-region compute failover mechanism does, for any persona. See [Part H, section 2](../capstone/parts/part-h-operations-dr-monitoring-finops.md#2-high-availability-and-disaster-recovery-precisely-distinguished) and [ADR-CAP-07](../capstone/adr/adr-cap-07-dr-gap-finance-first-recommendation.md) for the finding and the conditional finance-first recommendation. This paragraph's original text is left unchanged above so the plan's original intent stays visible next to what was actually found.

### H3. Backup and recovery boundaries [NEW, unchanged from revision 1 section 16]

Terraform recreates infrastructure, does not recover data - Project 14's core distinction, applied to Northwind's FSLogix and golden-image estate.

### H4. Autoscaling and capacity strategy [EXISTING + RECONCILED, unchanged from revision 1 section 14]

Power Management Autoscale, six independent scaling plans, per the same SHC reconciliation as F8.

### H5. Cost optimization and FinOps [NEW, unchanged from revision 1 section 17, now explicitly rolling up into B10]

The cost-ceiling trade-off analysis, now explicitly stated as feeding the enterprise-level Cost Management view (B10) rather than existing as an AVD-only cost exercise.

### H6. Troubleshooting and operational scenarios [NEW, unchanged from revision 1 section 21]

Two incident scenarios via Project 15's 10-layer method.

### H7. Architecture decision records [NEW, expanded from revision 1 section 22]

At minimum, five ADRs, not three - this revision adds two the new enterprise-layer scope requires:

1. Hub-and-spoke, not Virtual WAN (C1) - applying Chapter 12's existing decision trigger, not a fresh derivation
2. Bangalore served via internet-path to the West Europe AVD Landing Zone, not a dedicated platform region (E3)
3. Active-passive cross-region DR, not active-active (H2)
4. Standard host-pool management, not Session Host Configuration (F8)
5. **[NEW]** Separate platform and AVD Landing Zone subscriptions, not one shared subscription for the whole estate (B2/E1) - the ADR that makes the enterprise/AVD Landing Zone distinction itself a documented, defensible decision, not just a diagram convention

### H8. Senior Architect interview scenarios [NEW, expanded from revision 1 section 23]

At minimum seven questions now, adding two for the expanded scope: defending the management group and subscription structure against "why not just one subscription for everything," and explaining precisely where the enterprise landing zone ends and the AVD landing zone begins to an interviewer probing whether the candidate actually understands the distinction or is just using both terms.

---

## 1. What Chapter 1 through Chapter 25 already decided about Northwind, verified directly

*(Unchanged from revision 1 - preserved here for reference since every part above cross-references it.)*

### 1.1 The baseline profile [EXISTING, Chapter 1]

| Attribute | Value |
|---|---|
| Users | 3,200 |
| Sites | Chicago (HQ), Amsterdam (EMEA hub), Bangalore (engineering) |
| Identity | On-premises Active Directory, fifteen years of GPO, synced to Microsoft Entra ID |
| Connectivity | ExpressRoute at Chicago and Amsterdam; internet-only at Bangalore |
| Applications | SAP, a licensed CAD suite, ~40 line-of-business applications |
| Compliance | Financial data in scope for SOX controls |
| Availability target | 99.5% for the desktop service |
| Budget | Must not exceed the current on-premises VDI run cost |

| Persona | Users | Profile |
|---|---|---|
| Task workers | 1,400 | Small application set, high density, shift patterns |
| Knowledge workers | 1,100 | Office apps, Teams, browser-heavy |
| Finance / regulated | 250 | Restricted data, tighter controls, audit requirements |
| Engineers (CAD) | 180 | GPU workloads, large files |
| Developers | 170 | High CPU and memory, local admin needed |
| Executives | 100 | Low volume, high visibility, mobile |

### 1.2 Identity architecture [EXISTING, Chapter 7]

Entra hybrid join. Two domain controllers in East US 2, two in West Europe, synced with the on-premises forest. Session hosts domain-joined and registered in Entra ID. GPO/Intune ownership documented up front. Validation: measure logon time per region separately, then deliberately break the ExpressRoute path to confirm regional DCs keep local logons working without it.

### 1.3 Regional structure [EXISTING, Chapters 3, 7, 12, 15]

East US 2 (Chicago) and West Europe (Amsterdam). Naming: `<type>-<workload>-<env>-<region-short>-<instance>`, environment code `prd`.

### 1.4 Host pool design [EXISTING, Chapter 15, cross-checked against Chapters 3, 5, 16, 17]

| Host pool | Type | Users | Reason |
|---|---|---|---|
| `hp-task-prd-<region>-01` | Pooled | 1,400 | Density is the business case |
| `hp-know-prd-<region>-01` | Pooled | 1,200 (1,100 knowledge + 100 executives) | Executives don't justify their own capacity floor |
| `hp-fin-prd-<region>-01` | Pooled | 250 | Isolation is a compliance requirement |
| `hp-cad-prd-<region>-01` | Personal | 180 | GPU, large local working sets |
| `hp-dev-prd-<region>-01` | Personal | 170 | Local admin needed |

### 1.5 Operating system [EXISTING, Chapter 5]

Windows 11 multi-session default; Windows Server only as a scoped, documented exception.

### 1.6 Profile storage sizing [EXISTING, Chapter 20]

Task worker pool: 32,000 peak IOPS at the sign-in burst, versus 28 TB capacity - sized from the burst, not capacity.

### 1.7 Address planning [EXISTING, Chapter 12]

Task worker subnet: 1,600 planned maximum, 320 hosts doubled for rolling updates, `/23` not `/24`.

---

## 2. Where existing chapter content and later lab/project work disagree, reconciled

### 2.1 Session Host Configuration [RECONCILED]

Chapter 16 assumed Northwind's three pooled host pools move to Session Host Configuration. Labs 11-20 later verified, rigorously, that no stable Terraform resource exists, the PowerShell cmdlets are preview, and the ARM API has never shipped non-preview - producing [an ADR](adr-shc-vs-standard-host-pools.md). This plan's Terraform (Part F8) uses standard host-pool management throughout; SHC is documented only as an optional future upgrade path, exactly as Lab 14 established the pattern.

### 2.2 Terminology collision with the lab environment [NEW, disclosure only]

The capstone's two regions (East US 2, West Europe) share one region name with the Labs 11-20 lab environment (East US 2, Central US) by coincidence. The capstone is its own environment, own domain, own Terraform state, with no dependency on the lab environment - the same independence every one of the 15 projects already maintained.

---

## 3. Executive business scenario and requirements

Covered in full in Part A. Not duplicated here.

---

## 25. What has been structurally validated, and what has not

**Validated in this planning pass:** every fact in section 1 checked directly against the actual chapter text. The Chapter 12 hub-and-spoke/Virtual WAN citation (Part C1) checked directly against the chapter's own quoted Microsoft guidance. The management group hierarchy in Part B1 is built on Microsoft's published Cloud Adoption Framework enterprise-scale structure, not invented. Cross-references in this document checked against real file paths.

**Not validated, and not claimed to be:** no Terraform has been written for any of the four layers (platform, AVD landing zone, AVD platform, or their combined operations tooling). No diagram has been built. No live Azure deployment of any kind, at any layer. Every decision in this plan is a design decision pending implementation, not an implemented and tested fact, until the corresponding phase below actually builds it.

---

## 26. Build phases, revised for the four-layer architecture

1. **Phase 1 - Enterprise Landing Zone and Governance (Parts B, D):** management group hierarchy, platform subscriptions, enterprise Azure Policy, RBAC/PIM, security baseline, platform monitoring, FinOps baseline. Delivered together, per D1's reasoning.
2. **Phase 2 - Identity and Connectivity Foundation (Part C):** hub-and-spoke networks in both regions, ExpressRoute termination, domain controllers, AD Sites and Services, Conditional Access baseline. Includes ADR 1 (hub-and-spoke decision).
3. **Phase 3 - AVD Landing Zone (Part E):** network spokes, AVD-specific policy and RBAC, the Bangalore connectivity decision and its Conditional Access policy. Includes ADR 2 and ADR 5.
4. **Phase 4 - AVD Platform, host pools and delivery (Part F, sections F1-F6):** all five pools x two regions, images, FSLogix, application delivery, Intune/GPO split.
5. **Phase 5 - Security and compliance (Part F7):** SOX controls for the finance persona, evidence-query pattern.
6. **Phase 6 - Operations (Part H1, H4, H5):** monitoring, autoscaling, cost model, rolling up into the enterprise FinOps view.
7. **Phase 7 - Resilience (Part H2-H3):** HA/DR, backup boundaries. Includes ADR 3.
8. **Phase 8 - Validation and close (Part H6-H8):** troubleshooting scenarios, all 5 ADRs finalized, interview questions, full diagram set (revision 1's seven diagrams plus an eighth: the management group/subscription hierarchy for Part B), closing report.

Each phase gets full Terraform (in its correct layer per G1), diagrams (render-inspect-fix), validation and troubleshooting sections, and is checked against this plan before moving to the next.

---

## 27. Sequencing confirmation

No capstone file, Terraform module, or diagram is created until this revised plan is reviewed and approved. Once approved, Phase 1 begins, and each subsequent phase proceeds without requiring routine re-approval, pausing only for the same four conditions used throughout Labs 11-20: a genuine conflict with current official Microsoft documentation, a missing dependency preventing correct implementation, a decision that would materially change this approved plan, or a limitation that would make a validation claim inaccurate.
