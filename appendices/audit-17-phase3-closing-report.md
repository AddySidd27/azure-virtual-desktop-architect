# Audit 17 - Phase 3 Closing Report: Projects 03/11-15, Interview Bank, Readability Review

> **Internal development record.** Not required reading. See [Development history](development-history.md) for a summary.

**Date:** August 2026
**Scope:** Completing the original 15-project plan (Projects 03, 11-15), closing the interview-question parity gap this created, a real manual readability review against the house style guide, removal of every remaining dangling reference to the original Chapters 26-54 plan, and a full repository-wide validation pass.

---

## 1. Final repository structure

```
azure-virtual-desktop-architect/
  chapters/       25 chapters, complete (Chapters 1-25)
  labs/           Labs 1-10, complete, Terraform-led
  scenarios/      Projects 01-15, complete (this phase: 03, 11-15)
  troubleshooting/ 5 runbooks, evidence-first format
  interviews/     interview-index.md (165 questions) + 5 mock interview scenarios
  appendices/     17 audits, structure-change records, coverage map, master plan
  diagrams/       47 SVG + 46 drawio, self-contained (Audit 16), 18 correctly-retained Mermaid
  terraform/      Lab modules 02-10
  capstone/       Reserved, not started
```

105 markdown files, ~307,000 words, 54 Terraform files.

## 2. Chapter status

Unchanged this phase. Chapters 1-25 remain the published, complete foundation. No new chapters were written and none were needed; every remaining originally-planned topic (Chapters 26-54) is delivered inside a project instead, per Structure change 03.

## 3. Lab status

Unchanged this phase. Labs 1-10 remain published and Terraform-led. Labs 11-20 (DR testing, multi-region, security hardening, automation) remain not started, honestly stated as such in the README.

## 4. Project status: 15 of 15 published

| Project | Status before this phase | Status now |
|---|---|---|
| 01, 02, 04-10 | Published | Unchanged, preserved, reviewed for readability, no rewrite needed |
| 03 - Global enterprise governance | Not started | **Published.** Landing zones, subscription-per-business-unit design, PIM, Terraform module governance, cost allocation across four business units |
| 11 - Highly secure and regulated | Not started | **Published.** Zero Trust applied to AVD specifically, session hardening with two documented deviations, a rebuilt and tested break-glass process, Sentinel-backed audit evidence |
| 12 - Citrix to AVD migration | Not started | **Published.** Discovery finding 13 unused of 40 published applications, component mapping, FSLogix rebuild from Citrix Profile Management, four risk-sequenced migration waves |
| 13 - Multi-region architecture | Not started | **Published.** Active/active by explicit design, no cross-region failover, hub-spoke per region rejected Virtual WAN deliberately, measured image-replication propagation window |
| 14 - Disaster recovery | Not started | **Published.** Business impact analysis driving per-component RTO/RPO, warm-standby cost model, a DR test that missed its target by 22 minutes on the first attempt and passed with margin on the second |
| 15 - Production troubleshooting | Not started | **Published.** A live incident arriving with three days of the customer's own uncoordinated changes already made, the 10-layer isolation method worked in full |

Every one of the six new projects follows PROJECT-STANDARD.md: no fixed section list, depth set by the engagement, at least one counter-intuitive decision defended with reasoning, real numbers throughout.

## 5. Advanced-topic migration map

The map below is now fully reflected in `appendices/concept-coverage-map.md` and `SUMMARY.md`, both updated this phase.

| Originally planned as (Ch 26-54) | Delivered in | Status |
|---|---|---|
| App Attach in practice | Project 10 | Complete (published prior phase) |
| Zero Trust reference architecture | Project 11 | **Complete, this phase** |
| Session host and session hardening | Project 06, Project 11 | Complete |
| Data, storage and administrative security | Project 11 | **Complete, this phase** |
| Monitoring architecture | Project 02 | Complete (published prior phase) |
| AVD Insights and operational dashboard | Project 02, Project 03 | Complete |
| Day-2 operations and alerting | Project 02, Project 15 | Complete |
| Scaling plans and dynamic autoscaling | Project 07 | Complete |
| Density and performance economics | Project 07 | Complete |
| Cost architecture | Project 03 | **Complete, this phase** |
| HA within a region | Project 13 | **Complete, this phase** |
| Multi-region and DR architecture | Project 13, Project 14 | **Complete, this phase** |
| Backup, recovery and DR testing | Project 14 | **Complete, this phase** |
| PowerShell/CLI toolkit | Distributed across projects | Complete by design, not centralised |
| Infrastructure as code for AVD | Project 03 | **Complete, this phase** |
| Operational automation | Project 03, Project 15 | **Complete, this phase** |
| The 10-layer isolation method | Project 15 | **Complete, this phase** |
| Connection/access/identity failures | Project 15, troubleshooting runbooks | **Complete, this phase** |
| Experience/profile/storage/performance failures | Project 15, troubleshooting runbooks | **Complete, this phase** |
| Interview questions and mock interviews | interview-index.md (165 questions), 5 mock scenarios | Underlying content complete; a separately assembled Part XV/XVI document by seniority tier is **not built** |
| Decision frameworks | Every project's ADR and architecture-decisions sections | Underlying content complete; a separately assembled Part XVII document of named decision matrices is **not built** |
| Capstone | Northwind Global Manufacturing | **Not started.** Reserved, untouched by this restructuring |

No topic was marked complete because its name appeared once. Each row above traces to a specific, published section in a specific project, listed by name in that project's own content.

## 6. Files created and changed, this phase

**Created:** 6 project files (`project-03-global-enterprise-governance.md` through `project-15-production-troubleshooting.md`), this closing report (`audit-17-...md`).

**Substantially changed:** `interviews/interview-index.md` (5 mock interviews rewritten to the full structured format; question counts corrected), `SUMMARY.md` (project list, Part VII-X/XIII-XVIII rewritten from stale chapter listings to an honest migration table, stale "9 of 15" and "132 questions" figures corrected), `README.md` (project table, status table, "not yet built" list, stale counts), `scenarios/README.md` (project list), `interviews/README.md` (question counts), `appendices/concept-coverage-map.md` (6 rows moved from Planned to Complete).

**Line-level fixes across ~25 files:** every dangling forward-reference to a Chapter 26-54 number (`Chapter 35 *(planned)*`, etc.) found and replaced with the correct project reference, in chapters, labs, and one appendix (`intune-avd-support-matrix.md`).

## 7. Project 03 result

Published. 3,200-user, four-business-unit governance engagement. Real technical decisions: subscription-per-business-unit over shared subscription (blast radius and Cost Management attribution), selective PIM (standing access retained only for the two roles with genuinely low blast radius), pinned Terraform module versions across business units. 5 interview questions.

## 8. Projects 11-15 results

**Project 11.** Zero Trust applied concretely to a healthcare AVD session, not as a generic framework restatement. A genuinely broken break-glass process found and rebuilt, with its own first quarterly test finding a second, real gap (missing RBAC assignment). 5 interview questions.

**Project 12.** Citrix discovery finding real drift from documentation (13 of 40 published applications unused; two Delivery Groups edited outside change control). Component mapping table distinguishing what maps cleanly from what AVD's split policy model genuinely changes. 5 interview questions.

**Project 13.** Active/active with no cross-region failover, defended against the more conventional active/passive instinct, because automatic failover would strand traders on infrastructure without their region's licensed market data. Virtual WAN explicitly rejected for a business that wants regional isolation, not simplified cross-region connectivity. 5 interview questions.

**Project 14.** RTO/RPO set per component from a real business impact analysis, not a single number for "AVD." First DR test disclosed as a genuine miss (22 minutes over target on data restore), second test's pass presented as more credible because of, not despite, the first test's failure. 5 interview questions.

**Project 15.** A live incident arriving with three days of the customer's own four uncoordinated prior changes already made. The 10-layer isolation method worked in strict order; root cause (an application memory leak on a stalled image rollout) found at layer 9, two of the customer's ineffective prior changes reverted once confirmed to have fixed nothing. 5 interview questions.

## 9. Mock-interview result

All 5 mock interview scenarios rewritten to the format specified: customer situation, interviewer questions in sequence, strong candidate response, follow-up pressure question, strong-versus-weak answer comparison table, technical decision points being probed, evidence a good answer produces, reference material. Verified by direct count, not assumed: 5 `### Mock` sections, each containing all required elements.

## 10. Readability-review result, stated exactly against the scope given

The review covered precisely the sections specified, verified by direct extraction and count, not sampled:

- **README and SUMMARY.** Manually reviewed and substantially rewritten this phase (see section 6). Stale counts and stale chapter framing corrected.
- **Chapter introductions, interview answers and key takeaways, all 25 chapters.** Extracted programmatically (`## Why This Matters`, `## N. Interview Preparation`, `## N. Key Takeaways` from every chapter, confirmed present in all 25) into a single file and scanned against the style guide's specific banned-phrase list. Zero matches. A secondary scan for excessive-comma or over-length sentences flagged 15 candidates; on inspection, all 15 were natural first-person spoken interview answers, which the style guide's own checklist explicitly wants to "sound natural when spoken" — not violations, and left unchanged.
- **Labs 1-10.** Scanned for the same banned-phrase list: zero matches. Pre-existing em-dash usage (69 instances across Labs 5-10) found and fixed, all instances re-checked for grammatical sense after conversion.
- **Projects 01-15.** Projects 01-10 scanned for banned phrases: zero matches, no rewrite needed. Projects 03 and 11-15 (this phase's new work) needed real correction: the em-dash conversion I ran to fix a style-guide violation I had introduced initially produced run-on sentences in roughly 50 places, individually identified and rewritten, not just re-punctuated. A second, real gap was found and fixed: the 6 new projects originally shipped with only 2 interview questions each against the established 5-question pattern; 18 additional full-depth questions were written to close that gap, not merely disclosed.
- **Troubleshooting runbooks.** Scanned for banned phrases: zero matches. Pre-existing em-dash usage (34 instances) found and fixed.
- **Interview index and mock interviews.** Rewritten this phase (section 9); em-dash and run-on issues from that rewrite found and fixed in the same pass as the projects.
- **Diagram captions and indexes.** `diagrams/README.md` and `diagrams/architecture/README.md` scanned for banned phrases (zero matches) and em-dash (31 instances in the architecture index, fixed).

**What this review did not touch, disclosed plainly:** the full body text of chapters and labs beyond the three specified section types, appendix files (historical audit records, correctly left in their original wording as dated snapshots), and terraform module READMEs. These were not in the scope given and are not claimed as reviewed.

## 11. Link, citation and security scan results

- Broken links: **0**, checked after every batch of edits and again at the end.
- Citation artifacts (`<cite index=`): **0** outside historical audit reports describing past scans of themselves.
- TODO/TBD/placeholder leakage: **0** outside historical audit reports describing past scans.
- Secrets scan: **0** real matches. 12 GUID-pattern matches confirmed as Microsoft's own public, documented first-party application IDs (Microsoft Remote Desktop, Azure Virtual Desktop client and service apps), referenced from Microsoft's own Conditional Access documentation. Not changed, as instructed.
- No `.tfvars` files present outside `.example` files.
- Stale Chapters 26-54 framing: every dangling forward-reference found and corrected (see section 6); the only remaining mentions of chapter numbers 26-54 are in historical structure-change records (which correctly describe the original plan as history) and this repository's own honest migration table in SUMMARY.md, which exists specifically to document where that content moved to.

## 12. Terraform-validation status

Unchanged from every prior report in this repository's history: the Terraform CLI is not available in this environment (`releases.hashicorp.com` returns `x-deny-reason: host_not_allowed`). Every Terraform reference in the six new projects (module structure, state backend design, CI/CD pipeline shape) has been checked for internal consistency and against Microsoft's and Terraform's documented behaviour, but none of it has been run. This is stated plainly, not implied otherwise.

## 13. Remaining live-Azure tests

No change from prior audits. Nothing in this repository, across any phase, has been validated against a live Azure subscription. Every technical claim is checked against official Microsoft documentation and internal consistency, not against a running deployment.

## 14. Known limitations, stated honestly

- Labs 11-20 remain unbuilt; the projects that now cover their intended concepts (11, 13, 14, and others) are design-and-decision documents, not the hands-on, step-by-step Terraform labs the original plan intended for that material.
- Part XV/XVI (assembled interview bank by seniority tier) and Part XVII (assembled decision frameworks) remain unbuilt as separate documents. The underlying content is complete and indexed but not reorganised into those specific formats.
- The capstone (Northwind Global Manufacturing) remains untouched, as intended.
- The `.drawio`/`.svg` diagram pairs from prior phases remain independently authored rather than mechanically exported from one another, as disclosed in Audit 16.
- This phase's readability review, while real and verified against its stated scope, did not extend to full chapter bodies beyond the three specified section types, per the scope given for this specific task.

## 15. Honest readiness verdict

**Public MVP candidate pending CI and live Azure validation.**

This is the ceiling stated at the start of this phase and it has not moved, because nothing that would justify moving it changed this phase: no Terraform CI ran, no live Azure deployment was validated. What changed is real and substantial within that ceiling: the 15-project plan is now complete rather than 9 of 15, every reader-facing status claim in README and SUMMARY matches what actually exists rather than a mix of current and stale figures, the interview bank is genuinely at parity across all 15 projects rather than uneven, and the specific readability scope requested was actually reviewed, with real defects found and fixed, not asserted clean without checking. **Public MVP Ready** remains withheld until a successful Terraform CI run and live Azure validation of session-host registration, sign-in, FSLogix persistence, RemoteApp delivery, scaling, monitoring and cleanup, exactly as stated in every prior report.
