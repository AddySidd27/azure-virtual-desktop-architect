# Current AVD Changes to Review

This page is a review aid, not a permanent feature-status guarantee. Check the linked Microsoft pages before using a recent capability in a production design.

**Last reviewed:** 6 September 2026

| Change | Current design impact |
|---|---|
| Session host configuration | Provides a service-managed configuration and update model for supported pooled host pools. The management approach is selected when the host pool is created. |
| Dynamic Autoscaling | Can create and delete session hosts for a pooled host pool that uses session host configuration. It is different from power-management autoscale. |
| Ephemeral OS disks | Supported for stateless AVD hosts only in pooled host pools using session host configuration, with documented disk, lifecycle, region, backup, and recovery limits. |
| Session host update | Replaces or deallocates existing VMs and creates hosts from the stored configuration. Plan user notification, capacity, image validation, and rollback. |
| RDP Multipath | Adds connection resilience options. Confirm current client, network, and feature requirements. |
| Windows App | Strategic client for supported platforms. Confirm client feature differences before a migration. |
| App Attach | Current application-attachment model. Include package storage and secondary-region access in recovery planning. |
| Azure Monitor Agent | Current monitoring agent used with Data Collection Rules for AVD Insights session-host data. |
| Windows update guidance | Choose patch-in-place or image-based servicing according to operating system, host-pool management approach, and lifecycle model. |

## Review before every design

1. AVD prerequisites and supported operating systems
2. Host-pool management approach and tooling support
3. Required FQDNs and endpoints
4. Client support and redirection features
5. Autoscale and session-host update behavior
6. FSLogix, Intune, image, application, and monitoring requirements
7. Regional availability, quota, pricing, preview status, and retirement dates

## Official Microsoft references

- [What's new in Azure Virtual Desktop](https://learn.microsoft.com/en-us/azure/virtual-desktop/whats-new)
- [What's new in AVD documentation](https://learn.microsoft.com/en-us/azure/virtual-desktop/whats-new-documentation)
- [Host-pool management approaches](https://learn.microsoft.com/en-us/azure/virtual-desktop/host-pool-management-approaches)
- [Windows update management for session hosts](https://learn.microsoft.com/en-us/azure/virtual-desktop/windows-update-management-methodologies-session-hosts)
- [Ephemeral OS disks on AVD](https://learn.microsoft.com/en-us/azure/virtual-desktop/deploy/session-hosts/ephemeral-os-disks)
