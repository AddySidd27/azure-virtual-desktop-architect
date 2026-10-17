# Review Register

This register is the only place where chapter reviews are recorded. A pass that is not listed here has not been completed.

The chapter contract requires two separate passes for every chapter (see [Chapter Contract](CHAPTER-CONTRACT.md), section 3):

- **Technical verification** checks the chapter's claims against current official Microsoft documentation.
- **Readability and architecture** checks the chapter as a reader would meet it, and checks that the design advice holds together.

## Status values

| Status | Meaning |
|---|---|
| Not Reviewed | No pass has been completed. This is the default for every chapter. |
| In Progress | A pass has started but is not finished. |
| Verified | Technical pass only. Every material claim was checked against a cited source and nothing is open. |
| Verified with caveats | Technical pass only. Checked, but some claims are Unverified, in Conflict, or are author judgement. The evidence record lists them. |
| Reviewed | Readability and architecture pass only. All checks done and nothing is open. |
| Reviewed with caveats | Readability and architecture pass only. Some checks were not done or findings are still open. The evidence record lists them. |

## What a completed pass must record

Every completed pass needs all of these in its evidence record. If one is missing, the pass is not complete.

1. The review date.
2. The reviewer or process, and whether it was independent of the author and of the other pass. If one reviewer or process did both passes, say so.
3. The outcome, using the status values above.
4. Supporting evidence: for the technical pass, the page title, link and retrieval date of each source used, and what each claim was checked against.
5. The commit of the text that was reviewed.

## Rules

- No chapter is marked reviewed until the pass has actually been done. Do not copy statuses from older records.
- Self-review tables that older versions of the chapters carried (removed in commit `fc4fd0e`) are not counted as evidence. They did not record sources, dates or reviewers.
- A claim that cannot be checked is recorded as Unverified, with the next action. It is not silently accepted.
- A chapter is publication-ready only when both passes are complete, neither has open caveats, and the pass that checks claims names its sources. This register does not yet mark any chapter publication-ready.
- When a chapter changes materially after a review, add a new row to the evidence record and set the status back to In Progress until the changed text is re-checked.
- Learn pages change. Dated statements (GA dates, retirement dates, versions) carry a `CURRENCY FLAG` in the chapter, and the evidence record gives the retrieval date.

## Register

| Chapter | Technical verification | Readability and architecture | Evidence |
|---|---|---|---|
| [Chapter 1 - What Azure Virtual Desktop Actually Is (and What It Is Not)](chapters/ch01-what-avd-actually-is.md) | Verified with caveats, 2026-10-16 | Reviewed with caveats, 2026-10-16 | [Chapter 1 record](reviews/ch01-review-record.md) |
| [Chapter 2 - The Control Plane, Management Plane and Data Plane](chapters/ch02-control-plane-management-plane-data-plane.md) | Verified with caveats, 2026-10-16 | Reviewed with caveats, 2026-10-16 | [Ch2 record](reviews/ch02-review-record.md) |
| [Chapter 3 - The AVD Object Model: Host Pools, Application Groups and Workspaces](chapters/ch03-avd-object-model.md) | Verified with caveats, 2026-10-16 | Reviewed with caveats, 2026-10-16 | [Ch3 record](reviews/ch03-review-record.md) |
| [Chapter 4 - The Connection Flow, End to End](chapters/ch04-connection-flow-end-to-end.md) | Verified with caveats, 2026-10-16 | Reviewed with caveats, 2026-10-16 | [Ch4 record](reviews/ch04-review-record.md) |
| [Chapter 5 - Operating Systems, Multi-session and Licensing](chapters/ch05-operating-systems-multisession-licensing.md) | Verified with caveats, 2026-10-16 | Reviewed with caveats, 2026-10-16 | [Ch5 record](reviews/ch05-review-record.md) |
| [Chapter 6 - Clients and the Endpoint Story](chapters/ch06-clients-and-the-endpoint-story.md) | Verified with caveats, 2026-10-16 | Reviewed with caveats, 2026-10-16 | [Ch6 record](reviews/ch06-review-record.md) |
| [Chapter 7 - Identity Architecture Foundations](chapters/ch07-identity-architecture-foundations.md) | Verified with caveats, 2026-10-16 | Reviewed with caveats, 2026-10-16 | [Ch7 record](reviews/ch07-review-record.md) |
| [Chapter 8 - Authentication Flows in Detail](chapters/ch08-authentication-flows-in-detail.md) | Verified with caveats, 2026-10-16 | Reviewed with caveats, 2026-10-16 | [Ch8 record](reviews/ch08-review-record.md) |
| [Chapter 9 - Conditional Access, MFA and Zero Trust Access](chapters/ch09-conditional-access-mfa-zero-trust.md) | Verified with caveats, 2026-10-16 | Reviewed with caveats, 2026-10-16 | [Ch9 record](reviews/ch09-review-record.md) |
| [Chapter 10 - RBAC, Delegation and the Administrative Model](chapters/ch10-rbac-delegation-administrative-model.md) | Verified with caveats, 2026-10-16 | Reviewed with caveats, 2026-10-16 | [Ch10 record](reviews/ch10-review-record.md) |
| [Chapter 11 - Network Fundamentals and Required Connectivity](chapters/ch11-network-fundamentals-required-connectivity.md) | Verified with caveats, 2026-10-16 | Reviewed with caveats, 2026-10-16 | [Ch11 record](reviews/ch11-review-record.md) |
| [Chapter 12 - Enterprise Topologies and IP Address Planning](chapters/ch12-enterprise-topologies-ip-planning.md) | Not Reviewed | Not Reviewed | None |
| [Chapter 13 - Hybrid Connectivity and Egress Control](chapters/ch13-hybrid-connectivity-egress-control.md) | Not Reviewed | Not Reviewed | None |
| [Chapter 14 - Protocol Optimisation and Network Performance](chapters/ch14-protocol-optimisation-network-performance.md) | Not Reviewed | Not Reviewed | None |
| [Chapter 15 - Host Pool Design Decisions](chapters/ch15-host-pool-design-decisions.md) | Verified with caveats, 2026-10-16 | Reviewed with caveats, 2026-10-16 | [Ch15 record](reviews/ch15-review-record.md) |
| [Chapter 16 - Automated Host Pools and Session Host Configuration](chapters/ch16-automated-host-pools-session-host-configuration.md) | Not Reviewed | Not Reviewed | None |
| [Chapter 17 - Session Host Sizing and Compute Selection](chapters/ch17-session-host-sizing-compute-selection.md) | Not Reviewed | Not Reviewed | None |
| [Chapter 18 - Session Host Lifecycle and Hybrid Session Hosts](chapters/ch18-session-host-lifecycle-hybrid.md) | Not Reviewed | Not Reviewed | None |
| [Chapter 19 - Why Profiles Are the Number One Cause of AVD Failure](chapters/ch19-why-profiles-cause-avd-failure.md) | Not Reviewed | Not Reviewed | None |
| [Chapter 20 - Profile Storage Architecture](chapters/ch20-profile-storage-architecture.md) | Not Reviewed | Not Reviewed | None |
| [Chapter 21 - FSLogix Production Implementation](chapters/ch21-fslogix-production-implementation.md) | Not Reviewed | Not Reviewed | None |
| [Chapter 22 - Profile Operations, Failure and Recovery](chapters/ch22-profile-operations-failure-recovery.md) | Not Reviewed | Not Reviewed | None |
| [Chapter 23 - Golden Image Engineering](chapters/ch23-golden-image-engineering.md) | Not Reviewed | Not Reviewed | None |
| [Chapter 24 - Intune and AVD: Endpoint Management Architecture](chapters/ch24-intune-and-avd-endpoint-management.md) | Not Reviewed | Not Reviewed | None |
| [Chapter 25 - Application Delivery Strategy and RemoteApp Design](chapters/ch25-application-delivery-remoteapp-design.md) | Not Reviewed | Not Reviewed | None |

Chapter 1 was reviewed by one assistant doing both passes in sequence, so neither pass is an independent review. The limitation is recorded in the evidence record.

## Open follow-up items

| Item | Where it is recorded |
|---|---|
| Host pool type claim repeated in Chapters 3 and 15, not reviewed | [Chapter 1 record](reviews/ch01-review-record.md) |
| Regional Host Pools and session host configuration status in the ADR and Labs 11 to 20 may be out of date | [Chapter 1 record](reviews/ch01-review-record.md) |
| `SOURCE-VERIFICATION.md` lacks rows for Windows 365, AVD Hybrid, Azure Local, managed identity, regional host pools and the FAQ | [Chapter 1 record](reviews/ch01-review-record.md) |
