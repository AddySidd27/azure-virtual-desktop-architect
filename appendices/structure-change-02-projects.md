# Structure Change 02 - Real-World Projects Expanded

**Date:** August 2026
**Status:** Applied
**Reason:** The original plan compressed 15 scenarios into 3 chapters. That is a case study format, not an engagement format, and it conflicts with the purpose of the projects.

---

## 1. What was planned

Part XI was three chapters, each covering five scenarios:

- Chapter 39, Scenarios 1 to 5
- Chapter 40, Scenarios 6 to 10
- Chapter 41, Scenarios 11 to 15

Five scenarios per chapter means roughly two thousand words each. That is enough to describe an architecture and nowhere near enough to design, build, test, operate and defend one.

---

## 2. What is being built instead

**Fifteen standalone projects**, each a complete engagement document following the [project standard](../PROJECT-STANDARD.md) with all thirty required sections.

Each project lives in `scenarios/` as its own file with its own diagram and, where relevant, its own Terraform.

| # | Project | Defining challenge |
|---|---|---|
| 01 | SMB, cost sensitive | Making the economics work at small scale, and knowing when to say no |
| 02 | 500 to 1,000 user enterprise | The first real persona split and the first real sizing exercise |
| 03 | 3,000+ user global enterprise | Governance, multi-region and operating model at scale |
| 04 | Hybrid Active Directory | Domain dependency, GPO coexistence, DC placement |
| 05 | Entra-only, cloud native | No domain controller, Entra Kerberos, and what that rules out |
| 06 | BYOD and remote workforce | Unmanaged devices, session controls, no endpoint management |
| 07 | Call centre, high density | Shift start storms, density economics, audio quality |
| 08 | Developer and engineering | Local admin, unpredictable load, personal pools |
| 09 | GPU and CAD | Vendor constraints, capacity availability, cost defence |
| 10 | RemoteApp and line of business | Application-only delivery, per-device licensing, partner access |
| 11 | Highly secure and regulated | Private egress, evidence for audit, control enforcement |
| 12 | Citrix to AVD migration | Brownfield, parallel run, application assessment, user migration |
| 13 | Multi-region architecture | Latency, workspace per region, storage placement |
| 14 | Disaster recovery | RTO and RPO derivation, what is recovered and what is rebuilt |
| 15 | Production troubleshooting and incident recovery | A live incident worked end to end under time pressure |

The list follows the fifteen situations requested, which differs slightly from the original scenario list. Personal desktop estate is now covered inside Project 08. A dedicated Citrix migration project and a live incident recovery project have been added, because both are common real engagements and neither was represented.

---

## 3. Effect on the book structure

| Before | After |
|---|---|
| 54 numbered chapters, including 3 scenario chapters | 51 numbered chapters plus 15 project documents |
| 15 scenarios as sections inside chapters | 15 projects as standalone engagement documents |
| Roughly 2,000 words per scenario | Roughly 8,000 to 12,000 words per project |

**Chapter numbering is not changed.** Chapters 39 to 41 are retired as containers rather than renumbered, so every existing cross reference to Chapters 42 and above still resolves. Part XI is now the project series.

Total book units go from 54 to 66. This is an increase in scope, taken deliberately, because the instruction was explicit that project depth takes priority over chapter count.

---

## 4. What did not change

- The remaining 51 chapters and their numbering
- The 20 labs and their dependency chain
- Northwind Global Manufacturing, which remains reserved for the Part XVIII capstone and is not reused as a project customer
- Naming conventions, terminology, diagram conventions and Terraform patterns
- The chapter contract, operations standard and diagram standard, which projects also follow

---

## 5. Build order

Projects are written after the concept chapters they depend on. A project cannot teach a design decision the reader has no framework for.

| Wave | Projects | Depends on |
|---|---|---|
| A | 01, 02, 04, 05 | Chapters 1 to 25, already written |
| B | 06, 07, 08, 10 | Adds Chapters 27 to 29 security |
| C | 03, 09, 11, 13 | Adds Chapters 30 to 35 monitoring, scaling and cost |
| D | 12, 14, 15 | Adds Chapters 36 to 38 HA and DR, and 45 to 47 troubleshooting |

Projects in Wave A can be written now. The rest follow their dependencies, and the order is recorded here so the sequence is deliberate rather than convenient.
