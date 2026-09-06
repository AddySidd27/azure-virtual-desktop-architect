# Writing Style Guide

This applies to every chapter, lab, scenario and appendix in this book. The goal is simple. A reader should be able to work through a hard AVD topic once and understand it, without going back over the same paragraph three times.

---

## Voice

Write like an experienced cloud architect explaining something to another engineer. Practical, direct, conversational. Not academic, not marketing, not a product page.

- Short sentences. If a sentence needs three commas to work, split it.
- Explain the idea in plain English first, then introduce the technical term.
- Use ordinary words. Do not reach for a longer word when a short one works.
- Do not overuse commas.
- Do not use the long dash character. Use a full stop, a comma or a normal hyphen instead.
- Do not open a chapter with filler like "In this chapter we will explore". Start with the actual content.
- Avoid "It is important to note that", "In today's rapidly evolving cloud landscape", "leveraging the power of", and similar padding.
- Do not repeat the same conclusion at the end of every section.

## Technical depth

Simple English does not mean less detail. Compare these:

Weak: "AVD uses secure connectivity."

Good: "AVD session hosts do not need inbound RDP ports open to the internet. The session host makes an outbound connection to the AVD service instead. That is why a correctly designed AVD environment never exposes TCP 3389 to the public internet."

Both are simple. Only one is useful.

## Examples and real-world use cases

Every chapter needs at least three practical examples where examples genuinely help. Do not invent filler examples to hit a number. If a topic only supports two good examples, use two.

Each example should cover:

1. The real-world requirement
2. The architecture or the decision taken
3. Why that option was chosen over the alternatives
4. How it would be implemented
5. What can go wrong
6. How an architect would validate it

Draw from realistic settings. Small business, large enterprise, hybrid AD, remote and BYOD workers, call centres, developers, regulated workloads, global deployments.

## Repetition

Do not re-explain something already covered. Link to the chapter that covers it and give only what the current chapter needs.

Good: "Reverse connect is covered in [Chapter 4](chapters/ch04-connection-flow-end-to-end.md). What matters here is that the session host needs outbound access on 443 before it can register."

## Accuracy

- Do not invent PowerShell, Azure CLI, Terraform, Bicep or KQL syntax. Verify against official documentation.
- State module or provider versions where behaviour depends on them.
- Mark anything unverified as `[VERIFY BEFORE IMPLEMENTATION]`.
- Add a dated `CURRENCY FLAG` to anything that has changed recently or is likely to change.
- Separate Microsoft-supported behaviour from unsupported or third-party approaches.

## Chapter self-review

Write the chapter. Then review it as a separate pass before publishing. Check every item:

- [ ] Technical accuracy
- [ ] Current Microsoft AVD capability, verified
- [ ] Supported versus unsupported clearly separated
- [ ] Commands, Terraform, CLI, PowerShell and KQL syntax correct
- [ ] Terraform logically correct, not just syntactically valid
- [ ] Mermaid diagrams render and match the text
- [ ] Architecture consistent with earlier chapters
- [ ] Links and references work and point to the right place
- [ ] Lab dependencies still hold
- [ ] Naming conventions followed
- [ ] Cost statements accurate and honest
- [ ] Security implications stated
- [ ] Interview answers sound natural when spoken
- [ ] At least three useful real-world examples where relevant
- [ ] No duplicated explanation from earlier chapters
- [ ] No missing concept the chapter needs
- [ ] Simple, natural English
- [ ] Nothing that reads as AI generated
- [ ] No excessive commas
- [ ] No long dash characters

Fix what the review finds before publishing.

## Priority order

Simple English, then technical accuracy, then practical examples, then hands-on implementation, then real-world architecture, then troubleshooting, then interview preparation.

## The test

Read the finished chapter and ask: would a senior Azure architect publishing this on GitHub be happy to put their name on it? If not, rewrite it.
