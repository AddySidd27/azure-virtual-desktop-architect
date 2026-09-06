# Architecture Diagrams

This folder contains editable draw.io sources and SVG copies that render on GitHub.

## Hiring-manager review set

Start with these diagrams:

| Diagram | Purpose | Editable source |
|---|---|---|
| [Northwind landing zone](capstone-landing-zone-architecture.svg) | Enterprise platform and AVD workload separation | [draw.io](capstone-landing-zone-architecture.drawio) |
| [Northwind identity and connectivity](capstone-identity-connectivity-topology.svg) | Regional hubs, spokes, hybrid identity, and connectivity | [draw.io](capstone-identity-connectivity-topology.drawio) |
| [Northwind governance](capstone-governance-control-plane.svg) | Policy, RBAC, PIM, and emergency access | [draw.io](capstone-governance-control-plane.drawio) |
| [Northwind AVD landing zone](capstone-avd-landing-zone.svg) | AVD subscriptions and workload boundaries | [draw.io](capstone-avd-landing-zone.drawio) |
| [Northwind AVD platform](capstone-avd-platform-architecture.svg) | Regional host pools, personas, and profiles | [draw.io](capstone-avd-platform-architecture.drawio) |
| [Terraform state architecture](capstone-terraform-state-architecture.svg) | State separation and layer dependencies | [draw.io](capstone-terraform-state-architecture.drawio) |
| [Operations and recovery](capstone-operations-dr-architecture.svg) | Monitoring, scaling, backup, and the DR gap | [draw.io](capstone-operations-dr-architecture.drawio) |

## Core learning diagrams

| Diagram | Purpose | Editable source |
|---|---|---|
| [Enterprise AVD reference](hero-01-complete-enterprise-reference.svg) | Main services and management boundaries | [draw.io](hero-01-complete-enterprise-reference.drawio) |
| [Connection and authentication](hero-02-connection-authentication-flow.svg) | User connection and sign-in flow | [draw.io](hero-02-connection-authentication-flow.drawio) |
| [Join model comparison](hero-03-join-model-comparison.svg) | Entra join and hybrid join | [draw.io](hero-03-join-model-comparison.drawio) |
| [Hub-and-spoke network](hero-04-hub-spoke-network.svg) | Network and egress design | [draw.io](hero-04-hub-spoke-network.drawio) |
| [FSLogix permission flow](hero-05-fslogix-permission-flow.svg) | Share-level RBAC and NTFS permissions | [draw.io](hero-05-fslogix-permission-flow.drawio) |
| [Golden image lifecycle](hero-06-golden-image-lifecycle.svg) | Build, test, publish, deploy, and rollback | [draw.io](hero-06-golden-image-lifecycle.drawio) |
| [Monitoring and troubleshooting](hero-07-monitoring-troubleshooting.svg) | Telemetry and investigation flow | [draw.io](hero-07-monitoring-troubleshooting.drawio) |
| [Multi-region HA and DR](hero-08-multiregion-ha-dr.svg) | Regional service and recovery design | [draw.io](hero-08-multiregion-ha-dr.drawio) |
| [Terraform dependencies](hero-09-terraform-dependencies.svg) | Lab deployment order | [draw.io](hero-09-terraform-dependencies.drawio) |
| [Final lab architecture](hero-10-final-mvp-lab-architecture.svg) | Labs 2-10 combined | [draw.io](hero-10-final-mvp-lab-architecture.drawio) |

## Diagram rules

- Maintain the `.drawio` file as the editable source.
- Export a matching `.svg` file for GitHub viewing.
- Use a diagram only when it makes a boundary, dependency, flow, or decision clearer.
- Label customer-managed and Microsoft-managed components correctly.
- Do not present a designed component as deployed or validated.
- Check technical labels against Microsoft Learn or the Azure Architecture Center.
- Keep resource names, regions, and status labels consistent with the related document.

## Viewing and editing

- Open `.svg` files in a browser or directly on GitHub.
- Open `.drawio` files in diagrams.net or the VS Code Draw.io Integration extension.

Back to the [main README](../../README.md) or [full contents](../../SUMMARY.md).
