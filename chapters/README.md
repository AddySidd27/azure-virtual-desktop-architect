# AVD Learning Chapters

These 25 chapters explain the architecture before the labs build it. Read them in order if you are new to AVD, or use the topic groups for revision.

| Group | Chapters | Topics |
|---|---|---|
| Fundamentals | 1-6 | AVD service, responsibility boundaries, object model, connection flow, operating systems, licensing, and clients |
| Identity and access | 7-10 | Join models, authentication, Conditional Access, MFA, RBAC, and delegation |
| Networking | 11-14 | Required connectivity, topology, DNS, egress, RDP Shortpath, and performance |
| Host pools and compute | 15-18 | Pool design, management approaches, sizing, placement, lifecycle, and updates |
| Profiles and storage | 19-22 | FSLogix, storage selection, permissions, Cloud Cache, and recovery |
| Images and applications | 23-25 | Golden images, Intune, application delivery, RemoteApp, and App Attach |

Each chapter includes official references, design decisions, failure scenarios, interview questions, and a chapter close for revision.

Technical statements must be checked against Microsoft Learn or the Azure Architecture Center. Time-sensitive statements carry a currency note. See [Validation Status](../VALIDATION-STATUS.md).

Use the [full table of contents](../SUMMARY.md) for direct chapter links.

## Status of Chapters 1 to 12 (17 October 2026)

What "reviewed" means here: each chapter had a technical pass against Microsoft Learn (retrieved 16 October 2026) and a readability pass, both by the same single reviewer, so neither is independent. Nothing in these chapters has been run in Azure. A chapter is not "complete" because it was reviewed; the open items below stay open until they are tested or decided. The evidence is in [REVIEW-REGISTER](../REVIEW-REGISTER.md) and the per-chapter records in `reviews/`.

| Chapter | Labs it links to | Open issues that touch it | Review record |
|---|---|---|---|
| [1 What AVD is](ch01-what-avd-actually-is.md) | none | U3, U4 (Learn conflicts, stated in the text) | [record](../reviews/ch01-review-record.md) |
| [2 Control, management and data plane](ch02-control-plane-management-plane-data-plane.md) | Lab 1 | none | [record](../reviews/ch02-review-record.md) |
| [3 Object model](ch03-avd-object-model.md) | Lab 2 | none | [record](../reviews/ch03-review-record.md) |
| [4 Connection flow](ch04-connection-flow-end-to-end.md) | Lab 3 | none open (U10 closed, queries not run) | [record](../reviews/ch04-review-record.md) |
| [5 OS, multi-session, licensing](ch05-operating-systems-multisession-licensing.md) | Lab 3 | U4, U15 | [record](../reviews/ch05-review-record.md) |
| [6 Clients](ch06-clients-and-the-endpoint-story.md) | Lab 4 | U8, U9, U12 | [record](../reviews/ch06-review-record.md) |
| [7 Identity foundations](ch07-identity-architecture-foundations.md) | Lab 4 | U15 | [record](../reviews/ch07-review-record.md) |
| [8 Authentication flows](ch08-authentication-flows-in-detail.md) | Lab 4 | U15, U18 | [record](../reviews/ch08-review-record.md) |
| [9 Conditional Access and MFA](ch09-conditional-access-mfa-zero-trust.md) | none | none | [record](../reviews/ch09-review-record.md) |
| [10 RBAC and delegation](ch10-rbac-delegation-administrative-model.md) | Labs 2, 3 | U35 (autoscale role scope, Learn conflict) | [record](../reviews/ch10-review-record.md) |
| [11 Network fundamentals](ch11-network-fundamentals-required-connectivity.md) | Labs 3, 4, 8 | U23 (private endpoint NSG behaviour, untested) | [record](../reviews/ch11-review-record.md) |
| [12 Enterprise topologies](ch12-enterprise-topologies-ip-planning.md) | Labs 3, 11 | none open (U33 closed with caveat: deprecated CAF pages) | [record](../reviews/ch12-review-record.md) |

Reading the evidence in the chapters:

- **Learn says** or a linked Learn page: a statement read on Microsoft Learn, with the retrieval date.
- **Judgement** or "Architect's Reality Check": the author's reasoning, not a Microsoft statement and not measured data.
- **Illustrative composite**: a scenario written for this knowledgebase. It is not a customer engagement, and its numbers are assumptions.
- `CURRENCY FLAG`: a time-sensitive statement with a retrieval date. Recheck before relying on it.
- `[VERIFY BEFORE IMPLEMENTATION]` and `[UNTESTED]`: a Learn gap or conflict, or a procedure that has not been run.

Which chapters were freshly re-read against Learn on 17 October 2026, and which were not, is listed in the [chapter source recheck](../reviews/CHAPTER-SOURCE-RECHECK.md).

For hands-on work across Labs 3 to 8 start with the [guided journey](../labs/JOURNEY-LABS-3-8.md). Acronyms are expanded at first use in each chapter and collected in the [glossary](../appendices/glossary.md).
