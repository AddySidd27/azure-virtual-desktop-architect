# Northwind Global Manufacturing: Enterprise Azure Virtual Desktop Program

**A Senior Cloud Architect / AVD Architect portfolio case study.** Northwind Global Manufacturing is fictional. The case study shows a complete architecture process: discovery first, then the enterprise platform, the AVD landing zone, the AVD platform, and the operational design. Each major decision links back to a stated requirement or risk.

**Current status:** Documents, diagrams, ADRs, and Terraform reference modules are present for Parts A-H. The design package is complete. The full Northwind environment has not been deployed or production validated. See [Validation Status](../VALIDATION-STATUS.md).

---

## How to read this

Start here, then go as deep as you want. Nothing below requires you to have read anything else first, and nothing below hides how much is actually built versus planned.

```text
This page (5 minutes)
  -> The Master Plan (the full architecture, decisions and reasoning)
    -> Part A (the discovery work actually completed)
      -> ADRs (why each major decision was made, and what was rejected)
        -> Terraform, diagrams, runbooks (as each part is built)
          -> Validation evidence (what's been checked, and how)
```

---

## 1. Executive summary: architecture at a glance

| | |
|---|---|
| **Customer** | Northwind Global Manufacturing - 3,200 users, three sites, one enterprise |
| **Problem** | Replace an aging on-premises VDI platform without breaking fifteen years of Group Policy, without weakening SOX controls, and without exceeding current run cost |
| **Scope** | Not "deploy AVD." The full stack: Azure Enterprise Landing Zone -> AVD Landing Zone -> AVD Platform -> Operations |
| **Regions** | East US 2 (Chicago), West Europe (Amsterdam) - a deliberate two-region decision, not a default |
| **The third site** | Bangalore has no ExpressRoute and gets no dedicated Azure region either - served over the internet through Conditional Access, a cost-driven decision defended in the ADRs, not an oversight |
| **Personas** | Six, each sized and isolated on its own stated reason - task workers, knowledge workers, finance (SOX-scoped), CAD engineers, developers, executives |
| **Governance model** | Platform and workload strictly separated - enforced by the management group hierarchy, the subscription boundaries, and the Terraform directory structure itself, not just by a diagram |
| **Status** | Design package complete; full environment not deployed or production validated |

---

## 2. The business challenge

Northwind's current on-premises VDI platform is reaching the end of its useful life, and the board has approved its replacement under one hard constraint: the new platform's steady-state cost cannot exceed what the current one costs to run. That constraint shapes almost everything that follows - it's the reason Bangalore doesn't get its own Azure region, and it's the test every cost-adding decision in this engagement has to pass.

Underneath that headline constraint sit three things that make this a genuinely hard problem, not a routine one:

- **Fifteen years of Group Policy** that cannot be redesigned as a side effect of a desktop migration, because SAP and a CAD suite both depend on it
- **SOX-scoped financial data**, for a 250-person finance population that cannot be treated the same way as the other 2,950 users
- **A 99.5% availability commitment** that, done properly, is not an adjective - it's 43.8 hours of permitted downtime a year, a number small enough to rule out a design with no regional resilience and tight enough that it has to actually be tested against, not asserted

Full detail: [Part A, sections 1-8](parts/part-a-discovery-and-requirements.md).

---

## 3. What I was asked to design

Not "an AVD environment." An architecture that demonstrates the same journey a real enterprise engagement of this size actually takes, end to end:

```text
Enterprise Discovery and Requirements
  -> Azure Enterprise Landing Zone
    -> Identity and Connectivity Foundation
      -> Governance and Security Foundation
        -> Dedicated AVD Landing Zone
          -> AVD Platform Architecture
            -> Implementation with Terraform
              -> Operations, DR, Monitoring and FinOps
```

The specific requirement that shapes this whole repository's structure: **the Enterprise Landing Zone and the AVD Landing Zone are not the same thing**, and the architecture has to make that distinction visible in the actual Terraform layout, not just describe it in prose. Section 6 shows exactly how.

Full detail: [Capstone Master Plan](../appendices/capstone-northwind-master-plan.md).

---

## 4. Key architecture decisions

Six decisions, each with a name, a status, and a link to the full reasoning. This is the part of a portfolio a reviewer usually has to ask about in an interview - here, it's already written down.

| Decision | Status | Where the full reasoning lives |
|---|---|---|
| **ADR-CAP-00:** Build a dedicated Enterprise Landing Zone, not a self-contained AVD subscription | **Decided and built** | [Part A, section 16](parts/part-a-discovery-and-requirements.md#16-adr-cap-00-build-a-dedicated-enterprise-landing-zone-not-an-isolated-avd-workload-subscription) |
| Hub-and-spoke, not Virtual WAN, for the platform network | Decided in the Master Plan, pending Part C build | [Master Plan, Part C1](../appendices/capstone-northwind-master-plan.md#part-c---identity-and-connectivity-foundation) |
| Bangalore served via internet path and Conditional Access, not a third Azure region | Decided in the Master Plan, pending Part E build | [Master Plan, Part E3](../appendices/capstone-northwind-master-plan.md#part-e---dedicated-avd-landing-zone) |
| Standard host-pool management, not Session Host Configuration | Decided, reconciling a real conflict with earlier book content | [Master Plan, section 2.1](../appendices/capstone-northwind-master-plan.md#21-session-host-configuration-reconciled) |
| Active-passive cross-region DR, not active-active | Decided in the Master Plan, pending Part H build | [Master Plan, Part H2](../appendices/capstone-northwind-master-plan.md#part-h---operations-dr-monitoring-and-finops) |
| Separate platform and AVD Landing Zone subscriptions, enforced by Terraform directory structure | Decided in the Master Plan, pending Part B/G build | [Master Plan, Part G1](../appendices/capstone-northwind-master-plan.md#part-g---implementation-with-terraform) |

Every one of these is stated with the alternative that was rejected and why - not just the choice that was made. That's deliberate: a decision without a rejected alternative next to it isn't a decision, it's a default.

---

## 5. Architecture evolution: how the thinking actually changed

This section exists because a hiring manager reading a finished architecture can't see the revisions that got it there - and the revisions are where the actual architectural judgment shows up, not the final diagram.

**An early version of the plan assumed Northwind already had an Azure landing zone** and covered only the AVD workload. The scope was later expanded to include the enterprise landing zone so the case study could show the full dependency chain.

The revised plan has eight parts, with the enterprise landing zone in Part B. [ADR-CAP-00](parts/part-a-discovery-and-requirements.md#16-adr-cap-00-build-a-dedicated-enterprise-landing-zone-not-an-isolated-avd-workload-subscription) records this scope decision.

**A second, smaller but equally real correction:** Chapter 16 of the book this capstone sits inside had already designed three of Northwind's host pools around Session Host Configuration. Later, more rigorous work (Labs 11-20) found that SHC has no stable Terraform resource, a preview-only PowerShell module, and an ARM API that's never shipped non-preview. Rather than silently building Northwind's pools differently from what an earlier chapter said, the conflict is named and resolved in writing - [Master Plan section 2.1](../appendices/capstone-northwind-master-plan.md#21-session-host-configuration-reconciled). This is the same discipline as the landing zone correction, applied at a smaller scale: when new evidence conflicts with an earlier decision, the conflict gets written down, not buried.

**Design-package progress:**

| Part | Title | Status |
|---|---|---|
| A | Enterprise Discovery and Requirements | **Complete** |
| B | [Azure Enterprise Landing Zone](parts/part-b-enterprise-landing-zone.md) | **Complete** |
| C | [Identity and Connectivity Foundation](parts/part-c-identity-connectivity-foundation.md) | **Complete** |
| D | [Governance and Security Foundation](parts/part-d-governance-security-foundation.md) | **Complete** |
| E | [Dedicated AVD Landing Zone](parts/part-e-avd-landing-zone.md) | **Complete** |
| F | [AVD Platform Architecture](parts/part-f-avd-platform-architecture.md) | **Complete** |
| G | [Implementation with Terraform](parts/part-g-terraform-implementation.md) | **Complete** |
| H | [Operations, DR, Monitoring and FinOps](parts/part-h-operations-dr-monitoring-finops.md) | **Complete as a design** - active-passive DR remains an implementation gap |

---

## 6. Final enterprise architecture

**Status:** The target design, diagrams, and Terraform reference modules are present. The full environment has not been deployed.

The design has this structure:

```text
Tenant Root
  Northwind (Intermediate Root)
    Platform                              <- Enterprise Landing Zone (Part B)
      Identity        - domain controllers, Entra Connect
      Management      - tenant-wide Log Analytics, Sentinel
      Connectivity     - hub VNets (both regions), ExpressRoute, Firewall
    Landing Zones
      Corp
        sub-northwind-avd-prod             <- AVD Landing Zone (Part E)
          5 host pools x East US 2          <- AVD Platform (Part F)
          5 host pools x West Europe
          Bangalore -> internet path -> West Europe, via Conditional Access
        sub-northwind-avd-nonprod
```

The Terraform directory structure this maps to, designed in [Master Plan Part G1](../appendices/capstone-northwind-master-plan.md#part-g---implementation-with-terraform), is deliberately three-tiered - `platform/`, `avd-landing-zone/`, `avd-platform/` - specifically so the separation this whole engagement is built around is enforced by where the code lives, not only described in a document.

See the [landing zone architecture diagram](../diagrams/architecture/capstone-landing-zone-architecture.svg) and its editable [draw.io source](../diagrams/architecture/capstone-landing-zone-architecture.drawio).

---

## 7. Technology and design trade-offs

Every trade-off below is a real either/or that was actually weighed, not a technology list.

| Decision point | Option taken | Option rejected | Why |
|---|---|---|---|
| Network topology | Hub-and-spoke | Virtual WAN | Microsoft's own stated trigger for Virtual WAN is more than two regions with global transit needs. Northwind has two. The trigger isn't met - see [Chapter 12](../chapters/ch12-enterprise-topologies-ip-planning.md), cited directly in the Master Plan, not re-derived |
| Bangalore connectivity | Internet path + Conditional Access into West Europe | A dedicated third Azure region | A third region means a third hub, a third identity footprint, and real ongoing cost - directly against the cost ceiling. The internet-path option costs nothing at the platform layer |
| Host pool management | Standard management | Session Host Configuration | No stable Terraform resource exists for SHC; the PowerShell path is preview; the ARM API has never shipped non-preview. A required capstone dependency can't sit on three simultaneously-unstable tooling paths |
| Cross-region resilience | Active-passive | Active-active | Active-active costs real money every month, permanently, for a benefit that only pays off during an outage. Against a hard cost ceiling and a 99.5% (not five-nines) target, that trade doesn't clear |
| Subscription strategy | Separate platform and workload subscriptions | One shared subscription | Subscriptions are the actual boundary for budget and blast radius in Azure - a policy mistake in the AVD workload should not be able to reach identity or connectivity |

---

## 8. Implementation approach

**Status:** Terraform reference modules are present. They require validation against a real Azure environment before use.

The Terraform strategy (full detail: [Master Plan Part G](../appendices/capstone-northwind-master-plan.md#part-g---implementation-with-terraform)) uses one remote state backend per architectural layer - platform, AVD Landing Zone, AVD platform - rather than one shared state file, because these three layers change at different rates and are owned by different concerns. This follows the same `terraform_remote_state` cross-referencing pattern already proven across [Labs 11-20](../appendices/labs-11-20-plan.md) in this book, applied here at enterprise scale rather than lab scale.

Each module must state what has and has not been validated. A formatting or provider validation check is not evidence of a successful Azure deployment.

---

## 9. Operational model

**Status:** The operational design and reference modules are present. Restore, failover, and production operating procedures are not validated by this case study.

The intended operational shape: two regional Log Analytics workspaces (not one shared workspace, for the same blast-radius reasoning as the subscription split), an active-passive DR runbook with a real, timed failover exercise once built (matching the discipline already proven in [Lab 19](../labs/lab-19-disaster-recovery-failover.md) and its own post-review correction), Power Management Autoscale tuned per persona's actual shift pattern, and a SOX evidence-query capability for the finance persona built on the exact pattern [Project 11](../scenarios/project-11-highly-secure-regulated.md) already proved out for a different regulatory regime.

---

## 10. Design outcomes and lessons

The design package is complete. The outcomes below describe architecture work, not production results.

**What the process has already demonstrated:** a first-draft architectural assumption (that a landing zone already existed) got corrected in writing, not quietly, once it was clear it didn't match what the engagement actually needed to show. A conflict between an earlier design decision (Chapter 16's SHC-based pools) and later, more rigorous evidence (the Labs 11-20 tooling investigation) got named and reconciled rather than silently overridden. A vague target (99.5% availability) got turned into a specific number (43.8 hours/year) before any design decision was allowed to claim it satisfied the requirement.

**What is still required:** provider validation of every module, a plan against an authorized Azure environment, selected lab deployments, restore and failover exercises, security review, and retained evidence.

---

## Progressive navigation

| Layer | What's there |
|---|---|
| **This page** | The story: problem, scope, decisions, trade-offs, honest status |
| **[Capstone Master Plan](../appendices/capstone-northwind-master-plan.md)** | The complete eight-part architecture, every decision reasoned in full |
| **[Part A](parts/part-a-discovery-and-requirements.md)** | The actual discovery deliverable - requirements, assumptions, risks, principles, ADR-CAP-00 |
| **[Parts B-H](parts/)** | Architecture documents are present for the enterprise platform, AVD landing zone, AVD platform, implementation, and operations |
| **[Terraform](../terraform/capstone-northwind/)** | Reference modules organized into platform, AVD landing zone, and AVD platform layers |
| **[Diagrams](../diagrams/architecture/README.md)** | Editable draw.io sources and SVG viewing copies |
| **ADRs** | [ADR-CAP-00](parts/part-a-discovery-and-requirements.md#16-adr-cap-00-build-a-dedicated-enterprise-landing-zone-not-an-isolated-avd-workload-subscription), [ADR-CAP-01](adr/adr-cap-01-identity-sync-method.md) (Entra Connect Sync, not Cloud Sync), and [ADR-CAP-06](adr/adr-cap-06-finance-fslogix-isolation.md) (finance FSLogix isolation, tiered) now exist; more are named and pending in the Master Plan |
| **Validation evidence** | Stated at the end of each part - see [Part A, section 18](parts/part-a-discovery-and-requirements.md#18-what-part-a-validates-and-what-remains-for-part-b) for the pattern every later part will follow |

---

Back to [the main book](../README.md) | [Northwind introduction](../chapters/ch01-what-avd-actually-is.md#4-meet-the-capstone-customer-northwind-global-manufacturing) | [Full index](../SUMMARY.md)
