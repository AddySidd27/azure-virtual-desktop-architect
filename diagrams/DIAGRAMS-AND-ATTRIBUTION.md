# Diagrams, Sources and Attribution Policy

This book is published publicly. Everything in it must be safe to publish and correctly attributed. This page explains how diagrams and sources are handled throughout.

---

## 1. Diagram classification

Every diagram in this book carries one of four labels. The label appears directly above the diagram.

| Label | Meaning | Can it be treated as Microsoft guidance? |
|---|---|---|
| **OFFICIAL MICROSOFT ARCHITECTURE** | The concept and structure come from official Microsoft documentation. A link to the original Microsoft page is always given. | Yes - follow the link for the authoritative version |
| **BOOK REFERENCE ARCHITECTURE** | An original design created for this book, informed by Microsoft guidance but not published by Microsoft | No |
| **LAB ARCHITECTURE** | The environment you build in Labs 1-20 | No |
| **EXAMPLE CUSTOMER ARCHITECTURE** | Northwind Global Manufacturing, the fictional capstone customer | No |

An original design is never presented as something Microsoft recommends.

---

## 2. How official Microsoft diagrams are handled

Microsoft's documentation images are Microsoft's copyrighted material. Reuse rights for republishing them in a public book or blog are not clearly granted for this use case.

**Therefore this book does not copy, embed, or reproduce Microsoft's diagram images.**

Instead, wherever an official Microsoft diagram exists and materially helps understanding, the book does this:

1. States that an official Microsoft diagram exists.
2. Gives a direct link to the exact Microsoft Learn page that contains it, so you can open the original alongside the text.
3. Provides an **original Mermaid diagram** that expresses the same architecture in the book's own visual style.
4. Explains the diagram in full, using the four-part structure below.

This keeps the book technically anchored to Microsoft's architecture while remaining safe to publish on GitHub and a blog. If Microsoft's usage terms for a specific asset are clearly permissive for republication, that asset may be embedded with attribution and a source link - but the default is link-plus-original.

Where the book quotes Microsoft documentation directly, the quotation is short, marked as a quotation, and attributed with a link. Everything else is written in the book's own words.

---

## 3. Diagram explanation structure

Every important diagram is followed by four sections, in this order:

1. **What the diagram shows** - the architecture explained in plain English.
2. **Step-by-step flow** - how traffic, authentication, sessions, storage or management actually move through it.
3. **Architect's view** - why it is built this way, and what the trade-offs are.
4. **Official reference** - the Microsoft Learn or Azure Architecture Center page that backs it.

You should never have to work out a diagram by staring at it.

---

## 4. Source hierarchy

**Tier 1 - authoritative.** Microsoft Learn, Azure Architecture Center, Cloud Adoption Framework, Azure service limits documentation, Az PowerShell and Azure CLI references, Terraform Registry provider documentation (for provider behaviour). All factual claims trace back to Tier 1.

**Tier 2 - supporting context only.** Microsoft Tech Community posts and official Microsoft announcements. Used for currency and context, never as the sole basis for a technical claim.

**Tier 3 - excluded from factual claims.** Community blogs, forums and vendor content. May be referenced as "field practice" and clearly labelled as such.

**Conflict rule.** If an official Microsoft diagram and the current Microsoft documentation disagree, the current documentation wins and the discrepancy is flagged in the text.

**Uncertainty rule.** Anything that cannot be verified at the time of writing is marked `[VERIFY BEFORE IMPLEMENTATION]` rather than guessed. Anything verified against a recent platform change carries a dated `CURRENCY FLAG`.
