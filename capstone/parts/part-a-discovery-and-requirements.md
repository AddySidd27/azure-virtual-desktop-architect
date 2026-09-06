# Northwind Capstone, Part A: Enterprise Discovery and Requirements

> **Part of:** [Northwind Capstone Master Plan](../../appendices/capstone-northwind-master-plan.md)
> **Sequence:** Part A of A-H. This document precedes and directly informs Part B (Azure Enterprise Landing Zone) - the landing zone is built as a documented consequence of what follows, not as a starting assumption.
> **Customer:** Northwind Global Manufacturing, established in [Chapter 1, section 4](../../chapters/ch01-what-avd-actually-is.md#4-meet-the-capstone-customer-northwind-global-manufacturing)
> **Technical baseline:** August 2026

---

## Why this document exists, and what it does not do

This is the discovery and requirements phase of a real architecture engagement, written the way a senior architect would actually produce it: business context first, requirements and constraints stated in the customer's terms, assumptions and risks named explicitly where the source material is silent, and only then a short set of architecture principles that everything from Part B onward is checked against.

**What this document does not do.** It does not design the landing zone, choose a network topology, or decide how many host pools Northwind needs. Those are Parts B, C, and F. Producing them here would collapse the sequence the customer specifically asked for - discovery driving design, not design dressed up as discovery.

---

## 1. Engagement overview

Northwind Global Manufacturing is replacing its current on-premises VDI platform with Azure Virtual Desktop, at a scale (3,200 users, six distinct personas, three sites, one in-scope compliance regime) that makes this an enterprise platform program, not a single-workload deployment. The scope of this engagement, agreed at discovery, is the full stack from Azure landing zone through to day-2 AVD operations - not because a smaller scope wouldn't work, but because Northwind has no existing enterprise-scale landing zone to build on (section 6), and building AVD without one would mean building governance, identity, and connectivity decisions inside the workload itself, exactly the anti-pattern Chapter 12 already warns against for this book's readers.

---

## 2. Business context and drivers

**Why now.** The current on-premises VDI platform's underlying hardware is approaching end of vendor support - **[ASSUMPTION]**, since Chapter 1 states only "the current on-premises VDI run cost" as a budget reference point and does not name a trigger event. A hardware end-of-life event is the most common real-world reason a project of exactly this shape and urgency gets board approval, and this plan states it as an assumption rather than presenting it as a fact Chapter 1 never established.

**What must not happen as a side effect of this project.** Fifteen years of Group Policy (Chapter 7) must keep working. SAP and the CAD suite must not require re-certification against a new identity model. The finance persona's SOX-relevant controls must not weaken during the transition - a compliance regression discovered during an audit, caused by a desktop platform migration, is a specific and real failure mode this engagement is designed to avoid, not a generic risk statement.

---

## 3. Business requirements

Restated from [Chapter 1](../../chapters/ch01-what-avd-actually-is.md#4-meet-the-capstone-customer-northwind-global-manufacturing) **[EXISTING]**, in the form a requirements register actually needs - testable, not descriptive:

| ID | Requirement | Source | Testable as |
|---|---|---|---|
| BR-01 | Support 3,200 users across six personas without a compromise design that treats them as one population | Chapter 1 | Distinct sizing and isolation decisions traceable to each persona (Part F) |
| BR-02 | Serve three physical sites: Chicago, Amsterdam, Bangalore | Chapter 1 | A stated connectivity path for each site (Part C, Part E) |
| BR-03 | Financial data remains within SOX control scope throughout and after migration | Chapter 1 | A named control set and an evidence-retrieval capability (Part F7) |
| BR-04 | Desktop service availability of 99.5% | Chapter 1 | A quantified downtime budget and a design that can be checked against it (section 8) |
| BR-05 | Steady-state Azure cost does not exceed the current on-premises VDI run cost | Chapter 1 | A traceable cost model with the baseline stated (Part H5) |

---

## 4. Technical requirements

| ID | Requirement | Type |
|---|---|---|
| TR-01 | Preserve the existing on-premises Active Directory forest and its Group Policy; do not require a forest redesign | [EXISTING], Chapter 7 |
| TR-02 | Hybrid identity: on-premises AD synced to Microsoft Entra ID, not a cloud-only redesign | [EXISTING], Chapter 7 |
| TR-03 | ExpressRoute connectivity honoured at Chicago and Amsterdam; no assumption that a third ExpressRoute circuit will be procured for Bangalore | [EXISTING], Chapter 1 |
| TR-04 | A governance model where naming, tagging, and policy are enforced as code, not documented as convention | [NEW] - this book's standing requirement since Project 03, applied here |
| TR-05 | Every architecture decision distinguishes what is platform-owned from what is workload-owned | [NEW] - the specific instruction shaping this entire capstone's structure |

---

## 5. Persona workload profiles

Chapter 1 establishes headcount and a one-line profile per persona. This section extends that into the level of detail Part F's host pool and sizing decisions will actually need, without yet making those decisions - stating requirements, not solutions.

| Persona | Users | Primary applications | Session pattern | Data sensitivity |
|---|---|---|---|---|
| Task workers | 1,400 | A small, fixed application set (order entry, scheduling, a warehouse system) | Shift-based, high concurrency during shift changes | Standard |
| Knowledge workers | 1,100 | Office, Teams, browser, SAP (light use) | Standard business hours, browser and collaboration heavy | Standard |
| Finance / regulated | 250 | SAP (finance modules), reporting tools | Standard business hours | **SOX-scoped** |
| Engineers (CAD) | 180 | The licensed CAD suite, large file handling | Business hours, sustained high resource use during design work | Standard, large working sets |
| Developers | 170 | Development tooling, local admin required | Variable, often outside standard hours | Standard, elevated local privilege |
| Executives | 100 | Office, Teams, mobile access | Low volume, high visibility, frequently mobile | Standard, high visibility if disrupted |

**What is deliberately not decided here.** Host pool count, personal-versus-pooled assignment, and VM sizing are Part F decisions, made once the platform and landing zone underneath them exist. Listing session patterns and data sensitivity now is what lets Part F's decisions be traceable back to a stated requirement rather than an assumption made at design time with no discovery behind it.

---

## 6. Current-state assessment

**[ASSUMPTION, stated as such, not as fact.]** Chapter 1 does not describe Northwind's existing Azure footprint. This engagement assumes:

- Northwind has a Microsoft Entra ID tenant already, populated via the existing AD sync (a precondition Chapter 7's hybrid identity design already requires to exist)
- Northwind has **no enterprise-scale landing zone**: no management group hierarchy beyond the tenant default, no platform subscriptions, no centrally enforced Azure Policy
- Northwind's current on-premises VDI platform is unspecified by vendor (section 2), and no attempt is made in this engagement to reverse-engineer or migrate its specific configuration - this is a platform replacement, not a lift-and-shift

**Why this specific assumption matters more than it might appear to.** If Northwind already had a landing zone, Part B would be an integration exercise: fit AVD into what exists. Assuming no landing zone exists is what makes Part B genuine architectural work, and it is stated here, explicitly, as a scope decision this engagement is making - not a fact discovered from Chapter 1, which simply does not say either way.

---

## 7. Constraints

| ID | Constraint | Source |
|---|---|---|
| C-01 | Two Azure regions only at the platform level (East US 2, West Europe) unless a documented exception is approved | [EXISTING], Chapters 3/7/12/15 |
| C-02 | No new ExpressRoute circuit for Bangalore | [EXISTING], Chapter 1 |
| C-03 | Steady-state cost ceiling equal to the current on-premises run cost | [EXISTING], Chapter 1 |
| C-04 | Fifteen years of Group Policy must continue to function; no forest redesign | [EXISTING], Chapter 7 |
| C-05 | This capstone's Terraform and environment are fully independent of the Labs 1-20 lab environment, despite a coincidental regional-name overlap | [NEW], disclosure |

---

## 8. Availability requirement, quantified

**[NEW derivation from an EXISTING target.]** Chapter 1 states 99.5% availability as the target. Stated as a number an architecture can actually be checked against:

```text
8,760 hours per year
x 0.5% permitted unavailability
= 43.8 hours per year of permitted downtime, planned or unplanned combined
```

This is a tight but not extreme target - roughly 3.65 hours per month. It rules out an architecture with no regional resilience at all (a single unplanned regional incident lasting several hours could consume a meaningful share of the annual budget in one event) without requiring the near-zero-RTO cost of a full active-active design for both regions. This number is the actual test Part H's HA/DR design (informed by Project 14's business-impact-analysis method) is built against - not a target chosen because it sounds appropriately serious, but the number Chapter 1's stated commitment actually implies.

---

## 9. RTO/RPO requirement, stated but not yet derived

**[NEW, requirement only - derivation is Part H's job, not this document's.]** Northwind requires a stated, evidenced RTO and RPO for the AVD service, derived from a genuine business-impact analysis (following [Project 14](../../scenarios/project-14-disaster-recovery.md)'s method) rather than an assumed number. This document states the requirement to have one; Part H produces it, once the platform and workload architecture exist to analyse.

---

## 10. Capacity planning inputs

| Input | Value | Type |
|---|---|---|
| Current headcount, by persona | Section 5's table | [EXISTING], Chapter 1 |
| Annual headcount growth assumption | 10% | [ASSUMPTION] - no figure given in Chapter 1; a conservative, commonly-used manufacturing-sector planning figure, stated as an assumption a real engagement would confirm with Northwind's HR/finance function before finalizing subnet and licensing sizing |
| Existing worked sizing examples | Task worker subnet (`/23`, Chapter 12), task worker profile storage (32,000 peak IOPS, Chapter 20) | [EXISTING] |
| Remaining four personas' sizing | Not yet worked in any existing chapter | Genuine gap, addressed in Part F using the same method Chapters 12 and 20 already demonstrate |

---

## 11. Regional strategy requirement

**[EXISTING requirement, NEW statement of what it requires from later parts.]** Two Azure regions are fixed (East US 2, West Europe). This document's requirement on Part C and Part E: state, with reasoning, how each of the three physical sites connects to this two-region platform - Chicago and Amsterdam have an obvious answer (their own region, via ExpressRoute); Bangalore does not, and is not resolved here. Resolving it before Part E has actually defined the AVD Landing Zone's network spokes would be designing ahead of the discovery this document is responsible for, not completing it.

---

## 12. Compliance requirements: SOX, made concrete

**[NEW - Chapter 1 names SOX scope; this section states what that actually requires of an IT platform, not just that it applies.]** For a desktop platform carrying financial data, SOX's IT general controls translate into requirements this book's existing security work can satisfy, but only if stated explicitly:

| SOX IT general control area | What it requires of this platform |
|---|---|
| Access controls | Named, auditable role assignments for anyone who can reach financial systems via AVD; no shared or generic accounts |
| Segregation of duties | The team that can change the finance persona's host pool configuration should not be the same team that can approve financial transactions inside SAP - an organisational control this platform must not undermine by over-broad AVD admin access |
| Change management | Every change to the finance persona's image, policy, or network path is traceable - directly satisfied by this book's Terraform-and-Git discipline, if applied without exception to the finance pool specifically |
| Audit trail | Evidence of who accessed financial systems, from where, and when, retrievable on request within a defined timeframe - the exact capability [Project 11](../../scenarios/project-11-highly-secure-regulated.md) already built for a different regulatory regime |

**What this section does not claim.** It does not claim AVD alone makes Northwind SOX-compliant - the same discipline this book has held since Project 11: AVD is one control surface among several (application-level controls inside SAP, physical security, staff training), and this document scopes its compliance commitment to what the desktop platform specifically controls.

---

## 13. Risk register

| ID | Risk | Category | Mitigation approach |
|---|---|---|---|
| R-01 | Building a full enterprise landing zone is materially larger scope than an AVD-only project and could expand past what this capstone should cover | Delivery | Part B is scoped to exactly what the AVD workload needs from a platform - not a speculative landing zone sized for workloads Northwind has not asked for |
| R-02 | Chapter 16's Session-Host-Configuration-based design and the Labs 11-20 ADR could be left unreconciled if not stated explicitly at the point AVD platform decisions are made | Consistency | Already reconciled in the master plan section 2.1; restated at the point of use in Part F |
| R-03 | The cost ceiling constraint (BR-05) could be treated as a slogan rather than a real, traceable design driver | Rigor | Part H's FinOps section requires a stated baseline cost figure and named trade-offs, not a general cost-consciousness gesture |
| R-04 | Bangalore's connectivity decision, if made too early, could be designed against an assumed platform shape that Part B/C have not yet actually built | Sequencing | Resolved explicitly in Part E, after Parts B and C exist, not before |
| R-05 | An assumed 10% annual headcount growth figure (section 10) could understate real growth if manufacturing sector conditions differ from the planning assumption | Planning | Stated explicitly as an assumption requiring confirmation with Northwind's own planning function before final capacity sizing is committed to in Part F |

---

## 14. Stakeholder requirements

| Stakeholder | Requirement | Where addressed |
|---|---|---|
| CFO | Cost at or below the current on-premises baseline; SOX-auditable finance persona | BR-05, section 12, Part H5 |
| CISO | Hybrid identity preserved; Conditional Access and PIM enforced tenant-wide | TR-01, TR-02, Part B7, Part C |
| Site leads (Chicago, Amsterdam, Bangalore) | Consistent experience regardless of site; Bangalore not treated as second-class | BR-02, section 11, Part E |
| Platform/infrastructure team | A landing zone built to be extended to future workloads, not shaped only around AVD | Section 6, Part B |
| AVD operations team | The same monitoring, autoscaling, and DR discipline this book has already proven at scale | Part H |

---

## 15. Architecture principles

The output of discovery is not only a requirements register - it is a small number of principles specific enough to actually constrain a decision, not broad enough to justify anything. These six govern every decision from Part B onward; where a later part deviates from one, that deviation is itself a decision requiring its own stated reason, not a silent exception.

1. **Platform before workload.** No AVD-specific resource is built before the platform capability it depends on exists and is validated. (Directly, this is why Part B precedes Part E.)
2. **Every exception is owned and dated.** Following [Project 03](../../scenarios/project-03-global-enterprise-governance.md)'s discipline: a deviation from a stated policy or principle has a named accountable owner and either an end date or an annual review date, never neither.
3. **State the number, not the adjective.** "Highly available," "cost-effective," and "secure" are not requirements. 99.5% is. The cost ceiling figure Part H states is. A control that can name what it evidences is. This principle is why section 8 does the arithmetic rather than repeating Chapter 1's adjective.
4. **Reconcile, don't silently override.** Where later, more rigorously validated work (the Labs 11-20 ADR) conflicts with earlier chapter content (Chapter 16), the conflict is named and resolved in writing, never quietly built differently with no note explaining why.
5. **Two regions is a stated scope, not an oversight.** Bangalore's absence of a dedicated region is a decision, made against a cost ceiling, not a gap this engagement failed to notice.
6. **No component without a stated reason.** Matching the customer's own instruction for this engagement directly: every subscription, every policy, every network hop is traceable to a requirement or a principle above it, not added because a reference architecture includes it by default.

---

## 16. ADR-CAP-00: Build a dedicated Enterprise Landing Zone, not an isolated AVD workload subscription

**Status:** Accepted
**Context:** Section 6 establishes, as a stated assumption, that Northwind has no existing enterprise-scale landing zone. The alternative to building one is deploying AVD into a single subscription with its own bespoke governance, identity, and network design, isolated from the rest of Northwind's Azure estate.

**Decision:** Build a dedicated Enterprise Azure Landing Zone (Part B) as the foundation this AVD program lands into, following Microsoft's Cloud Adoption Framework enterprise-scale structure, rather than a self-contained AVD subscription with its own one-off governance.

**Reasoning.**
- **Platform reuse.** Northwind's next workload after AVD - and there will be one, at this company's scale - should not need to rebuild identity, connectivity, and governance from scratch. A landing zone amortizes that cost across every future workload, not just this one.
- **Consistent with principle 1.** Platform before workload is not just a sequencing preference; it is the reason a landing zone, not a workload-shaped subscription, is the right foundation.
- **Consistent with this book's own governance pattern.** [Project 03](../../scenarios/project-03-global-enterprise-governance.md) already demonstrated, for a different customer, that subscription-level separation between platform and workload is what actually protects budget and blast radius - a lesson this capstone applies at the point Northwind's own landing zone is designed, not re-derived from nothing.

**Consequences.** Real, larger scope than an AVD-only deployment (risk R-01, accepted and scoped deliberately narrow in Part B). A longer Phase 1 than a workload-only project would need. In exchange: every later part of this capstone can state platform-versus-workload ownership precisely, because the platform actually exists as its own thing to own something.

**Revisit if:** Northwind's actual current-state assessment (once performed for real, beyond this engagement's stated assumption in section 6) finds an existing landing zone already in place - in which case Part B becomes an integration exercise against it, not a from-scratch build.

---

## 17. Traceability: this document against the existing book

| This document's section | Existing chapter/lab/project it draws from | Type |
|---|---|---|
| Section 3 (business requirements) | Chapter 1 | [EXISTING] |
| Section 5 (persona profiles) | Chapter 1, extended | [EXISTING] + [NEW] |
| Section 8 (availability quantified) | Chapter 1's target, new arithmetic | [NEW] |
| Section 9 (RTO/RPO requirement) | Project 14's method, referenced not yet applied | [EXISTING method, NEW application pending] |
| Section 12 (SOX made concrete) | Project 11's control catalogue, reframed | [EXISTING] + [NEW] |
| Section 15 (architecture principles) | Project 03's exception discipline; this book's general evidence-first standard | [EXISTING pattern, NEW as a named principle set] |
| Section 16 (ADR-CAP-00) | Project 03's subscription-separation lesson, applied at discovery stage | [NEW decision, EXISTING supporting evidence] |

---

## 18. What Part A validates, and what remains for Part B

**Validated here:** every existing-chapter fact restated in this document checked directly against the source chapter text (cross-referenced against the master plan's own verification pass). The availability arithmetic in section 8 is a direct calculation, checked by hand. Every cross-reference link in this document resolves to a real file.

**Not yet done, and correctly so at this stage:** no landing zone has been designed. No management group, subscription, or Azure Policy exists yet, not even on paper beyond the master plan's outline. Part B is where section 16's decision is actually built, not just decided.

---

## What comes next

[Part B - Azure Enterprise Landing Zone](../../appendices/capstone-northwind-master-plan.md#part-b---azure-enterprise-landing-zone) is built as the direct, documented consequence of this discovery: the management group hierarchy, subscription strategy, and governance baseline that ADR-CAP-00 commits to and principle 1 requires exist before any AVD-specific resource is created.
