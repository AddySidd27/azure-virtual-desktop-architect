# Architecture Case Study Standard

Revised August 2026. The projects are now the primary vehicle for the rest of this book, not a supplement to the concept chapters. See [Structure change 03](appendices/structure-change-03-project-led.md).

A project is a fictional architecture exercise based on a realistic business problem. It is not presented as customer work. The reader receives requirements, constraints, and risks, then designs and defends a solution.

---

## 1. Before writing a project, answer these

Every project opens with an engagement brief that answers eight questions honestly:

1. What realistic enterprise situation does this represent?
2. What business problem triggered it?
3. What constraints exist that cannot be designed away?
4. Which previously learned concepts are being applied?
5. Which new concepts have to be introduced here?
6. What architectural decisions must be made?
7. What could realistically go wrong?
8. How would the environment be validated and handed to operations?

If question 1 cannot be answered with a situation an architect would actually meet, the project should not be written. No scenario exists to demonstrate a technology.

---

## 2. Depth is set by the engagement, not by a template

There is no fixed section list and no target word count. A project covers what that engagement genuinely requires and stops.

Most engagements will need most of the following, and the order varies with the work:

Business and technical requirements, assumptions, personas, architecture decisions, architecture diagram, identity, authentication and Conditional Access, network, host pools, sizing, image strategy, profiles and storage, application delivery, security, monitoring, scaling, cost, high availability, disaster recovery, Terraform, deployment steps, validation, failure scenarios, troubleshooting, runbooks, patching, trade-offs, and interview questions.

Some engagements need migration planning, parallel running, application assessment or incident recovery instead of half of that list. A disaster recovery project spends its length on recovery, not on how to size a host.

**Padding is a defect.** A section that repeats a concept chapter, or restates a decision already made, is removed.

---

## 3. Teaching new concepts inside a project

Where a project needs a concept the book has not covered, teach it there, at the point the engineer would need it. Keep it practical and short. Explain what it is, why it matters here, how to configure it, and how to tell whether it is working.

Do not write a textbook section. The reader is mid-engagement, not mid-syllabus.

Concepts introduced in a project are recorded in the concept coverage map so nothing is lost or taught twice.

---

## 4. Realism rules

**Worked numbers.** User counts, concurrency, host counts, IOPS, costs, and timings must be labelled as assumptions, calculations, targets, or measured lab evidence.

**Competing requirements.** At least two that pull against each other, resolved explicitly.

**Constraints that cannot be designed away.** Budget ceilings, contracts, skills, regulation, dates.

**At least one decision that goes against the obvious answer**, with the reasoning.

**Realistic failure patterns.** Use failures documented by Microsoft or demonstrated in a lab. Do not present a fictional incident as a real customer event.

**Operational ownership.** Who runs this afterwards, and whether the design suits them.

---

## 5. What the reader should be able to do afterwards

- Explain the architecture to a customer without notes
- Defend every decision, including the compromises
- Build selected parts in a lab from the Terraform and the steps
- Predict what will break and how they would know
- Answer an architecture design interview question on that engagement
- Publish the design as portfolio work

---

## 6. Consistency

Same naming conventions, terminology, diagram standard and Terraform patterns as the rest of the book. Concept chapters are referenced, never repeated.

Each project uses a different fictional organization. Northwind Global Manufacturing is reserved for the capstone.

## 7. Credibility rules

- Put a fictional case-study notice directly below the title.
- Use future or conditional language for tests and outcomes that were not run.
- Do not claim customer savings, go-live results, incidents, migrations, or handover completion.
- A written test step is a validation plan, not validation evidence.
- Link product behavior to Microsoft Learn or the Azure Architecture Center.
- Link lab-tested claims to sanitized evidence.
