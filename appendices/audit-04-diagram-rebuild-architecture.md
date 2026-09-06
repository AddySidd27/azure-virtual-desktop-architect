# Audit 04 - Full Diagram Rebuild to Architecture Standard

**Date:** August 2026
**Scope:** Every diagram in the repository, Chapters 1 to 15 and Labs 3 and 4
**Standard applied:** [DIAGRAM-STANDARD.md](../DIAGRAM-STANDARD.md), tightened again
**Result:** All 21 diagrams rebuilt. One new diagram added. Every component box now contains a component name and nothing else.

---

## 1. What was still wrong after Audit 03

Audit 03 shortened labels from paragraphs to three short lines. That was an improvement and it was still the wrong shape.

Boxes like `Windows 11 multi-session` on one line and `Pooled host pool only` on the next are still explanation inside a rectangle. They force the reader to read the diagram rather than see it. And a diagram made of stacked text boxes reads as a flowchart no matter how it is coloured.

The rule was too soft. It allowed a second line for "an address or a size", and that permission was used everywhere.

---

## 2. The rule now

**A component box contains the component name. Nothing else.**

Good: `Session Host`, `Azure Firewall`, `Microsoft Entra ID`, `Domain Controller`, `FSLogix Storage`, `Windows App`.

Not allowed: subnet ranges, IP addresses, VM sizes, port numbers, configuration values, licensing notes, any second line.

Ports and protocols live on arrows, and only as short labels: `HTTPS 443`, `RDP`, `Kerberos 88`, `SMB 445`, `UDP 3478`, `profile mount`.

Everything else moves to the text below the diagram, which is where the chapter already explains it properly.

Two other rules were added:

- **Every diagram has a title**, set in Mermaid frontmatter.
- **Only draw a diagram when it helps.** A chapter does not need a diagram to be complete. One good diagram beats three weak ones.

---

## 3. What changed, diagram by diagram

| Diagram | Change |
|---|---|
| ch01 shared responsibility | **New.** The old one had sentences as subgraph titles. Now two ownership zones with component names only |
| ch02 service architecture | Rebuilt. Five Microsoft managed components, five customer managed, arrows labelled with protocol and port |
| ch03 object model | Rebuilt. Four zones: Entra ID, presentation, publishing, compute |
| ch04 connection flow | Title added. Already a sequence diagram with short participant names |
| ch05 OS decision | Rebuilt. Outcomes are now `Windows 11 multi-session`, `No RDS CAL`, not four line summaries |
| ch06 client path | Rebuilt. Three outcomes, one short consequence each |
| ch07 join model | Rebuilt. Three join types, two outcomes, one rule node |
| ch08 identity architecture | Rebuilt. Five zones: user, Entra ID, Microsoft managed, customer Azure, on-premises |
| ch08 authentication sequence | Title added. Kept as a sequence because order is the point |
| ch09 Conditional Access | Rebuilt. Two zones, one app and one policy in each |
| ch10 permission planes | Rebuilt. Role holders on the left, three permission planes as zones. Role names are the labels |
| ch11 egress enforcement | Rebuilt. Three enforcement points, one verification node |
| ch12 topology decision | Rebuilt. Two options, one shared outcome |
| ch13 egress architecture | Rebuilt. User, Microsoft managed, hub, spoke, on-premises. Blocked inbound path in red dashed |
| ch14 transport paths | Rebuilt. Primary TCP path heavy, UDP attempts green, relay paths dashed |
| ch14 Teams media | Rebuilt. Media path heavy green, fallback red dashed, no registry detail |
| ch15 pooled or personal | Rebuilt. Three questions, two outcomes, one consequence each |
| ch15 broker selection | Title added. Sequence diagram, correct type for a reconnect comparison |
| ch24 endpoint management | Rebuilt. Two stage decision |
| lab03 network topology | Rebuilt. Four subnets by function, no CIDR ranges in boxes |
| lab04 identity topology | Rebuilt. Later lab components greyed and dashed |

---

## 4. Verification

| Check | Result |
|---|---|
| Multi-line node labels anywhere | None |
| Longest label | `Desktop Virtualization Contributor`, an Azure role name |
| Configuration values inside nodes | None. CIDR ranges, IP addresses and registry paths moved to text |
| Sentences on arrows | None. Longest arrow label is `profile mount` |
| Every diagram titled | Yes |
| Ownership zones present on architecture diagrams | Yes |
| Correct diagram type for the purpose | Architecture for relationships, sequence for ordered flows, decision tree for choices |
| Standalone `.mermaid` file and inline block for each | Yes |
| Consistent colour convention across all diagrams | Yes |
| Microsoft diagram images reproduced | None |

---

## 5. The convention, stated once

| Element | Treatment |
|---|---|
| Microsoft managed | Solid dark blue, white text |
| Customer Azure | Light blue |
| On-premises | Warm neutral |
| User endpoint | White, dashed border |
| Storage | Cylinder shape |
| Primary traffic path | Thick blue arrow |
| Optional or optimised path | Green, dashed when it may not establish |
| Blocked path | Red dashed |
| Built in a later lab | Grey, dashed border |

A reader learns this once and it holds for the whole course.

---

## 6. What this audit teaches

Three audits were needed on the same subject, and each one failed for the same underlying reason: the standard permitted a little explanatory text inside a component, and any allowance gets used to its limit.

The fix was not more review. It was removing the allowance. A component box contains a component name. That rule cannot be stretched, which is why it works.
