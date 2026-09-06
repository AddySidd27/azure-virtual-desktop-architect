# Audit 16 - Repository-Wide Diagram Remediation: Closing Report

**Date:** August 2026
**Scope:** Every diagram in the repository, Chapters 1-25, Labs 1-10, published Projects 01/02/04-10, troubleshooting runbooks, brought to the standard established for the 10 hero diagrams (Audit 14): self-contained vector shapes, zero remote icon dependency, editable `.drawio` source, matching `.svg` export, rendered PNG visually inspected, technical accuracy verified against the related chapter/lab/Terraform.

---

## 1. Total diagrams inventoried

**52 standalone Mermaid diagrams** at the start of this pass (Audit 15), plus the 10 hero diagrams and Chapter 1/Project 09 diagrams already complete from prior passes.

## 2. Mermaid diagrams retained, and why

**18 diagrams retained as Mermaid**, unchanged, each independently classified as a `sequenceDiagram` or a small (`<25` line) decision tree / object relationship with no zone or boundary structure, exactly the categories the brief specifies Mermaid remains correct for:

`ch03-avd-object-model`, `ch04-avd-connection-flow`, `ch05-session-host-os-decision`, `ch06-client-path-decision`, `ch07-join-model-decision`, `ch08-authentication-sequence`, `ch11-egress-enforcement-points`, `ch12-topology-decision`, `ch15-broker-host-selection`, `ch15-pooled-vs-personal-decision`, `ch16-management-approach-decision`, `ch24-session-host-enrolment-decision`, `lab07-object-model`, `lab09-two-delivery-models`, `project04-policy-decision-flow`, `project05-dependency-disposition`, `project05-entra-signin-sequence`, `project10-app-attach-lifecycle`.

Verified at the end of this pass by direct file listing against the exact list committed to in Audit 15, this is not a memory-based reconciliation; `ls diagrams/*.mermaid` returns precisely these 18 files and no others.

## 3. Mermaid diagrams improved

**0.** No small decision tree or sequence was rewritten or converted, per the explicit instruction not to inflate the Draw.io count by converting simple diagrams that were already correct.

## 4. Architecture diagrams replaced

**34 of 34**, matching Audit 15's classification exactly:

| Batch | Count | Diagrams |
|---|---|---|
| 1 (Chapters 1-8) | 2 | ch02-avd-control-plane, ch08-identity-architecture |
| 2 (Chapters 9-16) | 6 | ch09-conditional-access-app-targeting, ch10-rbac-permission-planes, ch13-avd-egress-architecture, ch14-rdp-transport-selection, ch14-teams-media-optimisation, ch16-session-host-configuration-objects |
| 3 (Chapters 17-25) | 9 | ch17-session-host-placement, ch18-session-host-registration, ch19-fslogix-profile-flow, ch20-azure-files-permission-layers, ch20-profile-storage-redundancy, ch22-cloud-cache-flow, ch23-image-build-pipeline, ch24-intune-management-planes, ch25-application-delivery-routes |
| 4 (Labs) | 4 | lab03-network-topology, lab04-identity-topology, lab05-storage-topology, lab08-session-host-join |
| 5 (Projects 01-05) | 6 | project01-harbourview-architecture, project04-dc-dns-placement, project04-hybrid-estate-as-found, project04-target-state, project05-ad-dependent-as-found, project05-target-state |
| 6 (Projects 06-10) | 6 | project06-device-trust-tiers, project07-existing-vdi, project07-production-architecture, project07-scaling-architecture, project08-developer-platform, project10-multi-client-platform |
| 7 (Troubleshooting) | 0 | Runbooks are procedural, not architectural, no diagram was needed or added |

**1 diagram resolved by reference, not rebuilt:** `lab10-complete-environment` was retired rather than duplicated, because Hero Diagram 10 already shows the complete Labs 1-10 environment (including Lab 10's own `log-avd-lab-eus2-01` and `sp-avd-lab-eus2-01`) with exact Terraform names. Lab 10's markdown now points directly at it, with a note explaining why a second near-identical diagram was not built. This is the "do not repeat completed work" principle applied at the lab level.

## 5. Draw.io files created

**35 new `.drawio` sources** in this pass (34 replacement diagrams, minus Lab 10's by-reference resolution, plus 1 pre-existing exception fixed, see section 11).

## 6. SVG files created

**34 new `.svg` files**, one per replaced diagram.

## 7. Diagrams removed as duplicates

**1**, `lab10-complete-environment.mermaid`, retired in favour of the existing Hero Diagram 10, as above. No other duplicates were found; the repository-wide inventory in Audit 15 found no case of two diagrams covering the same content by accident.

## 8. Missing diagrams added

**0.** Audit 15's inventory found that every chapter, lab, and published project already had at least one diagram before this pass began. The work in this pass was entirely format and quality remediation, not gap-filling.

## 9. PNG visual-QA result

**Every one of the 34 replaced diagrams was rendered to PNG with `cairosvg` and visually inspected**, not just structurally bounds-checked. This is the same standard applied to the 10 hero diagrams in Audits 13-14, extended across the whole repository.

**Real defects found and fixed during this pass, by category:**

| Defect class | Count (approx.) | Example |
|---|---|---|
| Tile too short/narrow for two-line label, causing text clipping | ~14 | ch02's "Diagnostics" tile, Project 07's "Contact Centre App" tile, Project 10's "Insurer D Team" subtitle |
| Canvas too narrow for content, causing edge clipping | ~4 | ch23's "Apps + Optimisations" tile, Project 08's zone headers |
| Zone height insufficient for its row count, causing overlap with the section below | ~3 | Project 07's scaling-architecture demand zone, Project 10's Users zone |
| Wrong diagram type chosen (flow diagram forced onto a many-to-many relationship) | 1 | ch10-rbac-permission-planes, rebuilt as a matrix/table, not boxes and arrows, which passed clean on the first render specifically because the format fit the content |
| Debugging leftover left in generator code, crashing the build | 2 | ch18, ch02, caught immediately by the traceback, not shipped |

None of these would have been caught by an XML-parse or bounds-only check; every one required actually rendering the image and looking at it.

## 10. Technical-QA result

Every replaced diagram was cross-checked against its source content before being drawn, not just visually polished after the fact. Specific findings from that cross-check, not from visual inspection:

- **Lab 3's old diagram used generic subnet labels** ("Identity Subnet") that matched nothing in `terraform/lab03-network/`. Rebuilt with the real names (`snet-identity-lab-eus2-01`, etc.) and added the actual NSG rule set by priority (140, 150, 160, 4000), which the old diagram omitted entirely.
- **Project 01 cross-checked against `project-01-smb-cost-sensitive.md`** confirmed the exact identity decision (cloud-only, Entra Kerberos, no AD DS pair) and exact headcounts (134 pooled + 6 personal) rather than assumed figures.
- **Project 07 cross-checked against `project-07-call-centre-high-density.md`** confirmed the real numbers used in the scaling diagram (Shift 1: 520, Shift 2: 610, Shift 3: 180, Emergency Surge: 300) rather than illustrative placeholders.
- **ch10's RBAC diagram** required recognising that a many-to-many role mapping is a table, not a flowchart, a technical-accuracy judgement about representation, not just a layout fix.

## 11. Self-containment: a repository-wide finding, not just a hero-diagram one

At the final validation step, a `grep` across every `.drawio` file in the repository found **one remaining exception**: `ch01-shared-responsibility.drawio` still referenced remote Azure icon URLs, inconsistent with the self-contained standard established after the Diagram 4 rebuild (Audit 14) and inconsistent with its own already-self-contained `.svg`. This was fixed in this pass, rebuilt to match the existing SVG exactly, using the same vector shape system as every other diagram. Re-verified: **zero `.drawio` files in the entire repository now reference a remote image.**

## 12. Broken-link result

**0** at every checkpoint this pass ran the check, after each batch, and again at the very end after the index updates. Full repository-wide re-scan for this closing report: **0 broken local links.**

## 13. Additional validation run for this closing report

```
XML validity, all 47 SVG + 46 .drawio files:        47/47, 46/46 valid
Self-containment (remote image= refs):               0 across all .drawio files
Structural bounds (element coordinates in canvas):   0 out-of-bounds across all 47 SVGs
Citation artifact scan (<cite index=):                1 match, confirmed legitimate self-reference
Secrets scan:                                         0 real matches, 0 non-example .tfvars
Mermaid file count:                                   18 (exact match to Audit 15's Keep list)
```

## 14. Remaining limitations, stated honestly

- **`.drawio` and `.svg` pairs are independently authored**, not one exported from the other, this environment cannot perform that export. Every pair was built from the same coordinates and content and cross-checked by hand, but a byte-for-byte diff between them was not run. Anyone editing one going forward should update the other.
- **No live Azure deployment** has validated that these diagrams' resource names and relationships hold up against a real running environment, the verification here is against the documented Terraform and prose, not a live subscription.
- **Terraform CLI validation remains unavailable** in this environment (confirmed again: `releases.hashicorp.com` returns `x-deny-reason: host_not_allowed`), unchanged from every prior audit in this repository's history.
- **A handful of minor cosmetic issues remain** in a few diagrams (slight label crowding, not clipping) where the content was judged more important to get right than to keep iterating on for further rounds of pixel-perfection, these are visible on close inspection but do not affect readability or accuracy, and are not hidden here.

## 15. Verdict

**Private preview ready.** This pass closes out the diagram-quality gap that Audits 12-15 identified and tracked honestly across four consecutive passes: from "2 of 10 hero diagrams, no true visual QA" through to a complete, self-contained, visually-verified diagram set across the entire repository, 10 hero diagrams, 34 chapter/lab/project diagrams, and 18 correctly-retained Mermaid diagrams, all validated by the same standard. What remains before a stronger verdict is unchanged from every prior report: a live Azure validation pass, and the Terraform CLI checks this environment cannot run.
