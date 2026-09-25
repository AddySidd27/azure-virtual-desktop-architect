# Development History

This repository was built in phases, each followed by a quality pass against the repository's own style, diagram, and citation standards. This page summarizes that history. The detailed pass-by-pass records referenced below remain in the repository for full traceability, but they are development notes, not reading material, and are kept out of the primary table of contents for that reason.

## Diagram quality (Audits 01-08)

The early diagram set was rebuilt twice: first to a consistent visual style (icons, layout, color), then to check every diagram's technical content against the chapter it illustrates. By the end of this phase, every diagram in the repository had been checked for both visual quality and topic accuracy, and an architecture-level diagram tier was introduced for the highest-value topics.

## Content retrofit (Audit 05, Structure changes 01-03)

Chapters 1-19 were retrofitted to a raised writing and technical-accuracy standard after the first nine chapters set a higher bar than the rest of the book. Windows 365 and Intune were promoted to first-class topics rather than side notes. The book's structure changed twice more: real-world case studies were expanded from a handful of examples into 15 full project write-ups, and the originally planned Chapters 26-54 were folded into that project-led format instead of being written as standalone chapters.

## Publication remediation (Audits 09-17)

Before the repository was shared for review, four passes worked through: broken links and stale citation artifacts; the full Labs 5-10 build, taking the lab sequence to a working AVD deployment; five troubleshooting runbooks and the first version of the interview question index; and a full visual QA pass that rendered and checked every diagram, fixing real rendering and content bugs rather than just re-styling them. A repository-wide diagram inventory followed, replacing 34 diagrams and standardizing all of them on a self-contained icon set with no remote dependencies. The closing pass published the remaining case studies (Project 03 and Projects 11-15, completing all 15) and ran a readability pass against the house style guide.

## Multi-region labs and corrections

Labs 11-20 added an active-active, multi-region AVD build on top of the original single-region lab sequence, with product-accuracy findings checked against current Microsoft Learn documentation (Regional Host Pools and Session Host Configuration are both still Preview or unavailable in Terraform, so the labs use standard host-pool management and Power Management Autoscale throughout - see [the ADR](adr-shc-vs-standard-host-pools.md)). One post-acceptance correction followed: Lab 19's disaster-recovery region originally depended on identity infrastructure in the region it was meant to protect against, which was fixed by adding a second, independent domain controller; the Capacity Reservation cost model was also corrected to reflect that it bills continuously regardless of whether a VM is deployed.

## Capstone build and remediation

The [Northwind capstone](../capstone/implementation-tracker.md) - a fictional 3,200-user enterprise AVD platform spanning identity, networking, policy, and the AVD platform itself - was built in parts (A through H) and then went through a dedicated review that found and fixed a handful of real issues: a fabricated Azure role name that didn't exist, three roles with no Terraform behind them, a host pool load-balancer setting that hadn't been checked against Microsoft's own guidance, and a monitoring workspace that had been designed but never actually built. Each fix is described at the point in the Terraform where it applies rather than narrated separately here.

## What this history does not claim

These passes found and fixed real problems - a fabricated resource name, missing Terraform, unchecked configuration values - and that work is reflected directly in the current chapters, labs, and Terraform, not just in this summary. It does not mean the repository is beyond error: treat any specific technical claim the way you would treat any single source, and verify it against current Microsoft documentation before relying on it in production.

For the full pass-by-pass record, see the files under [`appendices/`](.) prefixed `audit-`, plus [`capstone/implementation-tracker.md`](../capstone/implementation-tracker.md). They are kept for traceability rather than as reading material, and their language and format (a "Pass 1 / 2 / 3" checklist repeated per document) is more mechanical than the rest of the book - useful as a record, not representative of the writing style elsewhere in the repository.
