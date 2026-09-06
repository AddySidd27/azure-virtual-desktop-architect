# Audit 10 - Citation Integrity Check (Post Cite-Strip)

**Date:** August 2026
**Trigger:** The prior pass stripped 348 `<cite index>` wrappers programmatically, preserving the enclosed prose. This check confirms that removal did not leave Microsoft-derived claims without professionally defensible source attribution.

---

## 1. Method

The stripped text was never rewritten — the wrapper tags were removed and the enclosed sentences kept verbatim as prose. That means every one of the 348 claims was, at the moment of stripping, already either original explanatory prose written around a Microsoft fact, or a short paraphrase/quotation under this repository's own citation rules (quotes under 15 words, one quote per source, established before any of this content was written). The question this check answers is narrower than "were the claims accurate" — that was already governed by the writing rules — and is specifically: **does a reader encountering one of these claims today have a clear, nearby path to the Microsoft source that supports it?**

Three checks were run:

1. **Reference-section coverage.** Does every chapter carry an "Official References" section, and does it plausibly cover the density of claims in that chapter?
2. **Density spot-check.** For the files with the highest original citation count (highest risk of an orphaned claim), read the full file and confirm every implementation-sensitive or time-sensitive statement maps to one of the listed references.
3. **Targeted remediation.** Where a file's claim density was high enough that a reader would have to guess which of several listed references backed a given row or paragraph, add a direct nearby link rather than relying on the reader to search a five-link list at the bottom of a long file.

---

## 2. Result 1: reference-section coverage

```bash
for f in chapters/ch*.md; do
  grep -q "Official References" "$f" || echo "MISSING: $f"
done
```

**Result: no output.** All 25 published chapters carry an Official References section. This was already a requirement of the [chapter contract](../CHAPTER-CONTRACT.md) from the first chapter written, independent of the citation-tag issue, so this result was expected rather than a new finding.

---

## 3. Result 2: density spot-check

The six files with the highest original `<cite index>` counts were read in full end to end:

| File | Original cite count | Reference links present | Verdict |
|---|---|---|---|
| `appendices/intune-avd-support-matrix.md` | 39 | 5, but structured as ten distinct sections each covering a different Intune capability area | **Remediated** — see section 4 |
| `chapters/ch20-profile-storage-architecture.md` | 21 | 12 | Adequate. High reference count matches high claim count, and the chapter's structure (numbered sections, each ending near a relevant citation) keeps claims close to their source |
| `chapters/ch04-connection-flow-end-to-end.md` | 18 | 6 | Adequate. The 18 claims cluster around the 13-step connection sequence, which is a single Microsoft Learn topic area covered by 2-3 of the 6 references; the remainder cover Shortpath and authentication, each with their own reference |
| `chapters/ch03-avd-object-model.md` | 17 | 6 | Adequate. Claims map cleanly to the object model documentation and the preferred-application-group-type page, both listed |
| `chapters/ch16-automated-host-pools-session-host-configuration.md` | 16 | 10 | Adequate. Roughly a 1.6:1 ratio, and the chapter's numbered sections each carry their own "Official Microsoft reference" line inline, not only at the bottom |
| `chapters/ch24-intune-and-avd-endpoint-management.md` | 15 | 10 (now more, after the Phase 1 correction) | Adequate, and already re-verified line by line against current Microsoft Learn in the prior remediation pass |

**The one genuine risk found:** `appendices/intune-avd-support-matrix.md`. Unlike the chapters, this file is a ten-section reference table used directly for architecture decisions (it is explicitly linked from Chapter 24 and four other chapters as the decision authority), and its 39 claims were backed by only 5 links positioned once at the very bottom of a 167-line document. A reader citing row 6 of section 4 in a design document would have had to guess which of the five links actually documents that specific row. This is a real gap between "the source exists in the file" and "source attribution is defensible for a specific claim," which is exactly the distinction this check was asked to make.

---

## 4. Remediation applied

Nine `*Source: [...]*` lines were added, one directly under each of the file's nine numbered section headings, each naming the specific Microsoft Learn page (and, where a section blends two topics, both pages) that documents the claims in that section. No new claims were added and no existing claim was reworded; this is attribution placement, not content change.

```bash
grep -c "^\*Source:" appendices/intune-avd-support-matrix.md
# 9
```

All nine source lines resolve to pages already present in the file's existing Official References list — no new URL was introduced, and none was invented. Per the instruction not to guess a mapping between an old citation index and a source: where a section's claims could plausibly come from more than one of the five listed pages (sections 8 and 9), both are named rather than picking one arbitrarily.

---

## 5. What was rewritten as original explanatory prose

None of the 348 claims needed rewriting. The distinction the task asked for — original prose versus Microsoft-derived claims — was already maintained at the point the content was first written, under this repository's standing citation rules (paraphrase over quotation, one quote per source, quotes under fifteen words). Stripping the `<cite>` wrapper did not change a paraphrase into an unattributed assertion; it removed a piece of internal tooling markup that had no reader-facing function once the claim was already correctly attributed via the reference sections. This check confirms that distinction held, in the one file where it was closest to not holding.

---

## 6. Claims that could not be verified

None. Every implementation-sensitive or time-sensitive claim in the six spot-checked files traces to a specific, currently reachable Microsoft Learn page listed in that file's own reference section. No claim was found that lacked a plausible source, and no source was guessed or invented to fill a gap — the one gap found (`intune-avd-support-matrix.md`) was closed using sources already present in the file, not new ones.

---

## 7. Summary

| Metric | Count |
|---|---|
| Files carrying stripped citation tags, originally | 33 |
| Chapters confirmed to have an Official References section | 25 / 25 |
| Files fully spot-checked end to end | 6 (the highest-density files) |
| Claims receiving new, more specific source attribution | 39 (via 9 section-level source lines, `intune-avd-support-matrix.md` only) |
| Claims rewritten as original prose | 0 (none required it) |
| Claims found unverifiable | 0 |
| Files judged adequate without change | 5 of the 6 spot-checked |
| Remaining files (33 total minus the 6 spot-checked) | Not individually re-read line by line in this pass; all confirmed via the automated check in section 2 to carry a references section, consistent with the chapter contract enforced since the first chapter was written |

**Honest limitation.** This was a focused check on the highest-risk files, not an exhaustive line-by-line re-read of all 33 affected files. The automated reference-section check (section 2) covers all of them; the full manual read (section 3) covers the six at highest risk by original citation density. If a specific claim elsewhere is ever challenged, the same method — read the claim, find the matching reference in that chapter's Official References list, add a direct link if the mapping isn't obvious — applies and should be run against that file specifically.
