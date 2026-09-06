# Diagram Quality Standard

Every architecture diagram in this book has to be good enough to hand to an engineer as a production design. If someone cannot implement the architecture correctly from the diagram and its explanation, the diagram is not finished.

This sits alongside the [chapter contract](CHAPTER-CONTRACT.md) and the [diagram and attribution policy](diagrams/DIAGRAMS-AND-ATTRIBUTION.md), which covers labelling and Microsoft attribution.

---

## 1. What a diagram must do

Communicate the architecture, its components, its boundaries and the actual traffic or data flow the chapter is explaining. Not decorate the page.

Generic box and arrow drawings produced to satisfy a requirement are worse than no diagram, because they look like documentation and teach nothing.

---

## 2. Layers

Use clear logical layers, drawn as subgraphs, chosen from those that apply:

- User and client
- Identity
- AVD service, meaning the Microsoft managed control plane
- Network
- Session hosts
- Storage
- Management and monitoring
- On-premises and external services

A diagram that mixes a user, a firewall rule and a storage account at the same visual level is not showing an architecture.

## 3. Boundaries

Show the boundaries that matter to the decision being explained:

- Azure subscription and resource group boundaries
- Virtual network boundaries
- Hub and spoke boundaries
- Trust boundaries
- On-premises versus Azure
- Microsoft managed versus customer managed

The Microsoft managed versus customer managed boundary is the most important one in this book, because it is the split every troubleshooting decision starts from.

## 4. Arrows

Every arrow represents real traffic, authentication, control or data flow. No decorative arrows.

Label connections with the protocol, port, service or purpose when it is technically relevant. Show direction clearly. Where a path is explicitly not present, such as inbound RDP to a session host, show it as a dotted line with a label saying so, because absence is often the point.

## 5. Visual quality

The reader should understand the architecture in ten to fifteen seconds, before reading a word of explanation. If they cannot, the diagram has failed regardless of how accurate it is.

**A component box contains the component name and nothing else.** No second line, no address, no size, no configuration. `Session Host`, `Azure Firewall`, `Microsoft Entra ID`, `FSLogix Storage`. Everything else belongs in the text below the diagram.

Bad: `Teams client signalling and UI with WebRTC redirector service installed per session host`
Good: `Microsoft Teams`

**Arrow labels are short.** `HTTPS 443`, `RDP`, `Kerberos`, `profile mount`, `media`, `control`. Not sentences.

**Explanation goes below the diagram, never inside it.** No configuration values, registry keys, PowerShell, or troubleshooting steps inside architecture components. Architecture diagrams show what exists and how it interacts. Implementation detail belongs in the chapter text or in a separate implementation diagram.

**Visual weight is not uniform.** Use `classDef` to colour by ownership, and thicker link styles for the primary traffic path. A viewer must be able to see at a glance which components Microsoft manages and which the customer manages. The colour convention used throughout this book:

| Layer | Treatment |
|---|---|
| Microsoft managed | Solid dark blue fill, white text |
| Customer managed Azure | Light blue fill, dark text |
| On-premises | Warm neutral fill |
| Endpoint | White fill, dashed border |
| Blocked or failure path | Red fill, dashed red link |
| Optimised or preferred path | Thick green link |
| Not yet built in this lab | Grey fill, dashed border |

**Layout is deliberate.** Vertical flow for architecture layers, `direction LR` inside a subgraph to keep peers on one row, and as few crossing lines as possible. Split a diagram rather than letting it become unreadable. Two clear diagrams beat one dense one.

**Architecture and sequence are different diagrams.** Where order matters, draw a separate sequence diagram rather than numbering arrows on an architecture diagram until it becomes a flowchart.

Use the same term for the same component everywhere in the book. Broker service is always the broker service. Session host is always a session host.

## 6. Required explanation

Every important architecture diagram carries six sections immediately below it:

1. **What this diagram shows**
2. **Step by step flow**
3. **Architect's interpretation**
4. **Important design decisions**
5. **Failure points**
6. **Official Microsoft reference**

Decision flow diagrams, meaning diagrams whose purpose is to show how a choice is made rather than how a system is built, use a reduced set: what it shows, step by step, architect's interpretation, and the reference. Failure points do not apply to a decision tree, and inventing them would be filler. Where the reduced set is used, the chapter says so.

## 7. Diagram types

**Network diagrams** must distinguish inbound, outbound, Azure to Azure, Azure to on-premises, user to service, management and storage traffic.

**Identity diagrams** must distinguish authentication, authorization, Conditional Access, MFA, session host authentication and single sign-on. These are different things and conflating them is the cause of most identity troubleshooting failures.

**Troubleshooting diagrams** show the isolation path and the decision points, not just the components.

**HA and DR diagrams** show the primary region, the secondary region, dependencies, replication, failover direction, recovery sequence and where RTO and RPO apply.

**Lab diagrams** show exactly the resources the lab deploys. Nothing aspirational. If the lab does not create Azure Firewall, the lab diagram does not contain Azure Firewall.

**Scenario diagrams** are built from that scenario's requirements. A generic AVD diagram reused across fifteen scenarios teaches nothing about any of them.

## 8. Microsoft reference rule

Microsoft Learn diagrams are used as reference and inspiration. Their images are never copied or reproduced. See the [attribution policy](diagrams/DIAGRAMS-AND-ATTRIBUTION.md).

Where Microsoft publishes an official diagram for the topic:

1. Link to the Microsoft Learn page.
2. Explain what the Microsoft reference architecture demonstrates.
3. Create an original diagram for this book.
4. Keep the original technically consistent with the Microsoft documentation.

## 9. Technical verification

Before finalising a diagram, verify every technical detail against current Microsoft documentation. Ports, protocols, FQDNs, service names, Azure components, authentication flows, network paths, supported architectures, feature availability and limitations.

Never invent a connection, port, protocol or architectural relationship. If a detail cannot be verified, mark it `[VERIFY]` on the diagram rather than guessing.

## 9a. Two diagram tiers

Mermaid is the wrong tool for a solution architecture diagram. It cannot express zones inside zones reliably, it has no icon vocabulary, it produces no legend, and its layout engine decides the composition for you. Recognising that took longer than it should have.

**Tier 1, concept and decision diagrams. Mermaid.** Decision trees, sequence diagrams, object relationships, policy precedence, lifecycle flows. Mermaid is genuinely good at these and they stay inline in Markdown where they render on GitHub without an asset.

**Tier 2, solution architecture diagrams. SVG, with an editable draw.io source.** Anything showing a deployed architecture: current state, target state, network topology, multi-region designs, and the architecture diagram in every project.

A tier 2 diagram carries:

| Element | Requirement |
|---|---|
| Title and subtitle | Diagram name and the project or chapter it belongs to |
| Zones | Ownership and network boundaries, drawn as labelled containers |
| Service tiles | One Azure service per tile, correct Microsoft product name, glyph, and a short qualifier such as size or count |
| Flow arrows | Labelled with protocol or purpose, styled by type |
| Legend | Every line style used, explained |
| Provenance note | Stating this is an original diagram and not a Microsoft one |

**Layout grammar, applied consistently across the book.** Users on the left, Microsoft managed services in the middle, customer Azure on the right, on-premises below or to the far right, operational controls in their own band. A reader learns the grammar once.

**Colour, consistent with the tier 1 convention.** Azure blue for customer Azure resources, darker blue for Microsoft managed services, neutral grey for users and endpoints, warm neutral for on-premises, amber for a deliberate exception, red for a failure or blocked path, green for a control.

## 9b. Icons and licensing

Microsoft publishes an Azure Architecture Icons set with its own terms of use. This repository does not redistribute those icon files, for two reasons: the terms restrict redistribution, and a public repository that ships Microsoft's assets creates an obligation for anyone who forks it.

**What this book does instead.** SVG diagrams use original glyphs drawn in the Azure palette, with correct Microsoft product names on every tile. Alongside them, editable `.drawio` sources use the Azure shape library built into diagrams.net, so opening a source file renders official Azure iconography locally without those assets being committed here.

**If you want official icons in the published images**, download the Azure Architecture Icons set from Microsoft under its terms, open the `.drawio` source, and export. The layout, labelling and flows are already correct.

## 10. Format

Tier 1, Mermaid:

- A standalone `.mermaid` source file in `diagrams/`
- Embedded inline in the chapter Markdown, so it renders on GitHub

Tier 2, architecture:

- An `.svg` in `diagrams/architecture/`, referenced from the Markdown so it renders on GitHub
- An editable `.drawio` source alongside it where the diagram is likely to be adapted
- Both are text formats, so both are diffable and version controlled

Filenames are descriptive and chapter prefixed, for example `ch13-avd-egress-architecture.mermaid`.

## 10a. Only draw a diagram when it helps

Do not produce a diagram because a chapter is expected to have one. One excellent diagram beats three mediocre ones. Where a subject is complex, split it into two focused diagrams rather than overloading one.

Every diagram carries a title, set in the Mermaid frontmatter.

## 11. Final review, two passes

**Pass 1, technical accuracy.** Verify every component, relationship, protocol, port and traffic path against current Microsoft documentation.

**Pass 2, visual quality.** Answer each of these honestly:

1. Does this look like an architecture diagram rather than a flowchart?
2. Can I understand the architecture in ten to fifteen seconds?
3. Are the component names short?
4. Are there any paragraphs inside boxes?
5. Are ownership boundaries obvious?
6. Are the important traffic paths obvious?
7. Are arrows crossing unnecessarily?
8. Is the layout balanced?
9. Is the text readable on GitHub?
10. Does the diagram accurately represent the chapter?
11. Does it follow Azure architecture diagram conventions?
12. Would I show this in an Azure Architect design review?

If the answer to any of these is no, rebuild the diagram. Do not patch it.

The final gate is one question: **could an engineer understand the architecture and implement it correctly from this diagram and its explanation?**
