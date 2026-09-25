# Audit 02 - Diagrams against the Diagram Quality Standard

> **Internal development record.** Not required reading. See [Development history](development-history.md) for a summary.

**Date:** August 2026
**Scope:** Every diagram in the repository at the time Chapter 14 was written
**Standard applied:** [DIAGRAM-STANDARD.md](../DIAGRAM-STANDARD.md)
**Result:** Two diagrams rebuilt, one explanation extended, five decision diagrams documented as using the reduced explanation set. Chapter 14 written to the standard from the start.

---

## 1. What the audit found

The diagram standard was written after Chapter 13. Diagrams produced before it were checked against it rather than assumed compliant.

| Diagram | Layers | Boundaries | Labelled traffic | Six part explanation | Verdict |
|---|---|---|---|---|---|
| ch02 control plane | Weak | Present but unlabelled | Partial | No | **Rebuilt** |
| ch03 object model | Not applicable | Not applicable | Relationship arrows, correct | Partial | Acceptable. This is an object relationship diagram, not a traffic diagram |
| ch04 connection flow | Sequence diagram | Implied | Yes, numbered | Yes | Acceptable. Sequence format suits a flow |
| ch05 OS decision | Decision tree | Not applicable | Not applicable | Reduced set | Documented |
| ch06 client path | Decision tree | Not applicable | Not applicable | Reduced set | Documented |
| ch07 join model | Decision tree | Not applicable | Not applicable | Reduced set | Documented |
| ch08 three authentications | Weak | Missing | Missing | No | **Rebuilt** |
| ch09 Conditional Access apps | Partial | App boundary shown | Yes | Yes | Acceptable |
| ch10 RBAC permission planes | Yes, three planes | Yes | Not traffic, permission scope | Yes | Acceptable |
| ch11 egress enforcement | Decision tree | Not applicable | Not applicable | Reduced set | Documented |
| ch12 topology decision | Decision tree | Not applicable | Not applicable | Reduced set | Documented |
| ch13 egress architecture | Yes | Yes, hub and spoke | Yes, with ports | Missing two sections | **Extended** |
| lab03 network topology | Yes | VNet and subnets | Yes | In lab format | Acceptable. Matches deployed resources exactly |
| lab04 identity topology | Yes | VNet and subnets | Yes | In lab format | Acceptable. Matches deployed resources exactly |

---

## 2. What was fixed

### Chapter 2, control plane diagram, rebuilt

The original showed three groups with unlabelled arrows. It did not communicate the one boundary the whole book depends on.

The rebuilt diagram has four layers: user and client, Microsoft managed control plane, management plane, and customer managed. The Microsoft managed and customer managed boundaries are named in the subgraph titles rather than implied. Every arrow carries a protocol and a purpose, the persistent outbound 443 connection is drawn as a heavy arrow because it is the mechanism the whole architecture rests on, and the absent inbound path is drawn as a labelled dotted line because its absence is the design point.

The explanation was extended from four sections to the full six, adding important design decisions with cross references, and a failure point table mapping each component to its symptom and first check.

### Chapter 8, three authentications diagram, rebuilt

The original was three boxes in a row. For an identity diagram, the standard requires authentication, authorization, Conditional Access, MFA, session host authentication and single sign-on to be distinguishable. The original showed none of that.

The rebuilt diagram separates the identity layer from the service and the session host, names both Entra application IDs, shows Conditional Access and MFA evaluated at stage one only, draws authorization as a separate step from authentication, shows the single sign-on path as a dotted line against the prompted path, includes the Kerberos ticket request to the domain controller with the port and the line of sight requirement, and draws the fact that Conditional Access does not apply at stages two and three as an explicit labelled line, because that misunderstanding causes more wasted investigation than anything else in this area.

Full six part explanation added, including a failure point table keyed by stage.

### Chapter 13, egress architecture, explanation extended

The diagram met the standard. The explanation was missing important design decisions and failure points. Both added.

### Five decision diagrams, convention documented

Chapters 5, 6, 7, 11 and 12 contain decision flow diagrams. Their purpose is to show how a choice is made, not how a system is built, so failure points do not apply. Rather than manufacture failure points for a decision tree, the standard defines a reduced explanation set for this diagram type, and each of these five chapters now carries a note saying which set it uses and why.

This is a deliberate exception, recorded here so it does not read as an oversight.

---

## 3. Chapter 14

Written to the standard from the start. Two diagrams rather than one, because transport selection and Teams media redirection are different flows and combining them would have produced something unreadable. Both carry layers, boundaries, labelled traffic with ports and protocols, and the full six part explanation.

The transport diagram uses heavy arrows for the connection that always happens and thin arrows for the optimisation attempts, so the reader can see at a glance that UDP is an upgrade rather than a requirement. The Teams diagram draws the silent fallback to server side rendering as a labelled dotted line, because that failure mode is the reason the diagram exists.

---

## 4. Consistency check

| Check | Result |
|---|---|
| Every diagram exists as both a standalone `.mermaid` file and an inline block | Pass |
| Filenames chapter prefixed and descriptive | Pass |
| Same component named the same way across all diagrams | Pass. Broker service, gateway service, resource directory, session host used consistently |
| Traffic types distinguished on network diagrams | Pass for ch13 and ch14. Lab diagrams show outbound and inbound explicitly |
| Identity concepts distinguished on identity diagrams | Pass after the ch08 rebuild |
| Lab diagrams match deployed resources | Pass. Neither lab diagram contains a component the lab does not create |
| No Microsoft diagram images reproduced | Pass. Links and original diagrams only |
| Ports and protocols verified | Pass. 443, 445, 88, 1688, 3390, 3478 and the 49152 to 65535 range verified against Microsoft documentation |

---

## 5. Standing rule confirmed

New standards apply retrospectively. The audit is repeated across completed work before the next chapter is written, and recorded here as the next numbered audit. This is the second time that rule has been applied, after [Audit 01](audit-01-chapter-contract.md).
