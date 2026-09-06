# Chapter Contract

What every major chapter in this book must deliver. This sits alongside the [style guide](STYLE-GUIDE.md) and the [operations and troubleshooting standard](OPERATIONS-AND-TROUBLESHOOTING-STANDARD.md).

The aim is that one project serves five purposes at once: a book, a lab manual, a production runbook, an interview preparation guide, and a public portfolio. Every chapter has to earn its place in all five.

---

## 1. Five things every chapter covers

Configuration alone is not a chapter. Each one must answer:

| Question | What it means in practice |
|---|---|
| **How does it work?** | The concept, explained simply, then the technical detail |
| **How does it behave in production?** | Real behaviour at scale, under load, over time. Not the happy path from a tutorial |
| **How does it fail?** | The actual failure modes, including the ones with misleading symptoms |
| **How does an engineer investigate it?** | Exact portal paths, PowerShell, CLI, KQL and Event Viewer steps |
| **How does an architect decide?** | Requirement, options, trade-offs, decision, reason |
| **How does the organisation prevent it?** | Design change, automation, monitoring, process or checklist |

The last one matters most and is skipped most often. A fix that does not become prevention will be applied again next quarter.

---

## 2. Three production scenarios

At least three realistic production scenarios per major chapter, where they are technically relevant. Each scenario carries:

- Implementation or investigation steps, exact enough to follow
- Expected results, including what correct output looks like
- Failure conditions, including what it looks like when it goes wrong
- Validation, proving the outcome rather than assuming it
- Architect level lesson, the thing worth remembering after the details fade

Troubleshooting scenarios use the nine step format in the [operations standard](OPERATIONS-AND-TROUBLESHOOTING-STANDARD.md). Design scenarios use requirement, decision, reasoning, implementation, risk, validation.

Do not manufacture a third scenario to hit the number. Two strong ones beat three where the last is filler.

---

## 2a. Architect's Reality Check

Important topics carry a short section called **Architect's Reality Check**, containing:

- What people commonly get wrong
- What I would check first in production
- What I would ask the customer
- What decision I would make as an architect
- What I would say in an interview

This is reasoning from experience, not generic advice. If a line could appear in any chapter, it does not belong here.

## 2b. Architect decision structure

Major architectural decisions are presented as a comparison, not a recommendation:

Requirement, Option A, Option B, pros, cons, operational impact, security impact, cost impact, scalability impact, failure impact, recommendation, when not to use the recommendation, real-world example.

No architecture is presented as universally correct. The trade-off is the content.

## 2c. Scale

Where scale changes the answer, say what changes at roughly 100 users, 1,000 users and 5,000 or more. Many AVD designs are correct at one size and wrong at another, and that is usually the interesting part of the topic.

## 3. Two review passes before publishing

Write the chapter, then review it twice, separately.

**Pass 1, technical verification.** Check every claim against current official Microsoft documentation. Verify commands, cmdlets, app IDs, portal paths, limits and supported scenarios. Confirm what is generally available, what is preview, and what is unsupported. Add a dated `CURRENCY FLAG` where the topic has changed recently. Mark anything unverified as `[VERIFY BEFORE IMPLEMENTATION]`.

**Pass 2, readability.** Read it as a reader, not as the author. Split long sentences. Remove padding. Cut anything that repeats an earlier chapter. Check that the English stays simple, natural and human, and that nothing reads as machine generated.

Both passes are recorded in the chapter self-review table at the end of the chapter.

---

## 4. What the finished chapter should be usable for

- **Learning.** A reader new to the topic can follow it without external material.
- **Doing.** An engineer can perform the procedures in the lab environment.
- **Operating.** The runbooks and troubleshooting steps work in a real environment.
- **Interviewing.** The questions and answers can be spoken aloud without sounding rehearsed.
- **Publishing.** It stands alone well enough to become a blog article, with correct attribution and no reproduced third party content.
