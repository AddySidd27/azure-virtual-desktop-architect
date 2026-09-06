# Source Verification

Technical content is checked against Microsoft Learn and the Azure Architecture Center. Terraform resource syntax also requires the official HashiCorp AzureRM provider documentation.

This register records the primary Microsoft source for each major topic. A source link does not prove that every design is valid for every tenant or region.

## Core service and prerequisites

| Topic | Primary Microsoft source | Last checked |
|---|---|---|
| AVD capabilities and responsibility split | [What is Azure Virtual Desktop?](https://learn.microsoft.com/en-us/azure/virtual-desktop/overview) | 2026-09-06 |
| Identity, OS, licensing, network, and session-host prerequisites | [AVD prerequisites](https://learn.microsoft.com/en-us/azure/virtual-desktop/prerequisites) | 2026-09-06 |
| Microsoft-managed and customer-managed components | [Service architecture and resilience](https://learn.microsoft.com/en-us/azure/virtual-desktop/service-architecture-resilience) | 2026-09-06 |
| Required session-host endpoints | [Required FQDNs and endpoints](https://learn.microsoft.com/en-us/azure/virtual-desktop/required-fqdn-endpoint) | 2026-09-06 |
| Licensing | [Licensing Azure Virtual Desktop](https://learn.microsoft.com/en-us/azure/virtual-desktop/licensing) | 2026-09-06 |

## Architecture and management

| Topic | Primary Microsoft source | Last checked |
|---|---|---|
| AVD enterprise landing zone | [Enterprise-scale support for AVD](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/azure-virtual-desktop/enterprise-scale-landing-zone) | 2026-09-06 |
| Standard and session host configuration approaches | [Host pool management approaches](https://learn.microsoft.com/en-us/azure/virtual-desktop/host-pool-management-approaches) | 2026-09-06 |
| Power-management and dynamic autoscale | [Autoscale scenarios](https://learn.microsoft.com/en-us/azure/virtual-desktop/autoscale-scenarios) | 2026-09-06 |
| Ephemeral OS disks for session hosts | [Ephemeral OS disks on AVD](https://learn.microsoft.com/en-us/azure/virtual-desktop/deploy/session-hosts/ephemeral-os-disks) | 2026-09-06 |
| Multi-region continuity | [Multi-region BCDR](https://learn.microsoft.com/en-us/azure/virtual-desktop/multi-region-bcdr) | 2026-09-06 |
| Session-host sizing | [Session-host VM sizing guidelines](https://learn.microsoft.com/en-us/windows-server/remote/remote-desktop-services/session-host-virtual-machine-sizing-guidelines) | 2026-09-06 |
| RDP Shortpath | [Configure RDP Shortpath](https://learn.microsoft.com/en-us/azure/virtual-desktop/configure-rdp-shortpath) | 2026-09-06 |

## Profiles, management, and applications

| Topic | Primary Microsoft source | Last checked |
|---|---|---|
| FSLogix profile storage | [Store FSLogix profiles](https://learn.microsoft.com/en-us/azure/virtual-desktop/store-fslogix-profile) | 2026-09-06 |
| FSLogix prerequisites | [FSLogix prerequisites](https://learn.microsoft.com/en-us/fslogix/overview-prerequisites) | 2026-09-06 |
| Intune for multi-session | [Windows Enterprise multi-session remote desktops](https://learn.microsoft.com/en-us/intune/solutions/azure-virtual-desktop-multi-session) | 2026-09-06 |
| Image templates | [Custom image templates](https://learn.microsoft.com/en-us/azure/virtual-desktop/custom-image-templates) | 2026-09-06 |
| App Attach | [App Attach overview](https://learn.microsoft.com/en-us/azure/virtual-desktop/app-attach-overview) | 2026-09-06 |

## Rules used during review

- Use the most specific AVD page for AVD support boundaries.
- Use the most specific current AVD feature page when a general prerequisite page and a newer feature page differ. Record the feature's exact host-pool, lifecycle, region, and preview limits.
- Use the live required-endpoint page when building firewall rules; copied endpoint tables become stale.
- Label fictional requirements and calculations as assumptions or worked examples.
- Do not convert a written validation procedure into a claim that the test was completed.
- Recheck dated product status statements before publication.

See [Validation Status](VALIDATION-STATUS.md) for implementation and test labels.
