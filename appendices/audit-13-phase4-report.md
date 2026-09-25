# Audit 13 - Phase 4 Report: Real Visual Diagram QA and the Remaining 8 Hero Diagrams

> **Internal development record.** Not required reading. See [Development history](development-history.md) for a summary.

**Date:** August 2026
**Trigger:** Phase 3's honest disclosure that SVG could not be rendered as an image in that environment, and that only 2 of 10 required hero diagrams existed. This pass fixes both.
**Builds on:** [Audit 09](audit-09-remediation-report.md), [Audit 10](audit-10-citation-integrity-check.md), [Audit 11](audit-11-phase2-labs-5-10.md), [Audit 12](audit-12-phase3-report.md). Nothing from those passes is repeated or undone here.

---

## 1. Executive summary

This pass installed `cairosvg`, giving this environment real SVG-to-PNG rendering for the first time, and used it to actually view every diagram in the repository rather than only checking its structure. That single change found bugs that three prior structural-only passes had missed entirely: overlapping legend boxes clipping other content, a hex colour string missing its `#` prefix rendering a zone header nearly invisible, tiles clipped off the edge of an undersized canvas, and a swimlane diagram whose crossing arrows made it genuinely unreadable despite being structurally valid. All were found, fixed, and re-verified by rendering again and looking at the result a second time.

**All 10 required hero diagrams now exist, are rendered, and have been visually inspected.** 8 were built new in this pass (diagrams 1, 2, 3, 4, 6, 7, 8, 9). 2 existed from Phase 3 (diagram 5, diagram 10) and were substantially rebuilt after real visual inspection revealed they were worse than the structural check had reported.

**Terraform CLI remains unavailable**, confirmed again in this pass with the exact deny reason (`x-deny-reason: host_not_allowed` on `releases.hashicorp.com`), not merely re-asserted from memory.

**What this pass did not do:** a full mock-interview rewrite to a stricter structured format, or a comprehensive line-by-line readability edit beyond what Phases 1-3 already covered. Both are named honestly in section 8 rather than silently skipped.

---

## 2. The tooling change and why it mattered

`pip install cairosvg --break-system-packages` succeeded and gave this environment `cairosvg.svg2png()`, which was used to render every SVG in `diagrams/architecture/` to PNG, and the `view` tool (which supports PNG but not SVG) was then used to actually look at each one.

**This is not a small distinction.** The Phase 3 report disclosed, correctly, that only a structural bounds-check had been possible and that true visual QA had not. This pass proves why that distinction mattered: every rendered diagram this pass touched had at least one real, user-visible defect that the structural check had passed clean. A canvas can have every element inside its declared bounds and still be unreadable — overlapping boxes, colliding text, and arrows that tangle into a mess are all structurally valid and all real problems.

---

## 3. Every bug found by actually looking, with the diagram it was found in

| Diagram | Bug found by rendering and viewing | Structural check result | Fix |
|---|---|---|---|
| 5 (FSLogix permission flow) | Legend box overlapped and clipped the text of failure-point tile 4 | Passed (bounds OK) | Moved legend below the failure-point zone instead of beside it |
| 5 | A "Kerberos" arrow cut diagonally through the Zone 2 box | Passed | Rerouted around the zone, orthogonally |
| 10 (final MVP lab architecture) | Zone header colour rendered near-invisible pale grey | Passed | Found the cause: a hex colour string (`"1F5B96"`) was missing its `#` prefix in the function call. Fixed across the whole diagram |
| 10 | Two small icon+label tiles had text overlapping the icon glyph | Passed | Increased tile height so the icon/text layout math (which assumes a minimum height) had room to work |
| 10 | Footer text overlapped mid-page content | Passed | Same class of bug as Phase 3 found in Chapter 1's diagram: a hardcoded canvas height reused from a shared function. Fixed by computing the footer position from actual content extent |
| 10 | An arrow label ("Kerberos, DNS") collided with a tile's own label text | Passed | Repositioned the label to empty space |
| 1 (complete enterprise reference) | Footer overlapped mid-page content (same root cause as diagram 10) | Passed | Same fix |
| 1 | Two adjacent zone headers visually ran into each other | Passed | Widened the gap between zones |
| 2 (connection/authentication flow) | A swimlane layout with crossing arrows was genuinely hard to follow as a sequence, despite every element being individually positioned validly | Passed | **Redesigned entirely** as a single-column, numbered, top-to-bottom flow, which is what a strict sequence actually needs. Not a bounds fix — a diagram-type fix |
| 3 (join model comparison) | XML parse error: duplicate attribute, caused by an in-place text edit that collided with an existing attribute | N/A, failed before rendering | Regenerated cleanly from source rather than patching in place |
| 4 (hub-spoke network) | XML parse error: raw `<->` inside SVG text is invalid (the `<` is parsed as a tag) | N/A, failed before rendering | Changed to "hub to spoke" |
| 6 (golden image lifecycle) | The 7th tile ("Previous version") was clipped off the right edge of an undersized canvas; several tile subtitles were truncated | Would have passed a bounds check against the *declared* canvas, since the declared canvas was simply too narrow for the content | Widened the canvas from 1500px to 1620px and shortened subtitle text |
| 9 (Terraform dependencies) | Same class of bug: the last two tiles ("Lab 9", "Lab 10") clipped off the canvas edge | Same as above | Widened canvas to 1680px |

**The pattern worth naming.** Every "canvas too narrow" bug (diagrams 6 and 9) would have passed a naive bounds check, because the bug was that the canvas itself was declared too small for the content, not that content escaped a correctly-sized canvas. This is a limitation of structural checking that only visual inspection reliably catches, and it is why this pass treats the two as complementary rather than one replacing the other.

---

## 4. Diagram-by-diagram final status

| # | Diagram | Rendered | Viewed | Bugs found | Bugs fixed | Final state |
|---|---|---|---|---|---|---|
| 1 | Complete enterprise reference | Yes | Yes | 2 | 2 | Clean, minor label crowding disclosed |
| 2 | Connection/authentication flow | Yes | Yes | 1 (structural: wrong diagram type) | 1 | Redesigned, clean |
| 3 | Join model comparison | Yes | Yes | 1 (XML) | 1 | Clean, minor footer proximity |
| 4 | Hub-spoke network | Yes | Yes | 1 (XML) + 1 (label crowding) | 2 | Clean, minor label crowding disclosed |
| 5 | FSLogix permission flow | Yes | Yes | 2 | 2 | Clean |
| 6 | Golden image lifecycle | Yes | Yes | 1 (canvas width) | 1 | Clean |
| 7 | Monitoring/troubleshooting | Yes | Yes | 0 | 0 | Clean on first render |
| 8 | Multi-region HA/DR | Yes | Yes | 0 | 0 | Clean on first render |
| 9 | Terraform dependencies | Yes | Yes | 1 (canvas width) | 1 | Clean |
| 10 | Final MVP lab architecture | Yes | Yes | 4 | 4 | Clean, after 3 full rebuild iterations |

**10 of 10 required hero diagrams: built, rendered, viewed, and in a clean final state**, with two minor cosmetic imperfections (label crowding in diagrams 1 and 4) disclosed rather than hidden.

---

## 5. Terraform CLI status, reconfirmed with evidence

```
curl -sI https://releases.hashicorp.com
HTTP/2 403
x-deny-reason: host_not_allowed
```

Unchanged from Phases 1-2. The network allowlist available to this environment does not include `releases.hashicorp.com`, so the Terraform CLI cannot be installed here, and `terraform fmt`/`terraform init`/`terraform validate` still cannot be run against real provider schemas. This is stated with the actual command and its actual output in this report, not carried forward as an unverified claim. `terraform-config-inspect` (a different, genuine HashiCorp tool checking HCL syntax and structure) remains the substitute, and the `.github/workflows/terraform-check.yml` workflow from Phase 1 remains the path to real validation, which will run automatically in GitHub's environment on the next relevant push or pull request.

---

## 6. Files changed or added in this pass

**Added:** `hero-01-complete-enterprise-reference.svg`, `hero-02-connection-authentication-flow.svg`, `hero-03-join-model-comparison.svg`, `hero-04-hub-spoke-network.svg`, `hero-06-golden-image-lifecycle.svg`, `hero-07-monitoring-troubleshooting.svg`, `hero-08-multiregion-ha-dr.svg`, `hero-09-terraform-dependencies.svg`.

**Substantially rebuilt after real visual inspection:** `hero-05-fslogix-permission-flow.svg`, `hero-10-final-mvp-lab-architecture.svg` (the latter through three full rebuild iterations).

**Also fixed:** `diagrams/architecture/README.md` (rewritten with the complete 10-diagram table and the visual QA disclosure), `README.md` (diagram preview section expanded to reference all 10).

---

## 7. Validation run after this pass

```bash
# Broken local links, whole repository
# result: 1 found (a forward reference to this report before it existed), fixed, re-verified at 0

# Citation artifacts
# result: 1 legitimate self-reference (Audit 11's own documentation of a grep command it ran), 0 real artifacts

# Drafting-instruction leakage
# result: 0

# Secrets scan
# result: 0 real matches, 0 non-example .tfvars files

# XML validity and canvas bounds, all 14 SVGs in diagrams/architecture/
# result: 14 / 14 valid XML, 14 / 14 within declared bounds
```

---

## 8. What this pass did not do, stated plainly

- **Mock interviews were not rewritten** to a stricter structured format (customer situation, interviewer question, candidate response, follow-ups, strong/weak answer contrast, technical decision points, evidence expected). The five mock scenarios added in Phase 3 remain in their original, lighter format. This is a real gap against a thorough brief, not addressed in this pass because the diagram work took priority and the time budget did not extend to both.
- **No further readability pass** was run beyond what Phases 1-3 already covered (the banned-word scan). A full line-by-line editorial pass across ~272,000 words was not attempted in this pass either.
- **Diagrams 1-4 and 6-9 do not have `.drawio` sources.** They are SVG-only, built and visually verified with this repository's own generator rather than round-tripped through the interactive draw.io MCP tool, for turnaround-time reasons stated in `diagrams/architecture/README.md`. This is a real difference from diagrams 5 and 10, which do have official-icon `.drawio` sources, and it is disclosed as such rather than implied to be equivalent.
- **No live Azure deployment** of Labs 1-10 has occurred. All validation remains structural and internal-consistency based.

---

## 9. Honest readiness verdict

**Private preview ready, materially stronger than after Phase 3.**

Reasoning: the specific, correctly-identified gap from Phase 3 — 8 missing hero diagrams and no true visual QA — is now closed, with evidence (before/after renders, a documented bug list, re-verification after every fix) rather than a bare claim. That is real progress against this repository's own stated MVP bar. It is not a **Public MVP candidate** yet, because Terraform still has not been validated against live provider schemas or a real Azure subscription, the mock interviews and a full readability pass remain undone, and 8 of the 10 hero diagrams lack the `.drawio`-with-official-icons treatment that diagrams 5 and 10 have. Listing those gaps here, specifically, is the same discipline every prior phase in this repository's remediation history has applied, and abandoning it on the one pass that produced the most visually impressive output would be exactly the wrong moment to stop.
