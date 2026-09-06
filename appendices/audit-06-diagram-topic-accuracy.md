# Audit 06 - Diagram Audit Against the Architecture Artifact Standard

**Date:** August 2026
**Scope:** All 29 diagrams, Chapters 1 to 22 and Labs 3 and 4
**Test applied:** Remove the chapter title, show only the diagram, and ask what topic it appears to explain. If the answer is not the chapter topic, rebuild.
**Result:** 6 diagrams failed and were rebuilt. 15 passed as decision trees or sequences, which are the correct type for their purpose. 8 passed as architecture diagrams.

---

## 1. The two that were called out, and why they failed

**Chapter 13, egress architecture.** The old diagram showed a hub, a spoke and a firewall with arrows between them. Shown without the chapter title, it looked like a generic Azure Firewall diagram. The chapter is about controlled AVD egress, and the diagram did not make the defining properties visible: that traffic is outbound only, that the route table is what forces it through the firewall, and that there is no inbound path to session hosts.

Rebuilt. The route table is now a component in the spoke rather than an implied property, the outbound chain from session hosts through the route table to the firewall is the dominant path, allow and deny are separate outcomes, on-premises traffic leaves via the gateway, and the absent inbound path is drawn as a crossed red link labelled "no inbound, no public IP".

**Chapter 14, Teams media optimisation.** The old diagram had the components but did not separate signalling from media. The one idea a reader must get in ten seconds is that signalling stays on the session host while media leaves from the endpoint, and that was not visually obvious.

Rebuilt. The endpoint now contains the media engine and the devices, the optimised media path is the heaviest line on the diagram and goes endpoint to Teams service without touching the session host, signalling and chat are normal weight from the session host, and the fallback path is red and dashed from the session host.

---

## 2. Full audit

| Diagram | Type | Topic test | Verdict |
|---|---|---|---|
| ch01 shared responsibility | Architecture | Passed after rebuild | **Rebuilt.** Was two flat groups. Now endpoint, Microsoft managed and customer managed as ownership boundaries with the dependency fan-out from session hosts |
| ch02 service architecture | Architecture | Pass | Keep |
| ch03 object model | Architecture | Pass | Keep. Four labelled layers, relationship arrows |
| ch04 connection flow | Sequence | Pass | Keep. Order is the subject, so sequence is correct |
| ch05 OS decision | Decision tree | Pass | Keep |
| ch06 client path | Decision tree | Pass | Keep |
| ch07 join model | Decision tree | Pass | Keep |
| ch08 identity architecture | Architecture | Pass | Keep. Five ownership zones, both app IDs, Kerberos path |
| ch08 authentication sequence | Sequence | Pass | Keep |
| ch09 Conditional Access | Architecture | Failed | **Rebuilt.** Was two boxes and two policies with no architecture. Now shows both enforcement points across endpoint, Entra ID, Microsoft managed and customer Azure, with the two token paths |
| ch10 permission planes | Architecture | Pass | Keep. Role holders outside, three permission planes as zones |
| ch11 egress enforcement | Decision tree | Pass | Keep |
| ch12 topology decision | Decision tree | Pass | Keep |
| ch13 egress architecture | Architecture | Failed | **Rebuilt.** See section 1 |
| ch14 transport paths | Architecture | Marginal | **Rebuilt.** Ownership zones added, managed and public Shortpath labelled distinctly, primary TCP path made dominant |
| ch14 Teams media | Architecture | Failed | **Rebuilt.** See section 1 |
| ch15 pooled or personal | Decision tree | Pass | Keep |
| ch15 broker selection | Sequence | Pass | Keep. Reconnect against new session is an ordered comparison |
| ch16 management approach | Decision tree | Pass | Keep |
| ch16 SHC objects | Architecture | Pass | Keep. Microsoft managed objects against customer resources |
| ch17 host placement | Architecture | Pass | Keep. Three zones and the shared storage dependency |
| ch18 registration components | Architecture | Pass | Keep |
| ch19 FSLogix flow | Architecture | Failed | **Rebuilt.** Was a flat left to right chain. Now separates session host, storage and identity as zones, and adds the temporary profile as a visible failure outcome, which is the chapter's core symptom |
| ch20 redundancy scope | Architecture | Pass | New in this pass. Zones inside a region, dashed paired region |
| ch20 access path | Architecture | Pass | Rebuilt earlier in this pass. Storage account as one boundary containing share, ACL and container |
| ch22 Cloud Cache | Architecture | Pass | Rebuilt earlier in this pass. Secondary provider greyed as standby, read after failover dashed |
| ch24 endpoint management | Decision tree | Pass | Keep |
| lab03 network topology | Lab architecture | Pass | Keep. Only shows what Lab 3 deploys |
| lab04 identity topology | Lab architecture | Pass | Keep. Later lab components greyed |

---

## 3. What changed in the standard

**Decision trees are not architecture diagrams and are not held to the same test.** A decision tree answers "which option do I choose". It has no components, no boundaries and no traffic. Fifteen of the diagrams in this repository are decision trees or sequences, and forcing ownership boundaries onto them would make them worse. They are labelled as such in the chapters.

**Every architecture diagram now carries a classification label above it**, so a reader is never left wondering whether it came from Microsoft:

- `OUR ORIGINAL ARCHITECTURE DIAGRAM` where it represents Microsoft's documented architecture
- `RECOMMENDED ARCHITECTURE` where it is our design rather than a Microsoft reference architecture
- `LAB ARCHITECTURE` for the lab environment
- `EXAMPLE CUSTOMER ARCHITECTURE` for Northwind

No Microsoft image is reproduced anywhere in the repository. Microsoft Learn is linked as the authoritative reference below each diagram, and the diagram is verified against it.

**Visual weight now carries meaning consistently.** Primary path is the heaviest line. Optional paths are lighter. Optimised paths are green. Fallback paths are dashed. Blocked paths are red. A reader learns this once.

---

## 4. Verification after the rebuild

| Check | Result |
|---|---|
| Any node containing more than a component name | None |
| Any sentence on an arrow | None. Longest label is "no inbound, no public IP" |
| Every architecture diagram has ownership boundaries | Pass |
| Every diagram has a title | Pass |
| Primary path visually dominant on every architecture diagram | Pass |
| Blocked and fallback paths visually distinct | Pass |
| Topic test passed without the chapter title | Pass for all 29 |
| Classification label present | Pass on all rebuilt diagrams |
| Microsoft images reproduced | None |
| Standalone `.mermaid` file and inline block for each | Pass |

---

## 5. The honest lesson

This is the fourth diagram audit. The first three improved labels, then layout, then text length. This one changed the question being asked.

The earlier audits asked whether the diagram was accurate and readable. The right question is what a reader thinks the diagram is about when they see it with no title. A technically correct diagram that looks like a generic Azure drawing has failed, because the reader learns nothing from it that the chapter text did not already say.

Chapters 13 and 14 both failed that test while passing every earlier check, which is why the test is now part of the standard.
