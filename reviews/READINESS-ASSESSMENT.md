# Readiness assessment, 2026-10-17

> **Technical baseline:** Microsoft Learn as retrieved 16 and 17 October 2026 (see [Review register](../REVIEW-REGISTER.md)). Single reviewer, no independent pass. Everything here is local to the working tree. Nothing was pushed, merged or deployed. This is not Microsoft endorsement, MVP approval or certification.

Two verdicts are given separately because they answer different questions. A document set can be fit to publish and still be unsafe to follow step by step.

## Evidence levels used

| Level | Meaning | Achieved in this repo? |
|---|---|---|
| Official-source verified | Claim read on Microsoft Learn, URL and date recorded | Yes, Chapters 1 to 12 and 15 (caveats listed) |
| Static repo checked | Files read, cross-checked, greps run | Yes |
| Syntax parsed | HCL parsed with python-hcl2, XML parsed, Mermaid rendered | Yes (see Test results in the final report) |
| Terraform validated | `terraform fmt -check`, `init -backend=false`, `validate` | **Yes in GitHub CI on `main` at `86e083d` (34 modules, Terraform 1.16.6). Also on this branch at `6a11662` (dispatch run 39007047474, including its 12 changed Terraform files). Not run locally (U25).** `plan` and `apply` were never run |
| Command executed | Azure CLI, PowerShell, KQL run | **No** |
| Azure behaviour tested | Behaviour observed in a subscription | **No** |
| End-to-end tested | Lab chain run to a user sign-in | **No** |
| Independently reviewed | Second reviewer | **No** |

## A. Documentation publication readiness

**Verdict: CONDITIONAL for Chapters 1 to 12 and 15 as a reviewed set. NO for the knowledgebase as a whole.**

Evidence for:
- Chapters 1 to 12 and 15 carry a technical pass and a readability pass, each "with caveats", with Learn URLs and retrieval dates in `reviews/chNN-review-record.md`.
- Every open issue is flagged in the text with a marker and tracked in [UNRESOLVED-ISSUES](UNRESOLVED-ISSUES.md) with a blocking classification. No open issue is classed as blocking publication of a reviewed chapter.
- Labs 1 to 10 have a [dependency matrix](../labs/LAB-DEPENDENCY-MATRIX.md) stating what is and is not proven.

Blocking issues for a whole-repository publication:
1. Twelve of 25 chapters (13, 14, 16 to 25 excluding 15) are `Not Reviewed` in the register. Publishing them implies a review that did not happen.
2. No pass was independent (single reviewer).
3. Terraform schema validation passed in CI on `main` and on this branch at `6a11662`, but `plan` and `apply` were never run (U25). Any "this deploys" implication is unsupported.

Non-blocking caveats: U3, U4, U8, U9, U12, U15, U18 and U35 are Learn conflicts or gaps that the text states plainly. Two CAF pages cited in Ch12 are deprecated and will disappear after 2026-10-30 (U33).

Actions to reach YES:
1. Review Chapters 13, 14, 16 to 25 (technical and readability), or remove or mark them as drafts in the published navigation.
2. Obtain one independent review of Chapters 1 to 12 and 15.
3. Done for `6a11662`: CI passed (see TERRAFORM-VALIDATION.md). Re-run CI after any further Terraform change.
4. Re-check every dated claim (retirements, GA labels) at publication time.

## B. Hands-on implementation readiness

**Verdict: NO.**

Evidence against:
- No lab, command, script or query has been executed. All are `[UNTESTED]`.
- Terraform `plan` and `apply` were never run on any module. `fmt`, `init -backend=false` and `validate` passed in CI on `main` and on this branch at `6a11662` (U25).
- The Lab 4 to 8 sign-in chain needs a test Entra tenant with a verified domain and Entra Cloud Sync. The author could not provision it (U30, U32).
- Some required controls are manual and outside Terraform: Start VM on Connect and autoscale role assignments (U28), VNet DNS (U24).
- `nsg-storage` does not enforce anything on the private endpoint subnet by default (U23).

Blocking issues (implementation): U25, U23 (if the reader relies on the NSG), U28 (for Start VM on Connect and autoscale), U15 (for session-host-configuration Entra-joined pools only). Conditional: U24, U26, U27.

Non-blocking caveats: U35 (subscription scope satisfies both Learn pages), the image SKU string `win11-25h2-avd` is not checked against a live image list (U31).

Actions to reach CONDITIONAL:
1. Run `plan` per layer in a disposable subscription (U25). CI schema validation already passed.
2. Execute [TEST-PLANS](TEST-PLANS.md) for U23, U26, U27 in a disposable subscription.
3. Decide, with approval, whether to add the U28 role assignments to Terraform.

Actions to reach YES: run Labs 1 to 8 end to end in a test tenant and record real output, then Labs 9 and 10, then clean up.

## Prioritised remaining actions

| Priority | Action | Needs approval or access |
|---|---|---|
| P1 | Terraform fmt, init, validate, plan on all modules | Registry access |
| P1 | Execute test plans U23 to U28 and E2E-1 | Azure subscription, cost |
| P1 | Review or hold back unreviewed chapters | None |
| P2 | Decide on U28 role assignments in Terraform | Explicit approval |
| P2 | Decide on the private endpoint policy argument in Lab 3 (U23) after verifying the provider argument | Provider docs, approval to change module |
| P2 | Independent review | Second reviewer |
| P3 | Fill small gaps found by the lab scan (variables in Labs 1, 3, 6; tools in Labs 3, 7, 10; security note in Lab 2) | None |
| P3 | Re-check Learn conflicts U3, U4, U9, U35 before release | None |

## Newly discovered risks (this pass)

1. NSG bypass on private endpoints (U23): the lab suggests a control that is not active by default.
2. Autoscale role scope disagreement within Learn (U35).
3. Lab 3 re-apply may revert VNet DNS set in Lab 4 (U24, unverified).
4. Lab 4 Step 7 depends on a tenant and verified domain not otherwise listed as a cost or prerequisite up front.
5. The lab scan is keyword-based. It is not a substitute for a reader walking the labs.

## Update, 17 October 2026 (Chapters 1 to 12 editorial pass)

Publication verdict is unchanged: CONDITIONAL. The pass removed unsupported frequency claims, labelled illustrative scenarios and judgement sections, expanded acronyms at first use, and re-read the Chapter 4 Shortpath and Chapter 8 SSO sections against Learn. It did not add independent review and did not close any issue. Implementation verdict is unchanged: NO.

CI note: manually dispatched GitHub CI passed on `6a11662` (runs 39007047474, 39007048778, 39007050303) and again on `b95af3f` (runs 39007931570, 39007932741, 39007933846), the commit that includes the Chapters 1 to 12 edits. CI also passed on `c123676` (runs 39008585420, 39008586968, 39008588332, each reporting that SHA). Commits after `c123676` have not had a CI run. A later source pass (Chapters 1 to 3, 5, 6 and 12, see [CHAPTER-SOURCE-RECHECK](CHAPTER-SOURCE-RECHECK.md)) changed chapter text only and closed no issue. Publication verdict stays CONDITIONAL and implementation verdict stays NO.
