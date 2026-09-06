# Audit 07 - Architecture Diagram Tier

**Date:** August 2026
**Trigger:** The diagrams did not look like Azure architecture diagrams, because Mermaid cannot produce them.
**Result:** A second diagram tier added. Project 09 rebuilt as the reference implementation. Remaining projects and chapters scheduled.

---

## 1. What was wrong

Six audits have been run on diagrams in this repository. Each one improved labels, layout, text length or topic accuracy, and each one worked within Mermaid. That was the mistake.

Mermaid is a good tool for a decision tree, a sequence or an object relationship. It cannot produce a solution architecture diagram, because it has:

- no icon vocabulary, so every component is a rectangle
- unreliable nesting of zones inside zones
- no legend
- a layout engine that decides the composition rather than the author

A reader comparing our diagrams with the Azure Architecture Center sees rectangles and arrows against a professional architecture drawing. The information was right. The artefact was not.

---

## 2. What changed

**Two tiers, defined in section 9a of the [diagram standard](../DIAGRAM-STANDARD.md).**

| Tier | Tool | Used for |
|---|---|---|
| 1, concept and decision | Mermaid, inline | Decision trees, sequences, object relationships, precedence flows, lifecycles |
| 2, solution architecture | SVG plus an editable draw.io source | Current state, target state, topology, every project architecture diagram |

**A tier 2 diagram requires** a title and subtitle, labelled zones, service tiles with correct Microsoft product names and a qualifier, labelled flow arrows, a legend, and a provenance note.

**A consistent layout grammar** across the book: users left, Microsoft managed centre, customer Azure right, on-premises below, operational controls in their own band.

**Editable source.** Each published SVG has a matching `.drawio` source. Make diagram changes in diagrams.net, then export the SVG from the same source so the pair stays aligned.

---

## 3. Icons, and an honest constraint

Microsoft publishes an Azure Architecture Icons set with terms of use that restrict redistribution. This repository does not commit those files, because a public repository shipping Microsoft's assets passes that obligation to anyone who forks it.

**What is done instead.** Original glyphs in the Azure palette, with correct product names on every tile, plus editable `.drawio` sources that use the Azure shape library built into diagrams.net. Opening a source file renders official Azure iconography locally without those assets being committed here.

Anyone who wants official icons in the published images downloads the set under Microsoft's terms, opens the `.drawio`, and exports. The layout and labelling are already correct.

---

## 4. Project 09 as the reference implementation

Three diagrams, replacing one Mermaid diagram.

| Diagram | What it communicates |
|---|---|
| Current state | Why the migration exists. Duplicated model data, nightly copies, two version incidents, no elastic capacity |
| GPU rendering path | Where the GPU sits between application and encoder, and the three independent failure points drawn as their own band |
| Production architecture | Four GPU pools sized by frame buffer, one model store both regions work from, and the operational controls that came from incidents |

The Mermaid version of the rendering path has been retired.

---

## 5. What happens to the existing diagrams

**Tier 1 diagrams stay as they are.** Decision trees in Chapters 5, 6, 7, 11, 12, 15, 16 and 24, sequences in Chapters 4, 8, 15 and Projects 05 and 10, and object relationship diagrams. Mermaid is the right tool for these and rebuilding them as SVG would make them worse.

**Tier 2 rebuilds, scheduled.** These are currently Mermaid and should be SVG:

| Diagram | Chapter or project |
|---|---|
| Service architecture | Chapter 2 |
| Egress architecture | Chapter 13 |
| Session host placement | Chapter 17 |
| FSLogix profile flow | Chapter 19 |
| Profile storage redundancy | Chapter 20 |
| Lab network and identity topology | Labs 3 and 4 |
| Project architecture diagrams | Projects 01, 02, 04, 05, 06, 07, 08, 10 |

**Sequencing.** New projects are written with tier 2 diagrams from the start. The backlog above is worked through in batches rather than in one pass, so it does not stall the remaining projects. This is recorded here so the backlog is visible rather than forgotten.

---

## 6. The lesson

Six audits inside a tool that could not produce the required output. The question each audit asked was whether the diagram was accurate, readable, or on topic. The question that was never asked was whether the tool was capable of the artefact.

When repeated review does not fix a problem, check whether the constraint is the work or the tool.
