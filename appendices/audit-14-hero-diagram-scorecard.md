# Audit 14 - Hero Diagram Scorecard: All 10 Complete and Self-Contained

> **Internal development record.** Not required reading. See [Development history](development-history.md) for a summary.

**Date:** August 2026
**Trigger:** Diagram 4's Hub-Spoke rebuild exposed a repository-wide inconsistency: 3 of 10 `.drawio` sources (1, 5, 10) depended on remote Azure icon URLs while their matching `.svg` exports used a different, self-contained shape system — exactly the mismatch flagged as unacceptable. This audit fixes all 10 to one consistent, offline-safe standard and scores every diagram against the full checklist.

---

## Why remote icons were dropped entirely

Tested directly: `cairosvg` in this environment cannot fetch a remote image URL at render time (a test SVG referencing a live Azure icon URL rendered as a blank canvas). That means any `.drawio` source depending on `image=https://...` cannot be reliably reproduced as a matching, offline-renderable SVG in this environment, and a person opening the `.drawio` without network access would see the same blank result.

**Standard adopted for all 10 diagrams:** a single, consistent, self-contained vector shape system (rounded rectangles, simple internal glyphs, no external references) used identically in the `.drawio` source, the `.svg` export, and the rendered `.png`. This is the fallback explicitly permitted when official remote icons cannot be exported reliably: "a reliable professional diagram is better than broken official icons." Every diagram now uses correct Azure product names on every tile; what changed is the icon artwork, not the technical content or terminology.

---

## Scorecard, all 10 hero diagrams

| # | Diagram | `.drawio` exists | Self-contained (0 remote refs) | SVG export exists | PNG rendered + inspected | No clipping | No text overlap | No connector crossing text/components | Orthogonal routing | Correct arrow endpoints | Legend inside canvas | Attribution inside canvas | Text readable | Technical flow accurate | **Final approval** |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Complete enterprise reference | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ **PASS** |
| 2 | Connection/authentication flow | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ **PASS** |
| 3 | Join model comparison | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ **PASS** |
| 4 | Hub-spoke network | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ **PASS** |
| 5 | FSLogix permission flow | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ **PASS** |
| 6 | Golden image lifecycle | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ **PASS** |
| 7 | Monitoring/troubleshooting | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ **PASS** |
| 8 | Multi-region HA/DR | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ **PASS** |
| 9 | Terraform dependencies | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ **PASS** |
| 10 | Final MVP lab architecture | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ **PASS** |

**10 of 10 hero diagrams pass every scorecard item.**

---

## What changed in this pass, concretely

- **Diagram 4** rebuilt twice from scratch after the first two attempts (tile-based, then a single-peering-pivot layout) produced real, visible defects — converging connectors, overlapping labels, a clipped subtitle. The final version uses a clean two-column grid (Hub left, Spoke right, identical top Y and height), one isolated horizontal peering connector between the two VNet boundaries with nothing else sharing its lane, and 5 numbered flow statements replacing what had been ambiguous crossing arrows.
- **Diagrams 1, 5, 10** rebuilt from remote-icon `.drawio` sources to the same self-contained shape system already used in their `.svg` exports, closing the drawio/svg mismatch.
- **Diagrams 2, 3, 6, 7, 8, 9** gained `.drawio` sources for the first time this pass (their SVGs already existed and had passed visual QA in an earlier turn); the new `.drawio` sources mirror those SVGs' layout and content using the same self-contained tile system.

## Verification commands and results

```bash
# Self-containment, .drawio (10/10 pass)
grep -c 'image=' hero-*.drawio     # 0 for every file

# Self-containment, .svg (10/10 pass)
grep -o 'http[^"]*' hero-*.svg | grep -v w3.org   # no matches

# Structural bounds, .svg (10/10 pass)
# every element's x/y coordinates fall within the declared canvas width/height
```

## Honest note on parity

The `.drawio` and `.svg` for each diagram are built from the same layout coordinates and the same content, by the same process, and use the identical shape system — but they are two independently-authored files (this environment cannot export one directly from the other), not a single file in two formats. They were cross-checked by hand for label text, tile position, and connector endpoints matching, but a byte-for-byte diff was not run. Anyone editing one going forward should update the other to keep them in sync.

## Next

All 10 hero diagrams cleared. Per the standing instruction, repository-wide diagram remediation (Chapters 1-25, Labs 1-10, Projects 01/02/04-10, troubleshooting) begins next.
