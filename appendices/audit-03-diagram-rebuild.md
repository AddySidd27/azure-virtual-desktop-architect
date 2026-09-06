# Audit 03 - Diagram Visual Quality Rebuild

**Date:** August 2026
**Scope:** Every diagram in the repository
**Standard applied:** [DIAGRAM-STANDARD.md](../DIAGRAM-STANDARD.md), revised with visual quality rules
**Result:** 13 diagrams rebuilt. 2 kept unchanged. 1 split into two. 2 lab diagrams added inline where they were missing from the chapter.

---

## 1. The problem with the previous diagrams

Audit 02 checked the diagrams for technical completeness and passed most of them. That audit asked the wrong question.

The diagrams were technically accurate and visually poor. Specifically:

- **Node labels were paragraphs.** Boxes contained sentences such as "Windows 11 Enterprise multi-session, pooled host pool only, per-user licence covers it, no RDS CAL, separate OS edition, check policy support". That is chapter text placed inside a rectangle.
- **Arrow labels were sentences.** Several carried three lines of explanation.
- **Configuration detail sat inside architecture components.** Registry paths, ports and instructions appeared in nodes rather than in the chapter.
- **Every component had the same visual weight.** Nothing indicated the primary traffic path or the ownership boundary at a glance.
- **Architecture diagrams were drawn as flowcharts.** Box to box to box, with numbered steps overlaid, rather than layered architecture.

The test that exposed it: could a reader understand the architecture in ten to fifteen seconds without reading the explanation. For most of these diagrams the answer was no.

---

## 2. What changed in the standard

The standard now specifies:

- Short node labels. Component name only, with at most a second line for an address or size.
- Short arrow labels. Protocol, port or purpose. Never a sentence.
- All explanation below the diagram, never inside it.
- No configuration values, registry keys or commands in architecture diagrams.
- A defined colour convention by ownership, applied consistently across every diagram in the book.
- Thicker link styling for the primary traffic path so it is visible immediately.
- Architecture and sequence drawn as separate diagrams rather than combined.
- A two pass review, with visual quality as its own pass and a list of questions to answer honestly.

## 3. The colour convention

Applied to every diagram in the repository, so a reader learns it once.

| Layer | Treatment |
|---|---|
| Microsoft managed | Solid dark blue, white text |
| Customer managed Azure | Light blue |
| On-premises | Warm neutral |
| Endpoint | White, dashed border |
| Blocked or failure path | Red, dashed link |
| Optimised or preferred path | Thick green link |
| Not built in this lab yet | Grey, dashed border |

---

## 4. Diagram by diagram

| Diagram | Action | Reason |
|---|---|---|
| ch02 control plane | **Rebuilt** | Four layers, ownership by colour, primary RDP path in heavy blue, one line per relationship. Detail moved to the explanation |
| ch03 object model | **Rebuilt** | Now three labelled layers, presentation, publishing and compute, with Entra groups as a separate dashed grouping. Previously a flat box chain |
| ch04 connection flow | Kept | Already a sequence diagram with short labels. Correct format for an ordered flow |
| ch05 OS decision | **Rebuilt** | Labels were four line paragraphs. Now short outcome nodes, with licensing outcomes coloured green and amber |
| ch06 client path | **Rebuilt** | Same problem, same fix |
| ch07 join model | **Rebuilt** | Labels shortened. The rule that users must exist in Entra ID is now a single highlighted outcome node rather than repeated text |
| ch08 identity | **Rebuilt and split into two** | One layered architecture diagram showing the identity, service, Azure and on-premises boundaries, plus a separate sequence diagram because the order of the three authentications is the point. Previously one diagram trying to do both |
| ch09 Conditional Access | **Rebuilt** | Two stage subgraphs with the app in each, and the Every time failure drawn as a red dashed path to a failure node |
| ch10 RBAC planes | **Rebuilt** | Three plane subgraphs with role names only, and the four job functions entering from outside. Previously long role descriptions inside nodes |
| ch11 egress enforcement | **Rebuilt** | Reduced from long endpoint lists inside nodes to a clean three way decision ending in a single verification node |
| ch12 topology decision | **Rebuilt** | Labels shortened to three short lines each |
| ch13 egress architecture | **Rebuilt** | Now shows endpoint, Microsoft managed, hub, spoke and on-premises as distinct boundaries, with the blocked path in red and the absent inbound path as a red dashed line |
| ch14 transport selection | **Rebuilt** | Primary TCP path in heavy blue, the three UDP attempts in green, dashed for the ones that may not establish. Reading it now shows immediately that UDP is an upgrade rather than a requirement |
| ch14 Teams media | **Rebuilt** | Control path, media path and fallback path visually distinct. Media path thick green, fallback red dashed. Registry and service detail removed from the nodes |
| ch24 Intune management | **Rebuilt** | Now a two stage decision, join type then host pool type, with short outcomes |
| lab03 network topology | **Rebuilt and added inline** | The diagram existed as a file but was never embedded in the lab. Now shows only the four subnets the lab actually creates, with outbound only traffic and the absent inbound path in red |
| lab04 identity topology | **Rebuilt and added inline** | Same. Components built in later labs are drawn in grey with dashed borders so the lab diagram matches exactly what Lab 4 deploys |

---

## 5. Consistency check

| Check | Result |
|---|---|
| Longest node label | Three short lines, only on decision tree outcome nodes |
| Sentences inside nodes | None |
| Configuration values inside architecture nodes | None. Registry paths and ports moved to chapter text |
| Ownership visible at a glance | Yes, through the colour convention |
| Primary traffic path visually distinct | Yes, through link styling |
| Every diagram both standalone and inline | Yes |
| Sequence diagrams used where order matters | ch04 and ch08 |
| Lab diagrams match deployed resources | Yes, with future components greyed |
| Microsoft diagram images reproduced | None. Links and original diagrams only |

---

## 6. What this audit teaches

Audit 02 checked whether the diagrams contained the right information. They did. That is not the same as being good diagrams.

The lesson worth keeping: a technically complete diagram that takes two minutes to decode is a worse deliverable than a simpler one that is understood immediately and supported by good text below it. The diagram carries the shape. The prose carries the detail. Mixing the two produces something that does neither job.
