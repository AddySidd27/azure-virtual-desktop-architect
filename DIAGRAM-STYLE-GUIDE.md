# Diagram Style Guide - SUPERSEDED, kept for history only

**This file is superseded.** It described a remote-icon approach (`app.diagrams.net/img/lib/azure2/...`) that was tried and then explicitly rejected during the repository-wide diagram remediation (see [Audit 14](appendices/audit-14-hero-diagram-scorecard.md), section "Why remote icons were dropped entirely"). Every diagram in this repository, without exception, uses the self-contained vector shape system instead: no external image references, verified by `grep -c 'image=' *.drawio` returning zero across the entire repository as of [Audit 16](appendices/audit-16-diagram-remediation-closing-report.md).

**Do not follow the icon registry below for new diagrams.** Use the self-contained tile-and-zone system already in use throughout `diagrams/architecture/`: rounded rectangles, simple internal glyphs (a circle-with-checkmark for a managed service, a monitor icon for a client, a cylinder for storage, and so on), built directly in the `.drawio` XML and matched exactly in the `.svg` export, with every diagram rendered to PNG and visually inspected before being considered complete. [DIAGRAM-STANDARD.md](DIAGRAM-STANDARD.md) remains current for layering, boundaries and content requirements; only the icon-sourcing section below is superseded.

The original content is preserved below for historical reference only.

---


---

## 1. Icon registry

Every service below has one locked style string, used identically everywhere it appears. Do not substitute a different icon for the same service in a later diagram.

| Service | Style |
|---|---|
| Windows Virtual Desktop / AVD service | `image;aspect=fixed;html=1;image=https://app.diagrams.net/img/lib/azure2/other/Windows_Virtual_Desktop.svg;` |
| Virtual Network | `shape=mxgraph.azure.virtual_network;fillColor=#00BEF2;strokeColor=none;` |
| Subnet | `image;aspect=fixed;html=1;image=https://app.diagrams.net/img/lib/azure2/networking/Subnet.svg;` |
| Microsoft Entra ID | `image;aspect=fixed;html=1;image=https://app.diagrams.net/img/lib/azure2/identity/Azure_Active_Directory.svg;` |
| Virtual Machine / session host | `shape=mxgraph.azure.virtual_machine;fillColor=#00BEF2;strokeColor=none;` |
| Storage Account | `image;aspect=fixed;html=1;image=https://app.diagrams.net/img/lib/azure2/storage/Storage_Accounts.svg;` |
| Azure Files | `image;aspect=fixed;html=1;image=https://app.diagrams.net/img/lib/azure2/general/Storage_Azure_Files.svg;` |
| Azure NetApp Files | `image;aspect=fixed;html=1;image=https://app.diagrams.net/img/lib/azure2/storage/Azure_NetApp_Files.svg;` |
| Log Analytics Workspace | `image;aspect=fixed;html=1;image=https://app.diagrams.net/img/lib/azure2/analytics/Log_Analytics_Workspaces.svg;` |
| Azure Firewall | `image;aspect=fixed;html=1;image=https://icons.diagrams.net/assets/azure/1/Azure_Firewall.svg;` |
| Private Endpoint | `image;aspect=fixed;html=1;image=https://app.diagrams.net/img/lib/azure2/networking/Private_Endpoint.svg;` |
| Key Vault | `image;aspect=fixed;html=1;image=https://icons.diagrams.net/assets/azure/1/Key_Vault.svg;` |
| Users | `image;aspect=fixed;html=1;image=https://icons.diagrams.net/assets/azure/1/Users.svg;` |
| Microsoft Intune (device configuration) | `image;aspect=fixed;html=1;image=https://app.diagrams.net/img/lib/azure2/intune/Device_Configuration.svg;` |
| ExpressRoute | `image;aspect=fixed;html=1;image=https://icons.diagrams.net/assets/azure/1/Express_Route.svg;` |
| Load Balancer | `shape=mxgraph.azure.load_balancer_generic;fillColor=#00BEF2;strokeColor=none;` |

All `image;` styles carry `points=[];align=center;fontSize=12;` for consistent label placement, omitted above for brevity.

**Where no official icon fits** (a specific application, a third-party system, an on-premises server class without its own Azure icon), use a plain rounded rectangle in the on-premises or customer-workload colour from the palette below, labelled with the correct product name. Do not invent a pictorial icon.

---

## 2. Boundaries

| Boundary | Style |
|---|---|
| Subscription / resource group | Dashed rounded rectangle, `strokeColor=#605E5C`, label top-left, uppercase |
| Virtual network | Solid rounded rectangle, `strokeColor=#0078D4`, label top-left |
| Subnet | Solid rounded rectangle inside a VNet, `strokeColor=#50A0E0`, thinner stroke |
| Microsoft-managed boundary | Solid fill `#EFF6FC`, `strokeColor=#0078D4` |
| Customer Azure boundary | Solid fill `#F5F9FD`, `strokeColor=#0078D4` |
| On-premises boundary | Solid fill `#FBF7F0`, `strokeColor=#8A7A5C` |
| User / endpoint boundary | Dashed, `strokeColor=#605E5C`, no fill |
| Deliberate exception | Solid fill `#FDF6EC`, `strokeColor=#B77300` |

Only include boundaries relevant to that diagram. A diagram with no on-premises component has no on-premises boundary.

---

## 3. Colour taxonomy

| Meaning | Colour |
|---|---|
| Microsoft managed service | `#0078D4` (Azure blue) |
| Customer Azure resource | `#0078D4` fill on icon, `#F5F9FD` zone fill |
| On-premises | `#8A7A5C` |
| User / endpoint | `#605E5C` |
| Normal flow | `#243A5E`, solid, 2pt |
| Policy or control flow | `#107C10` (green), dashed |
| Deliberate exception, reviewed | `#B77300` (amber) |
| Blocked or failure path | `#A4262C` (red), dashed |

---

## 4. Lines and arrows

- Solid, 2pt, `#243A5E`: primary data or session traffic.
- Dashed, `#107C10`: a policy, configuration or control action rather than user traffic.
- Dashed, `#A4262C`: a blocked path, or a path shown to explain what does *not* happen.
- Every arrow that matters carries a short label: protocol, purpose, or both. `RDP`, `SMB 445`, `broker`, `sign in`.
- Edge routing: `routing: "libavoid"` on every hand-placed architecture diagram, so wires clear the boxes without moving the layout.

---

## 5. Typography and labels

- Diagram title: 20pt, `#243A5E`, top-left.
- Subtitle: 13pt, `#605E5C`, directly below the title, naming the project or chapter.
- Zone label: 12-13pt, bold, uppercase, the zone's own colour.
- Tile label: service name in the correct current Microsoft product name, 12-13pt, with a one or two line qualifier in 11pt grey where useful (size, count, role).
- Never abbreviate a product name on first appearance in a diagram.

---

## 6. Legend

Every diagram with more than one line style or boundary type carries a small legend, bottom-right or bottom-left, listing each style used and its meaning. A diagram with only one flow type may omit it.

---

## 7. Metadata and provenance

Every diagram carries, as a footer or as `.drawio` custom properties:

- Title
- Project or chapter reference
- Status: `OUR ORIGINAL ARCHITECTURE DIAGRAM`, `RECOMMENDED ARCHITECTURE`, `EXAMPLE CUSTOMER ARCHITECTURE`, or `LAB ARCHITECTURE`
- A note that this is an original diagram, not a Microsoft one, and that product names are Microsoft trademarks

---

## 8. File and repository conventions

- Every solution architecture diagram exists as an editable `.drawio` source and a rendered `.svg`, both in `diagrams/architecture/`.
- Filename pattern: `<chapter-or-project><NN>-<short-name>.svg` / `.drawio`, matching the existing project and chapter numbering.
- The `.svg` is what the Markdown embeds, so it renders on GitHub without a viewer.
- The architecture diagram index at `diagrams/architecture/README.md` lists every file, its purpose, and its source project or chapter, and is updated whenever a diagram is added or replaced.
- Tier 1 diagrams (decision trees, sequences, object relationships) remain Mermaid in `diagrams/`, per section 9a of [DIAGRAM-STANDARD.md](DIAGRAM-STANDARD.md), and are not migrated.

---

## 9. Icon licensing position

No Microsoft icon asset files are committed to this repository. Diagrams reference official icons by URL from Microsoft's own icon service, and `.drawio` sources use the built-in Azure shape library in diagrams.net. Neither redistributes Microsoft's icon files inside this repository. See [DIAGRAM-STANDARD.md](DIAGRAM-STANDARD.md) section 9b for the full reasoning.
