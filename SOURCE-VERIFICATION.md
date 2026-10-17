# Source Verification

Technical content is checked against Microsoft Learn and the Azure Architecture Center. Terraform resource syntax also requires the official HashiCorp AzureRM provider documentation.

This register records the primary Microsoft source for each major topic. A source link does not prove that every design is valid for every tenant or region.

## Core service and prerequisites

| Topic | Primary Microsoft source | Last checked |
|---|---|---|
| AVD capabilities and responsibility split | [What is Azure Virtual Desktop?](https://learn.microsoft.com/en-us/azure/virtual-desktop/overview) | 2026-09-06; re-read 2026-10-16: page carries a deprecation notice, removal 30 October 2026 (U33) |
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

## Close-out pass, 2026-10-16 (Chapters 1 to 12)

All pages below were read on 2026-10-16 (Microsoft Learn). Process note: single reviewer. See `reviews/UNRESOLVED-ISSUES.md` for the issue each supports.

| Topic | Source | Section used | Issue |
|---|---|---|---|
| Regional host pools GA, managed identity GA, Dynamic autoscaling, SHC, Multipath | [What's new](https://learn.microsoft.com/azure/virtual-desktop/whats-new) | June to September 2026 entries | U1, U2, U3 |
| Regional deployment scope regions | [Data locations](https://learn.microsoft.com/azure/virtual-desktop/data-locations) | Regional deployment scope | U1 |
| SHC limits, West US 3 | [Prerequisites](https://learn.microsoft.com/azure/virtual-desktop/prerequisites), [Host pool management approaches](https://learn.microsoft.com/azure/virtual-desktop/host-pool-management-approaches) | Regions, session host configuration | U2 |
| Autoscale roles and scope, Dynamic autoscale | [Create and assign a scaling plan](https://learn.microsoft.com/azure/virtual-desktop/autoscale-create-assign-scaling-plan) | Prerequisites, Configure a time limit policy | U3, U21, U34 |
| Start VM on Connect roles and scope | [Start VM on Connect](https://learn.microsoft.com/azure/virtual-desktop/start-virtual-machine-connect) | Prerequisites | U21, U28 |
| Service principal and managed identity role assignment | [Assign roles to the AVD service principals](https://learn.microsoft.com/azure/virtual-desktop/service-principal-assign-roles) | Assign roles | U21 |
| Ephemeral OS disks | [Ephemeral OS disks](https://learn.microsoft.com/azure/virtual-desktop/deploy/session-hosts/ephemeral-os-disks), Prerequisites page | Limitations | U4 |
| Windows 10 ESU on AVD | [Understanding ESU](https://learn.microsoft.com/azure/virtual-desktop/understanding-extended-security-updates), [Enable ESU for virtual machines](https://learn.microsoft.com/windows/whats-new/enable-extended-security-updates-virtual) | AVD, VDI steps | U5 |
| Azure verification for VMs | [Azure verification](https://learn.microsoft.com/azure/azure-local/manage/azure-verification) | Supported OS | U6 |
| AVD on Azure Local | [Overview](https://learn.microsoft.com/azure/virtual-desktop/azure-local-overview) | Requirements | U7 |
| Legacy client dates | [Remote Desktop client overview](https://learn.microsoft.com/previous-versions/remote-desktop-client/overview) | Support dates | U8 |
| Windows App platforms | Windows App overview and get-started pages | Platforms | U9 |
| Connection states | [Diagnostics with Log Analytics](https://learn.microsoft.com/azure/virtual-desktop/diagnostics-log-analytics), [WVDConnections](https://learn.microsoft.com/azure/azure-monitor/reference/tables/wvdconnections) | Queries, columns | U10 |
| FQDN checks | [Required FQDNs](https://learn.microsoft.com/azure/virtual-desktop/required-fqdn-endpoint), [Check access](https://learn.microsoft.com/azure/virtual-desktop/check-access-validate-required-fqdn-endpoint) | Event 3701, URL tool | U11 |
| Cloud-only profiles on Azure Files | [Profile container with Entra ID](https://learn.microsoft.com/azure/virtual-desktop/create-profile-container-azure-ad), [Entra-joined session hosts](https://learn.microsoft.com/azure/virtual-desktop/azure-ad-joined-session-hosts), storage hybrid-identities enable page | Prerequisites, permissions | U13, U14, U15 |
| Entra Domain Services limits | Entra Domain Services FAQ and management VM tutorial | Admin rights, schema | U16 |
| MFA flow and app IDs | [Enforce MFA](https://learn.microsoft.com/azure/virtual-desktop/set-up-mfa) | Target apps, authentication flow | U19, U20 |
| KDC proxy | [Key distribution center proxy](https://learn.microsoft.com/azure/virtual-desktop/key-distribution-center-proxy) | Supported clients | U18 |
| Private Link | [Set up Private Link](https://learn.microsoft.com/azure/virtual-desktop/private-link-setup) | Sub-resources, DNS, clients | U22 |
| Cloud Sync and `.local` | [Cloud Sync prerequisites](https://learn.microsoft.com/entra/identity/hybrid/cloud-sync/how-to-prerequisites), [Nonroutable domain](https://learn.microsoft.com/microsoft-365/enterprise/prepare-a-non-routable-domain-for-directory-synchronization) | Requirements, UPN suffix | U30, U32 |
| Session lock and time limits | [Session lock behavior](https://learn.microsoft.com/azure/virtual-desktop/configure-session-lock-behavior), [Policy CSP ADMX_TerminalServer](https://learn.microsoft.com/windows/client-management/mdm/policy-csp-admx-terminalserver) | Policy names and paths | U34 |
| CAF deprecation | [Enterprise-scale landing zone](https://learn.microsoft.com/azure/cloud-adoption-framework/scenarios/azure-virtual-desktop/enterprise-scale-landing-zone) | Deprecation notice | U33 |
| Built-in roles | [RBAC for AVD](https://learn.microsoft.com/azure/virtual-desktop/rbac) | Power On roles | U21 |

### Added 2026-10-17 (final readiness gate)

| Topic | Primary Microsoft source | Finding | Issue |
|---|---|---|---|
| Private endpoint network policies (NSG bypass) | [Manage network policies for private endpoints](https://learn.microsoft.com/azure/private-link/disable-private-endpoint-network-policy), [Inspect traffic](https://learn.microsoft.com/azure/private-link/inspect-traffic-with-azure-firewall) | Policies disabled by default, NSG bypassed until enabled (2026-10-17) | U23 |
| Name resolution for VMs and custom DNS | [Name resolution for VMs](https://learn.microsoft.com/azure/virtual-network/virtual-networks-name-resolution-for-vms-and-role-instances) | Forwarding timeout above 4 seconds, port 53 bypasses NSGs (2026-10-17) | U27 |
| Resource provider registration | [Resource providers and types](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-providers-and-types), AVD prerequisites | Microsoft.DesktopVirtualization registration needs */register/action (2026-10-17) | U26 |
| Autoscale role scope | [Troubleshoot autoscale](https://learn.microsoft.com/troubleshoot/azure/virtual-desktop/troubleshoot-autoscale), [Create and assign a scaling plan](https://learn.microsoft.com/azure/virtual-desktop/autoscale-create-assign-scaling-plan) | Pages disagree on role scope (2026-10-17) | U35 |
| Re-verified unchanged (2026-10-17) | Autoscale scenarios, Prerequisites, Ephemeral OS disks, Windows App get-started, KDC proxy, azure-ad-joined-session-hosts, Intune MSIX guidance | No new evidence | U3, U4, U8, U9, U12, U15, U18 |

Not verified in this pass: Windows 365, AVD Hybrid (Arc) and managed identity beyond the What's new entries. Chapter 1 statements on them rest on What's new only.

## Editorial re-check, 17 October 2026

| Topic | Sources read (retrieved 17 October 2026) | Result | Issue |
|---|---|---|---|
| RDP Shortpath (Ch4) | [RDP Shortpath for Azure Virtual Desktop](https://learn.microsoft.com/en-us/azure/virtual-desktop/rdp-shortpath) | Ports, ranges, selection and security statements match. Four wording corrections in Chapter 4 | none new |
| Single sign-on (Ch8) | [Configure single sign-on](https://learn.microsoft.com/en-us/azure/virtual-desktop/configure-single-sign-on) | Prerequisites and steps match. Client list and external identity requirement added | U15, U18 unchanged |
| Conditional Access for AVD (Ch9) | [set-up-mfa](https://learn.microsoft.com/en-us/azure/virtual-desktop/set-up-mfa) | Matches. One stale table row corrected | none |
| Required endpoints (Ch11, Lab 3) | [required-fqdn-endpoint](https://learn.microsoft.com/en-us/azure/virtual-desktop/required-fqdn-endpoint) | Service tag error corrected | none |
| Private endpoint network policies (U23) | [Manage network policies for private endpoints](https://learn.microsoft.com/azure/private-link/disable-private-endpoint-network-policy) | New CLI parameter and ARM values recorded | U23 open |
| Start VM on Connect scope (U28) | [Configure Start VM on Connect](https://learn.microsoft.com/azure/virtual-desktop/start-virtual-machine-connect) | Lower scope guidance corrected by Learn; matches Ch10 | U28 open |
| AzureRM 5.0 provider registration | [HashiCorp announcement](https://www.hashicorp.com/blog/terraform-azurerm-provider-50-now-generally-available) | No providers registered by default; upgrade guide not retrievable | U26 open |
