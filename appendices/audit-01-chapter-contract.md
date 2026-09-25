# Audit 01 - Chapters 1 to 9 against the Chapter Contract

> **Internal development record.** Not required reading. See [Development history](development-history.md) for a summary.

**Date:** August 2026
**Scope:** Every completed chapter before Chapter 10
**Standard applied:** [CHAPTER-CONTRACT.md](../CHAPTER-CONTRACT.md), [STYLE-GUIDE.md](../STYLE-GUIDE.md), [OPERATIONS-AND-TROUBLESHOOTING-STANDARD.md](../OPERATIONS-AND-TROUBLESHOOTING-STANDARD.md)
**Result:** All gaps fixed. Chapters updated in place. Architecture decisions, lab environment, naming conventions and cross chapter links preserved.

---

## 1. What the audit found

The chapter contract, the operations standard and the style guide were written after Chapters 1 to 5 were published. Those chapters were written to an earlier and weaker standard, and the audit confirmed it rather than assuming they were fine.

| Chapter | Production scenarios | Investigation detail | Architect's four questions | Inline diagram | Self-review |
|---|---|---|---|---|---|
| 1 | Missing | Not applicable | Missing | Present | Missing |
| 2 | Missing | Missing | Missing | Present | Missing |
| 3 | Missing | Missing | Missing | Present | Missing |
| 4 | Missing | Missing | Missing | Present | Missing |
| 5 | Missing | Missing | Missing | Present | Missing |
| 6 | Present | Missing | Missing | **Missing** | Present |
| 7 | Present | Missing | Missing | Present | Present |
| 8 | Present | Present | Present | Present | Present |
| 9 | Present | Present | Present | **Missing inline** | Present |

Interview preparation, official Microsoft references and currency flags were already present everywhere.

---

## 2. What was fixed

### Chapter 1 - What Azure Virtual Desktop Actually Is
Added three production decision scenarios: a 60 user firm where AVD is the wrong answer, a manufacturer whose business case omitted storage, telemetry and RDS CALs, and an organisation whose real problem was identity rather than desktops. Added the architect's four questions, adapted for a pre-deployment chapter. Added the self-review table.

### Chapter 2 - Control Plane, Management Plane and Data Plane
Added three production scenarios with full investigation detail: a Monday morning "AVD is down" that was drain mode left on after maintenance, session hosts unavailable after a firewall change diagnosed through event ID 3701, and a data residency question during a regulator review. Added the architect's four questions with escalation evidence requirements. Added the self-review table.

### Chapter 3 - The AVD Object Model
Added three production scenarios: new starters with an empty workspace, a user holding two sessions on one host pool, and a multi-region rollout blocked by the location rule. Each with exact portal paths and PowerShell. Added the architect's four questions, including the reminder that host pool type cannot be changed after creation. Added the self-review table.

### Chapter 4 - The Connection Flow
Added three production scenarios: silent RDP Shortpath loss after a security hardening project, registration failures caused by TLS inspection, and afternoon disconnections traced to density rather than network. Added KQL, event 3701 investigation and the architect's four questions. Added the self-review table.

### Chapter 5 - Operating Systems, Multi-session and Licensing
Added three production scenarios: Intune policies reporting Not applicable on multi-session, an unbudgeted RDS CAL discovered two weeks before go live, and activation failures appearing three weeks after a firewall change. Added the architect's four questions. Added the self-review table.

### Chapter 6 - Clients and the Endpoint Story
Added the missing Mermaid diagram, a client path decision flow with the standard four part explanation. Added three troubleshooting scenarios in the nine step format: devices that missed the deployment wave, a redirection gap affecting one team, and BYOD browser experience problems that cannot be reproduced internally. Added the architect's four questions. Section numbering corrected after the insertion.

### Chapter 7 - Identity Architecture Foundations
Added three troubleshooting scenarios in the nine step format: domain join failures caused by a deallocated domain controller, Entra joined users rejected at sign in because of the missing Virtual Machine User Login role, and profile mount failures caused by the one identity source per storage account rule. Added the architect's four questions.

### Chapter 9 - Conditional Access, MFA and Zero Trust
The diagram existed as a standalone `.mermaid` file but was not inline in the chapter, so it would not render on GitHub or in a blog post. Added inline with the four part explanation.

### Chapter 8
No gaps found. Chapter 8 was the first written to the full standard and it passed unchanged.

---

## 3. Accepted exception

**Chapter 1 has no nine step troubleshooting scenario, and should not have one.** Nothing is deployed at that point in the book. Its three scenarios are design decision scenarios instead, which is the correct format for a chapter about whether to adopt the technology at all. The contract requires scenarios where they are technically relevant, and manufacturing a troubleshooting scenario for a pre-deployment chapter would be filler.

This is recorded here rather than left as an apparent gap.

---

## 4. Consistency check across Chapters 1 to 9

Run after the fixes.

| Check | Result |
|---|---|
| Production scenarios present where relevant | Pass, with the Chapter 1 exception above |
| Investigation steps with exact portal, PowerShell, CLI, KQL and Event Viewer paths | Pass |
| Architect's four questions | Pass, all nine chapters |
| Inline Mermaid diagrams | Pass, all nine chapters |
| Interview preparation | Pass |
| Official Microsoft references | Pass |
| Currency flags where the topic has changed | Pass |
| Self-review tables recording both review passes | Pass |
| Long dash characters | None anywhere in the repository |
| Naming conventions | Unchanged. `rg-avd-*-lab-eus2-01`, `hp-*`, `vm-avdlab-*` used consistently in all new content |
| Lab environment consistency | Unchanged. New scenarios reference the same resource groups, subnets and host names built in Labs 1 to 4 |
| Northwind capstone consistency | Unchanged. 3,200 users, six personas, three sites, same regions |
| Cross chapter links | New content links to existing chapters and labs. No links created to content that does not exist except forward references clearly marked as planned |
| Architecture decisions | Preserved. No design decision was revised during the audit |

---

## 5. Verification approach applied

Every claim involving an Entra application ID, Conditional Access behaviour, sign-in frequency, authentication flow, Microsoft supported limitation, service principal, PowerShell parameter or Azure feature was checked against current Microsoft documentation during the audit rather than carried forward from an earlier chapter.

The two application ID sets used in Chapters 8 and 9 were re-verified during this audit:

- Azure Virtual Desktop, `9cdead84-a844-4324-93f2-b2e6bb768d07`
- Windows Cloud Login, `270efc09-cd0d-444b-a71f-39af4910ec45`
- Microsoft Remote Desktop, `a4a365df-50f1-4397-bc59-1a1564b8bb9c`

The sign-in frequency behaviour differences per application, the restriction that Every time is supported only on Windows Cloud Login, the silent failure of background feed refresh and diagnostics upload after the reauthentication period expires, and the requirement to disable legacy per-user MFA were all confirmed against the current Microsoft pages.

Anything that could not be confirmed carries `[VERIFY BEFORE IMPLEMENTATION]`.

---

## 6. Standing rule going forward

Whenever a new standard is added to this repository, it applies retrospectively. The audit is repeated across completed chapters before the next chapter is written, and the result is recorded in this folder as the next numbered audit.
