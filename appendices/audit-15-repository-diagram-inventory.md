# Audit 15 - Repository-Wide Diagram Inventory and Classification

> **Internal development record.** Not required reading. See [Development history](development-history.md) for a summary.

**Date:** August 2026
**Scope:** Every inline Mermaid, standalone Mermaid, SVG and `.drawio` file in the repository, classified before any replacement work begins.

---

## Method

Every standalone `.mermaid` file was inspected for its declared type (`flowchart`, `sequenceDiagram`) and line count. Diagrams already classified as Tier 1 in [Audit 08](audit-08-repository-diagram-coverage.md) were cross-checked against this new pass rather than re-judged from scratch, since that classification (16 kept as Mermaid, 32 flagged for replacement) has already been verified twice. The 7 lab diagrams added in Phase 2 (Labs 5-10) are classified here for the first time.

**Rule applied:** `sequenceDiagram` type, or a `flowchart` under ~25 lines with no zone/boundary structure, stays Mermaid. A `flowchart` at or above ~25 lines showing zones, boundaries, or physical/network topology is a replacement candidate. This matches the instruction not to convert simple decision trees merely to inflate a count.

---

## Full inventory: 52 standalone Mermaid files, 18 already-complete architecture files

| File | Type | Lines | Classification |
|---|---|---|---|
| ch01-shared-responsibility |, |, | **Already replaced** (Chapter 1, Phase 3) |
| ch02-avd-control-plane | flowchart TB | 54 | **Replace** |
| ch03-avd-object-model | flowchart TB | 50 | Keep (object relationship, not physical topology) |
| ch04-avd-connection-flow | sequenceDiagram | 27 | Keep |
| ch05-session-host-os-decision | flowchart TB | 21 | Keep (decision tree) |
| ch06-client-path-decision | flowchart TB | 18 | Keep (decision tree) |
| ch07-join-model-decision | flowchart TB | 23 | Keep (decision tree) |
| ch08-authentication-sequence | sequenceDiagram | 28 | Keep |
| ch08-identity-architecture | flowchart TB | 54 | **Replace** |
| ch09-conditional-access-app-targeting | flowchart LR | 47 | **Replace** |
| ch10-rbac-permission-planes | flowchart TB | 50 | **Replace** |
| ch11-egress-enforcement-points | flowchart TB | 18 | Keep (decision tree) |
| ch12-topology-decision | flowchart TB | 19 | Keep (decision tree) |
| ch13-avd-egress-architecture | flowchart TB | 59 | **Replace** |
| ch14-rdp-transport-selection | flowchart LR | 36 | **Replace** |
| ch14-teams-media-optimisation | flowchart LR | 39 | **Replace** |
| ch15-broker-host-selection | sequenceDiagram | 21 | Keep |
| ch15-pooled-vs-personal-decision | flowchart TB | 22 | Keep (decision tree) |
| ch16-management-approach-decision | flowchart TB | 21 | Keep (decision tree) |
| ch16-session-host-configuration-objects | flowchart TB | 35 | **Replace** |
| ch17-session-host-placement | flowchart TB | 34 | **Replace** |
| ch18-session-host-registration | flowchart TB | 32 | **Replace** |
| ch19-fslogix-profile-flow | flowchart LR | 46 | **Replace** |
| ch20-azure-files-permission-layers | flowchart TB | 36 | **Replace** |
| ch20-profile-storage-redundancy | flowchart TB | 39 | **Replace** |
| ch22-cloud-cache-flow | flowchart TB | 31 | **Replace** |
| ch23-image-build-pipeline | flowchart LR | 48 | **Replace** |
| ch24-intune-management-planes | flowchart TB | 45 | **Replace** |
| ch24-session-host-enrolment-decision | flowchart TB | 20 | Keep (decision tree) |
| ch25-application-delivery-routes | flowchart LR | 46 | **Replace** |
| lab03-network-topology | flowchart TB | 30 | **Replace** (network design) |
| lab04-identity-topology | flowchart TB | 32 | **Replace** (identity boundaries) |
| lab05-storage-topology | flowchart TB | 25 | **Replace** (storage architecture) |
| lab07-object-model | flowchart LR | 9 | Keep (small object relationship) |
| lab08-session-host-join | flowchart TB | 20 | **Replace** (shows the environment converging, borderline but architecture) |
| lab09-two-delivery-models | flowchart LR | 10 | Keep (small object relationship) |
| lab10-complete-environment | flowchart TB | 30 | **Replace** (complete lab environment, explicitly listed category) |
| project01-harbourview-architecture | flowchart TB | 55 | **Replace** (target-state architecture) |
| project04-dc-dns-placement | flowchart TB | 41 | **Replace** |
| project04-hybrid-estate-as-found | flowchart TB | 46 | **Replace** (current-state) |
| project04-policy-decision-flow | flowchart TB | 29 | Keep (decision tree) |
| project04-target-state | flowchart TB | 45 | **Replace** |
| project05-ad-dependent-as-found | flowchart TB | 43 | **Replace** (current-state) |
| project05-dependency-disposition | flowchart TB | 23 | Keep (decision tree) |
| project05-entra-signin-sequence | sequenceDiagram | 26 | Keep |
| project05-target-state | flowchart TB | 57 | **Replace** |
| project06-device-trust-tiers | flowchart TB | 54 | **Replace** |
| project07-existing-vdi | flowchart TB | 43 | **Replace** (current-state) |
| project07-production-architecture | flowchart TB | 72 | **Replace** (target-state) |
| project07-scaling-architecture | flowchart TB | 50 | **Replace** |
| project08-developer-platform | flowchart TB | 57 | **Replace** |
| project10-app-attach-lifecycle | sequenceDiagram | 20 | Keep |
| project10-multi-client-platform | flowchart TB | 56 | **Replace** (target-state) |

**Already-complete architecture files** (18, from prior passes): 10 hero diagrams (all `.drawio` + `.svg`, self-contained), `ch01-shared-responsibility` (`.drawio` + `.svg`, self-contained), and 3 Project 09 diagrams (`.svg`, 2 with `.drawio` that still reference remote icon URLs, flagged below as a genuine technical inconsistency to fix, not a new diagram to build).

---

## Totals

| Classification | Count |
|---|---|
| Total standalone Mermaid diagrams inventoried | 52 |
| Keep as Mermaid (correct as-is) | 18 |
| **Replace with self-contained Draw.io + SVG** | **34** |
| Already replaced (prior passes) | 1 (Chapter 1) + 3 (Project 09, partial) |
| Missing diagrams identified (see below) | 0 new gaps found, every chapter, lab and published project already has at least one diagram; the work here is upgrading format, not filling a gap |

**Genuine technical inconsistency found, not a new build:** `project09-02-gpu-rendering-path.drawio` and `project09-03-production-architecture.drawio` still reference remote Azure icon URLs, the same inconsistency found and fixed for hero diagrams 1, 5, and 10 in Audit 14. These two are queued for the same fix, not a rebuild of content.

---

## Batch plan and realistic scope, stated honestly

34 diagrams need full self-contained `.drawio` + `.svg` + rendered-and-inspected `.png` treatment. Based on the hero diagram pass (Audit 13-14), a diagram that needs real architectural correctness (zones, boundaries, non-crossing connectors) took between 1 and 4 iterations to pass a full visual inspection. Building all 34 to that same bar in one continuous pass is a large amount of work; this document commits to the batch order requested and executes as far as the session allows, reporting the exact stopping point rather than a partial pass presented as complete.

**Batch order and count:**

| Batch | Scope | Diagrams to replace |
|---|---|---|
| 1 | Chapters 1-8 | 2 (ch02, ch08-identity-architecture) |
| 2 | Chapters 9-16 | 6 (ch09, ch10, ch13, ch14-rdp, ch14-teams, ch16-config-objects) |
| 3 | Chapters 17-25 | 9 (ch17, ch18, ch19, ch20-permissions, ch20-redundancy, ch22, ch23, ch24, ch25) |
| 4 | Labs 1-10 | 5 (lab03, lab04, lab05, lab08, lab10) |
| 5 | Projects 01-05 | 6 (project01, project04 x3, project05 x2) |
| 6 | Projects 06-10 | 6 (project06, project07 x3, project08, project10) |
| 7 | Troubleshooting + final indexes | 0 new diagrams (the 5 runbooks currently have no diagrams and do not need one, they are procedural, not architectural); index and reference updates only |

Batch 1 begins immediately following this document.
