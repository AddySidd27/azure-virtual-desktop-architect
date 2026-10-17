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

## Asset verification (diagrams, labs, Terraform)

Diagram, lab, scenario and Terraform checks for Chapters 1 to 12 are recorded per chapter in [reviews/ASSET-VERIFICATION.md](reviews/ASSET-VERIFICATION.md), with the tests actually executed. Open issues are in [reviews/UNRESOLVED-ISSUES.md](reviews/UNRESOLVED-ISSUES.md).

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
| [Chapter 12 - Enterprise Topologies and IP Address Planning](chapters/ch12-enterprise-topologies-ip-planning.md) | Verified with caveats, 2026-10-16 | Reviewed with caveats, 2026-10-16 | [Ch12 record](reviews/ch12-review-record.md) |
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

## Final readiness gate records (2026-10-17)

- [Readiness assessment](reviews/READINESS-ASSESSMENT.md): two independent verdicts (documentation publication, hands-on implementation).
- [Unresolved issues](reviews/UNRESOLVED-ISSUES.md): U1 to U35 with blocking classification.
- [Test plans](reviews/TEST-PLANS.md): U23 to U28 and the Lab 4 to 8 sign-in chain. None executed.
- [Lab dependency matrix](labs/LAB-DEPENDENCY-MATRIX.md): Labs 1 to 10.

## Open follow-up items

| Item | Where it is recorded |
|---|---|
| Host pool type claim repeated in Chapters 3 and 15, not reviewed | [Chapter 1 record](reviews/ch01-review-record.md) |
| Regional Host Pools and session host configuration status in the ADR and Labs 11 to 20 may be out of date | [Chapter 1 record](reviews/ch01-review-record.md) |
| `SOURCE-VERIFICATION.md` lacks rows for Windows 365, AVD Hybrid, Azure Local, managed identity, regional host pools and the FAQ | [Chapter 1 record](reviews/ch01-review-record.md) |

## Close-out pass, 2026-10-16

Chapters 1 to 12 were re-reviewed against 34 tracked issues. 21 are closed (U29 to U32 and U34 in text or code only, none executed), 13 remain open: U3, U4, U9 (Learn conflicts), U8, U12, U15, U18 (evidence unavailable or undocumented), U23 to U28 (not tested). Terraform was not run locally. GitHub CI passed `fmt`, `init -backend=false` and `validate` on `main` at `86e083d`, which does not cover this branch's Terraform edits (see U25 and [TERRAFORM-VALIDATION](TERRAFORM-VALIDATION.md)); `plan` and `apply` were never run. Chapters 1 to 12 are **not** marked complete. See [UNRESOLVED-ISSUES](reviews/UNRESOLVED-ISSUES.md) and [ASSET-VERIFICATION](reviews/ASSET-VERIFICATION.md).


## Portfolio release preparation, 17 October 2026

- Added [Labs 3 to 8 guided journey](labs/JOURNEY-LABS-3-8.md): tenant, identity, DNS, interactive DC access, stage gates, cost and teardown. Not executed.
- Lab 3 to 8 edits: prerequisites, U23 and U24 wording, DNS forwarder timeouts in Lab 4 Step 5b, the Lab 5 Step 5 SYSTEM-context limitation, Lab 6 and Lab 8 step references.
- New U36 (no documented route to an interactive DC session). U35 re-confirmed against two Learn pages.
- U25 corrected: CI had already validated Terraform on `main`. `plan` and `apply` still never run; this branch's 12 changed Terraform files not CI-checked. Added `tools/terraform-validate-all.sh` (syntax-checked only).
- Added [DECISIONS-REQUIRED](reviews/DECISIONS-REQUIRED.md) for items needing approval. README now carries a status notice and an evidence legend.

## Chapters 1 to 12 editorial pass, 17 October 2026

Single reviewer, not independent. Gap analysis of all twelve chapters found them structurally complete, so changes were limited to evidence and clarity:

- 23 unsupported frequency or experience claims ("almost always", "most common", "most teams never learn") reworded or marked as judgement.
- Every scenario or example section now states that it is an illustrative composite. Every Architect's Reality Check states that it is engineering judgement, not measured data.
- About 70 first-use acronym expansions added where the chapter never expanded the term. Glossary extended.
- Two sections re-read against Learn (Chapter 4 Shortpath, Chapter 8 SSO) with corrections recorded in their review records. Inline source links added to Chapter 1, 4 and 8.
- `chapters/README.md` now has a status table for Chapters 1 to 12 with labs and open issues.

Mermaid blocks in Chapters 1 to 12 (8) render without error with mmdc and the Playwright Chromium. Rendered output was not visually inspected in this pass. No issue was closed. U23 to U28, U35 and U36 are unchanged.

CI on `d638745` (dispatched manually on the pushed branch, 17 October 2026, runs report SHA `d6387458403df4c81f90bd2405c134cd3940b036`): Terraform structural check 39009750006, Repository check 39009751327, Markdown link check 39009752483, all success. Earlier: CI on `b1ef26d` (dispatched manually on the pushed branch, 17 October 2026, runs report SHA `b1ef26d95f4a969c72878ba74b9e9c6b269c856e`): Terraform structural check 39009291886, Repository check 39009293198, Markdown link check 39009294575, all success. Earlier: CI on `c123676` (dispatched manually on the pushed branch, 17 October 2026, runs report SHA `c123676f4f6a0a93651c74e7f69f3cf3c59405ad`): Terraform structural check 39008585420, Repository check 39008586968, Markdown link check 39008588332, all success. Earlier: CI on `b95af3f`: Terraform structural check 39007931570, Repository check 39007932741, Markdown link check 39007933846, all success. Structure, links, formatting and schema validation only. It does not validate chapter accuracy, Azure behaviour or lab execution.

## Source recheck and issue reassessment, 17 October 2026

Single reviewer. Full Learn re-reads: Chapter 9 (set-up-mfa) and Chapter 11 (required FQDNs), plus Chapter 4 and 8 earlier the same day. Two corrections: a stale app row in the Chapter 9 sign-in frequency table, and a service tag error in Chapter 11 and Lab 3. Chapters 1, 2, 3, 5, 6 and 12 were not re-read; see [CHAPTER-SOURCE-RECHECK](reviews/CHAPTER-SOURCE-RECHECK.md). Issues U23, U24, U26, U27, U28, U35 and U36 reassessed with acceptance criteria in [OPEN-ISSUES-REASSESSMENT](reviews/OPEN-ISSUES-REASSESSMENT.md); none closed. Lab 1 provider note corrected from a static read of resource types. Lab 3 and Lab 7 troubleshooting extended. README evidence boundary for the author's separate projects added.
