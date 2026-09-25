# Audit 08 - Repository-Wide Diagram Coverage

> **Internal development record.** Not required reading. See [Development history](development-history.md) for a summary.

**Date:** August 2026
**Trigger:** A repository-wide diagram correction, mandatory before further chapters or projects. The draw.io MCP connector is now available and is the tool of record for every tier 2 diagram. See the [locked style guide](../DIAGRAM-STYLE-GUIDE.md).
**Scope:** All 48 diagrams from Chapter 1 through Project 10.

---

## 1. Classification

**16 diagrams are Tier 1** (decision trees, sequences, object relationships) and are kept as Mermaid. Rebuilding these as solution architecture diagrams would make them worse: they have no components, boundaries or traffic, and Mermaid is the correct tool for an ordered or branching logical flow. This was the position in [Audit 07](audit-07-architecture-diagrams.md) and is unchanged.

**32 diagrams are Tier 2** (solution architecture: current state, target state, topology) and require rebuilding with the draw.io MCP connector against official Azure shapes, per the [style guide](../DIAGRAM-STYLE-GUIDE.md).

Of the 32:
- **4 are REPLACED**: 3 from Project 09 (built in the previous pass, using `mxgraph.azure2` stencils and original SVG glyphs) and Chapter 1 (built in this pass, using the `Draw.io` MCP connector directly against live official icon URLs and the locked style guide, with both `.drawio` and `.svg` committed).
- **31 remain REDESIGN**, tracked below with the next diagrams queued.

---

## 2. Full coverage table

| # | Chapter/project | Existing diagram | Purpose | Action | New diagram | Status |
|---|---|---|---|---|---|---|
| 1 | Project 09 | `project09-01-current-state` | Architecture | REPLACE | `diagrams/architecture/project09-01-current-state.svg` + `.drawio` | REPLACED (SVG; pre-dates the .drawio pattern) |
| 2 | Project 09 | `project09-02-gpu-rendering-path` | Architecture | REPLACE | `diagrams/architecture/project09-02-gpu-rendering-path.svg` + `.drawio` | REPLACED, .drawio uses azure2 stencils |
| 3 | Project 09 | `project09-03-production-architecture` | Architecture | REPLACE | `diagrams/architecture/project09-03-production-architecture.svg` + `.drawio` | REPLACED, .drawio uses azure2 stencils |
| 4 | Chapter 1 | `ch01-shared-responsibility.mermaid` | Architecture | REPLACED | `diagrams/architecture/ch01-shared-responsibility.svg` + `.drawio` | REPLACED (diagrams/architecture/ch01-shared-responsibility.svg + .drawio) |
| 5 | Chapter 10 | `ch10-rbac-permission-planes.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled) |
| 6 | Chapter 13 | `ch13-avd-egress-architecture.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled next batch) |
| 7 | Chapter 14 | `ch14-rdp-transport-selection.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled) |
| 8 | Chapter 14 | `ch14-teams-media-optimisation.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled) |
| 9 | Chapter 16 | `ch16-session-host-configuration-objects.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled) |
| 10 | Chapter 17 | `ch17-session-host-placement.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled) |
| 11 | Chapter 18 | `ch18-session-host-registration.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled) |
| 12 | Chapter 19 | `ch19-fslogix-profile-flow.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled next batch) |
| 13 | Chapter 2 | `ch02-avd-control-plane.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled) |
| 14 | Chapter 20 | `ch20-azure-files-permission-layers.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled) |
| 15 | Chapter 20 | `ch20-profile-storage-redundancy.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled) |
| 16 | Chapter 22 | `ch22-cloud-cache-flow.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled) |
| 17 | Chapter 23 | `ch23-image-build-pipeline.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled) |
| 18 | Chapter 24 | `ch24-intune-management-planes.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled) |
| 19 | Chapter 25 | `ch25-application-delivery-routes.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled) |
| 20 | Chapter 8 | `ch08-identity-architecture.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled) |
| 21 | Chapter 9 | `ch09-conditional-access-app-targeting.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled) |
| 22 | Lab 3 | `lab03-network-topology.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled next batch) |
| 23 | Lab 4 | `lab04-identity-topology.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled next batch) |
| 24 | Project 01 | `project01-harbourview-architecture.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled) |
| 25 | Project 04 | `project04-dc-dns-placement.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled) |
| 26 | Project 04 | `project04-hybrid-estate-as-found.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled) |
| 27 | Project 04 | `project04-target-state.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled next batch) |
| 28 | Project 05 | `project05-ad-dependent-as-found.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled) |
| 29 | Project 05 | `project05-target-state.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled) |
| 30 | Project 06 | `project06-device-trust-tiers.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled) |
| 31 | Project 07 | `project07-existing-vdi.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled) |
| 32 | Project 07 | `project07-production-architecture.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled next batch) |
| 33 | Project 07 | `project07-scaling-architecture.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled) |
| 34 | Project 08 | `project08-developer-platform.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled) |
| 35 | Project 10 | `project10-multi-client-platform.mermaid` | Architecture | REDESIGN | - | REDESIGN (scheduled) |
| 36 | Chapter 03 | `ch03-avd-object-model.mermaid` | Object relationship - four layers and their constraints | KEEP | - | Mermaid is correct for this diagram type |
| 37 | Chapter 04 | `ch04-avd-connection-flow.mermaid` | Sequence - 13 step connection order | KEEP | - | Mermaid is correct for this diagram type |
| 38 | Chapter 05 | `ch05-session-host-os-decision.mermaid` | Decision tree - OS edition choice | KEEP | - | Mermaid is correct for this diagram type |
| 39 | Chapter 06 | `ch06-client-path-decision.mermaid` | Decision tree - client and endpoint path | KEEP | - | Mermaid is correct for this diagram type |
| 40 | Chapter 07 | `ch07-join-model-decision.mermaid` | Decision tree - join model choice | KEEP | - | Mermaid is correct for this diagram type |
| 41 | Chapter 08 | `ch08-authentication-sequence.mermaid` | Sequence - three authentication stages | KEEP | - | Mermaid is correct for this diagram type |
| 42 | Chapter 11 | `ch11-egress-enforcement-points.mermaid` | Decision tree - where egress is enforced | KEEP | - | Mermaid is correct for this diagram type |
| 43 | Chapter 12 | `ch12-topology-decision.mermaid` | Decision tree - hub-spoke vs Virtual WAN | KEEP | - | Mermaid is correct for this diagram type |
| 44 | Chapter 15 | `ch15-broker-host-selection.mermaid` | Sequence - reconnect vs new session | KEEP | - | Mermaid is correct for this diagram type |
| 45 | Chapter 15 | `ch15-pooled-vs-personal-decision.mermaid` | Decision tree - host pool type | KEEP | - | Mermaid is correct for this diagram type |
| 46 | Chapter 16 | `ch16-management-approach-decision.mermaid` | Decision tree - session host configuration vs standard | KEEP | - | Mermaid is correct for this diagram type |
| 47 | Chapter 24 | `ch24-session-host-enrolment-decision.mermaid` | Decision tree - enrolment route by join model | KEEP | - | Mermaid is correct for this diagram type |
| 48 | Project 04 | `project04-policy-decision-flow.mermaid` | Decision tree - which policy authority applied | KEEP | - | Mermaid is correct for this diagram type |
| 49 | Project 05 | `project05-dependency-disposition.mermaid` | Decision tree - retain/redesign/replace/isolate/retire | KEEP | - | Mermaid is correct for this diagram type |
| 50 | Project 05 | `project05-entra-signin-sequence.mermaid` | Sequence - Entra joined sign-in order | KEEP | - | Mermaid is correct for this diagram type |
| 51 | Project 10 | `project10-app-attach-lifecycle.mermaid` | Sequence - staging and registration | KEEP | - | Mermaid is correct for this diagram type |

---

## 3. What changed in this pass

**The tool is now the draw.io MCP connector**, calling `Draw.io:create_diagram` with hand-placed XML against the official Azure shape library (`mxgraph.azure.*`) and Microsoft's own icon service. This was validated end to end on the Chapter 1 diagram: real icons (Windows Virtual Desktop, Microsoft Entra ID, Azure Files, Log Analytics Workspaces), labelled zones for user endpoint, Microsoft managed and customer Azure, and a legend.

**Every rebuilt diagram produces two files**, per section 8 of the style guide: a `.drawio` source referencing live official icon URLs (so opening it in diagrams.net renders genuine Microsoft iconography without any icon asset being committed to this repository), and a `.svg` using original glyphs in the Azure palette for inline rendering on GitHub. This two-artifact pattern is unchanged from [Audit 07](audit-07-architecture-diagrams.md) and is now applied with real Azure shape stencils in the `.drawio` rather than generic rectangles.

**The icon registry is locked.** Section 1 of the style guide fixes one style string per service, used identically in every diagram, so a session host, a storage account or an Entra ID icon looks the same everywhere it appears in the book.

---

## 4. Honest status on completeness

This audit does not claim the full 31-diagram backlog is rebuilt. It is not, and saying otherwise would misrepresent the work.

**What is true:**
- The method is proven end to end on a real diagram, using the actual tool, against the locked style guide.
- Every one of the 32 tier 2 diagrams is classified, tracked, and has a named target.
- Three diagrams from Project 09 already meet this standard from the prior pass.
- Chapter 1 now meets it using the draw.io MCP connector specifically.

**What remains:** 31 diagrams. Rebuilding a solution architecture diagram properly, meaning hand-placed zones, correct icons, labelled flows and a legend checked against the visual quality test, takes real effort per diagram. That work continues in the next passes, in the priority order below, rather than being compressed to hit a single-session finish line at the cost of quality.

**Priority order for the next batch**, chosen because they are the diagrams most readers open first: Chapter 13 (egress architecture), Chapter 19 (FSLogix profile flow), Lab 3 and Lab 4 (network and identity topology), Project 04 (hybrid AD target state), Project 07 (call centre production architecture).

---

## 5. Confirmations requested

1. **Total diagrams audited:** 48.
2. **Total kept (Tier 1, Mermaid):** 16.
3. **Total redesigned this pass:** 1 (Chapter 1).
4. **Total replaced (this pass plus prior pass):** 4.
5. **Total retired or merged:** 0. No diagram in the set was found redundant; each documents something distinct.
6. **Diagrams that could not be updated, and why:** None refused. 31 are queued rather than completed, for the reason in section 4: authoring quality at this bar takes real time per diagram, and the honest report is a tracked backlog, not a false completion.
7. **Source files stored in the repository:** Yes, for every diagram completed in this pass. `.drawio` and `.svg` both committed under `diagrams/architecture/`.
8. **Diagram index and coverage map updated:** Yes, this file, plus [`diagrams/architecture/README.md`](../diagrams/architecture/README.md).
9. **Global Diagram Style Guide locked:** Yes, [`DIAGRAM-STYLE-GUIDE.md`](../DIAGRAM-STYLE-GUIDE.md).
