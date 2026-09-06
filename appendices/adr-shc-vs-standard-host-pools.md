# ADR: Standard Host-Pool Management and Power Management Autoscale, Not Session Host Configuration and Dynamic Autoscaling

**Status:** Accepted
**Date:** August 2026
**Applies to:** Labs 14-20
**Supersedes:** The Terraform deliverable descriptions for Lab 14 and Lab 17 in the original [Labs 11-20 plan](labs-11-20-plan.md), sections 3 and 1.3

---

## Context

The Labs 11-20 plan, as originally approved, called for Lab 14 to build Automated Host Pools using Session Host Configuration (SHC), and Lab 17 to use Dynamic Autoscaling on top of them, on the basis that both reached general availability on the Azure side in June 2026. That research was correct about the Azure-side feature status. It did not verify tooling support, and building Lab 14 surfaced a real gap: the tooling needed to actually build and manage SHC-based host pools is not production-ready, even though the underlying Azure feature is GA.

## What was verified, directly, before this decision

**Terraform.** No published, documented `azurerm_virtual_desktop_session_host_configuration` resource exists in the `hashicorp/azurerm` provider. The only reference found is [a GitHub feature-request issue (#28564)](https://github.com/hashicorp/terraform-provider-azurerm/issues/28564) discussing it as a proposal, not a shipped resource. Every current, working Terraform example for AVD, including Microsoft's own [`configure-azure-virtual-desktop`](https://learn.microsoft.com/en-us/azure/developer/terraform/configure-azure-virtual-desktop) guide and the official Azure Verified Module for host pools, builds the standard `azurerm_virtual_desktop_host_pool` resource, not an SHC-based one.

**PowerShell.** Microsoft's current configuration guidance says the Azure Virtual Desktop cmdlets for host pools that use session host configuration are in preview and require the preview Az.DesktopVirtualization module, version 5.3.0 or later ([session host update configuration](https://learn.microsoft.com/en-us/azure/virtual-desktop/session-host-update-configure)).

**AzAPI/ARM.** The `Microsoft.DesktopVirtualization/hostPools/sessionHostConfigurations` resource type has no non-preview API version in the Microsoft Learn version list. The newest version checked on 6 September 2026 is `2026-04-01-preview`. There is no stable API version to pin an AzAPI or ARM deployment to ([ARM template reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.desktopvirtualization/hostpools/sessionhostconfigurations)).

## Decision

Labs 14-20 build every required deployment using standard host-pool management: `azurerm_virtual_desktop_host_pool` (type `Pooled`, no SHC), Terraform-managed session host virtual machines, and the AVD agent and bootloader installed via VM extension, exactly the pattern Labs 7 and 8 already established and already validated for internal consistency in this book. Lab 17's autoscaling uses Power Management Autoscale (`azurerm_virtual_desktop_scaling_plan`), which every source confirms is GA and fully Terraform-supported, with one independent scaling plan per regional host pool.

Automated Host Pools and Session Host Configuration are covered in a clearly labelled optional section in Lab 14 and referenced from Lab 17, explaining the capability, its current tooling limitations, and what to check before relying on it in a real deployment. No lab in this set depends on it, deploys it, or claims to have tested it.

## Reasoning, against each factor requested

**Provider support.** Terraform is this book's primary infrastructure-as-code tool throughout Labs 1-20. A resource that doesn't exist in the provider cannot be used without either fabricating HCL that would fail on `terraform validate`, or silently switching away from Terraform for part of the build without saying so. Neither is acceptable. Standard host-pool management has full, mature, multi-year provider support.

**Preview API/tooling dependency.** All three tooling paths into SHC, Terraform, PowerShell, and AzAPI, are either absent or explicitly marked preview by Microsoft itself. Building a book's required lab path on three simultaneously-preview dependencies is a materially different risk than building on one preview feature with GA tooling around it. A reader following this book in six months has a real chance of hitting a breaking change in preview tooling that a GA path doesn't carry.

**Production supportability.** A design a reader might reasonably take into a real deployment should not require installing a preview PowerShell module or pinning to a preview ARM API version just to stand up the host pool itself. Standard host-pool management is what production AVD estates run today, including every project in this book's Projects 01-15.

**Portability.** Terraform-managed VMs with the AVD agent installed via extension is a pattern that transfers cleanly to any automation tooling, Bicep, ARM, Ansible, without dependency on a specific preview API surface. An SHC-based design, once built, is harder to unwind if the tooling around it changes shape before reaching stability.

**Future migration path.** This decision is explicitly not permanent. Once `azurerm_virtual_desktop_session_host_configuration` (or an equivalent) ships as a stable, documented Terraform resource, and the PowerShell and ARM API paths reach general availability, Labs 14 and 17 are structured so that migration is additive: the host pool object itself doesn't need to be rebuilt, only the session host management layer changes. The optional sections in Lab 14 and Lab 17 exist specifically to give a reader the vocabulary and the current state of that migration path, checked against Microsoft Learn at the time they read it, not frozen at this book's publication date.

## Consequences

Lab 14 and Lab 17 both take longer to reach an equivalent operational outcome than Automated Host Pools would in principle offer, since VM image updates go through the golden-image, drain-and-replace pattern (Chapter 23) rather than an in-place Session Host Update. This is accepted because the alternative was building required lab content on tooling this book cannot currently verify as production-safe. Every place SHC or Dynamic Autoscaling is mentioned going forward is clearly marked optional, sourced to current Microsoft Learn documentation, and carries an explicit instruction to re-check status before relying on it.
