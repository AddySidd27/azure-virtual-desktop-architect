# Audit 05 - Chapters 1 to 19 Retrofit to the Raised Standard

> **Internal development record.** Not required reading. See [Development history](development-history.md) for a summary.

**Date:** August 2026
**Scope:** Every chapter written before the standard was raised at Chapter 19
**Standards applied:** [CHAPTER-CONTRACT.md](../CHAPTER-CONTRACT.md), [OPERATIONS-AND-TROUBLESHOOTING-STANDARD.md](../OPERATIONS-AND-TROUBLESHOOTING-STANDARD.md), [DIAGRAM-STANDARD.md](../DIAGRAM-STANDARD.md)
**Result:** All 19 chapters updated. No chapter left at the older standard.

---

## 1. What the audit found

Three things were added to the standard at Chapter 19: the extended scenario format with business impact, architect lesson and interview lesson, the Architect's Reality Check section, and an explicit discussion of how the design changes with scale.

The scan across Chapters 1 to 18 found:

| Item | Chapters missing it |
|---|---|
| Business impact in scenarios | All 18 |
| Architect lesson in scenarios | 1 to 8 |
| Interview lesson in scenarios | All 18 |
| Architect's Reality Check | All 18 |
| Scale discussion | 2, 4, 5, 6, 7, 8, 9, 10, 11, 13, 14, 16, 17, 18 |

Interview preparation, official references, currency flags, the architect's four questions and diagram compliance were already present everywhere, because those were retrofitted in earlier audits.

---

## 2. What was changed

### Architect's Reality Check, 18 chapters

Added to every chapter from 1 to 18, answering the five questions defined in the chapter contract. Each was written specifically for that chapter's subject. Examples of what the section now carries:

- Chapter 4: check the transport before resizing hosts, and ask what changed on the network recently
- Chapter 9: check sign in frequency on the AVD app first, and ask whether legacy per user MFA is still enabled anywhere
- Chapter 13: check inside the virtual machine before the firewall, and ask what endpoint agents are deployed to session hosts
- Chapter 16: ask what the session host pipeline actually does, because that decides whether the management approach should change
- Chapter 18: read status together with the status timestamp, because Available with a stale timestamp is a different fault

### Scale discussion, 14 chapters

Added where it was missing, covering roughly 100, 1,000 and 5,000 users. These are not multiplications. Each explains what changes architecturally. For example:

- Chapter 8: an extra prompt is an annoyance at 100 users, a ticket stream at 1,000, and something that must be enforced in code at 5,000 because manual consistency across many host pools is not achievable
- Chapter 10: a delegation model is documentation at 100 users and an availability control at 5,000, because it limits the blast radius of an honest mistake
- Chapter 11: broad outbound access is acceptable at 100 users, a firewall is justified at 1,000, and at 5,000 the region specific endpoint lists need per region maintenance

### Business impact, 50 scenarios

Added to every scenario across Chapters 1 to 18. Each states who is affected, how many and what it costs, with a number where one exists. Where the impact is not user facing, that is stated plainly rather than inflated. Several scenarios have no user impact at all, such as the data residency question in Chapter 2 and the unbudgeted RDS CAL in Chapter 5, and saying so is more useful than inventing an outage.

### Architect lesson, Chapters 1 to 8

Chapters 9 to 18 already carried these. Added to the earlier chapters, drawn from the scenario rather than generic.

### Interview lesson, 50 scenarios

Added throughout. Each explains what the story demonstrates to an interviewer, not just what happened. This is the field that makes the scenarios usable for interview preparation rather than only for reference.

---

## 3. What was deliberately not changed

**Chapter 1 keeps design decision scenarios rather than troubleshooting scenarios.** Nothing is deployed at that point in the book. Manufacturing a troubleshooting scenario there would be filler. This exception was recorded in [Audit 01](audit-01-chapter-contract.md) and still holds.

**No chapter was rewritten wholesale.** The instruction was to improve quality, accuracy, consistency and usefulness, not to regenerate work that was already correct. Technical content, architecture decisions, naming conventions, lab references and diagrams were left alone where they already met the standard.

**No diagrams were changed in this pass.** They were rebuilt to the current standard in [Audit 04](audit-04-diagram-rebuild-architecture.md) and were re-checked rather than re-made.

---

## 4. Verification after the retrofit

| Check | Result |
|---|---|
| Every chapter has an Architect's Reality Check | Pass, Chapters 1 to 20 |
| Every chapter discusses scale where relevant | Pass |
| Every scenario has business impact | Pass |
| Every scenario has an architect lesson | Pass |
| Every scenario has an interview lesson | Pass |
| Long dash characters anywhere in the repository | None |
| Internal links still resolve | Pass. No link targets were changed |
| Lab links intact | Pass |
| Naming conventions unchanged | Pass |
| Northwind personas and figures unchanged | Pass |
| Diagram files unchanged | Pass, by design |

---

## 5. Changelog

| Chapter | What changed | Why | Technical verification | Diagram | Lab | Review |
|---|---|---|---|---|---|---|
| 1 | Reality Check, business impact and interview lessons on three design scenarios | Standard raised at Ch 19 | No new technical claims added | Unchanged | Unchanged | Readability |
| 2 | Reality Check, scale, business impact, architect and interview lessons | Same | No new claims | Unchanged | Unchanged | Readability |
| 3 | Reality Check, business impact, architect and interview lessons | Same | No new claims | Unchanged | Unchanged | Readability |
| 4 | Reality Check, scale, business impact, architect and interview lessons | Same | No new claims | Unchanged | Unchanged | Readability |
| 5 | Reality Check, scale, business impact, architect and interview lessons | Same | No new claims | Unchanged | Unchanged | Readability |
| 6 | Reality Check, scale, business impact, architect and interview lessons | Same | No new claims | Unchanged | Unchanged | Readability |
| 7 | Reality Check, scale, business impact, architect and interview lessons | Same | No new claims | Unchanged | Unchanged | Readability |
| 8 | Reality Check, scale, business impact, architect and interview lessons | Same | No new claims | Unchanged | Unchanged | Readability |
| 9 to 11 | Reality Check, scale, business impact, interview lessons | Same | No new claims | Unchanged | Unchanged | Readability |
| 12 | Reality Check, business impact, interview lessons | Same | No new claims | Unchanged | Unchanged | Readability |
| 13 to 14 | Reality Check, scale, business impact, interview lessons | Same | No new claims | Unchanged | Unchanged | Readability |
| 15 | Reality Check, business impact, interview lessons | Same | No new claims | Unchanged | Unchanged | Readability |
| 16 to 18 | Reality Check, scale, business impact, interview lessons | Same | No new claims | Unchanged | Unchanged | Readability |
| 19 | None required. Written to the raised standard | Reference chapter for the new format | Complete | Unchanged | Unchanged | Complete |

**Note on technical verification during this retrofit.** No new technical claims were introduced. Every addition is reasoning, impact or interview framing built on content that was already verified in that chapter's original review. Where a retrofit needed a technical fact, it referenced the existing verified statement rather than adding a new one. That is deliberate, because adding unverified claims during a formatting pass is how errors enter a book.

---

## 6. Standing rule, restated

New standards apply retrospectively. The audit runs across completed work before the next chapter is written, and is recorded here as the next numbered audit. This is the fifth application of that rule.
