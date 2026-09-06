# Hands-on Labs

These 20 labs form one progressive learning path. Complete prerequisites and cost checks before deploying Azure resources.

**Validation status:** all labs are documented practice procedures. This repository does not include Azure execution logs or other evidence that would justify calling them lab validated. Treat every command result as expected output until you run it in your own authorized subscription and retain evidence.

## Single-region path

| Lab | Outcome |
|---|---|
| [1](lab-01-azure-prerequisites-and-tooling.md) | Check subscription, permissions, quota, tools, and cost controls |
| [2](lab-02-terraform-foundation-and-governance.md) | Create the Terraform foundation and resource groups |
| [3](lab-03-vnet-subnets-nsg-dns.md) | Build the virtual network, subnets, NSGs, and DNS foundation |
| [4](lab-04-identity-integration.md) | Build the lab identity dependency |
| [5](lab-05-storage.md) | Build FSLogix profile storage and permissions |
| [6](lab-06-fslogix.md) | Configure and check FSLogix settings |
| [7](lab-07-avd-host-pool.md) | Create the host pool, application group, and workspace |
| [8](lab-08-session-hosts.md) | Deploy, join, register, and check session hosts |
| [9](lab-09-application-groups.md) | Configure application delivery and assignments |
| [10](lab-10-operations.md) | Configure scaling and monitoring, then run operational checks |

## Multi-region and recovery path

| Lab | Outcome |
|---|---|
| [11](lab-11-multiregion-network-foundation.md) | Build the second-region network foundation |
| [12](lab-12-regional-identity.md) | Add regional identity services |
| [13](lab-13-regional-storage-foundation.md) | Add regional profile storage |
| [14](lab-14-active-active-hostpools-workspaces.md) | Build separate regional host pools and workspaces |
| [15](lab-15-cloud-cache-replication.md) | Configure the Cloud Cache lab pattern |
| [16](lab-16-user-region-assignment.md) | Apply non-overlapping regional user assignment |
| [17](lab-17-regional-autoscaling.md) | Apply power-management autoscale by region |
| [18](lab-18-regional-security-monitoring.md) | Add regional security and monitoring controls |
| [19](lab-19-disaster-recovery-failover.md) | Build and evaluate an active-passive recovery pattern |
| [20](lab-20-validation-cost-teardown.md) | Validate the design, review cost, and remove lab resources |

## Lab rules

- Run labs only in an authorized Azure subscription.
- Read the prerequisites and cleanup section before deployment.
- Replace example identifiers and secrets without committing them.
- Check current Microsoft documentation before using time-sensitive settings.
- A written validation step is not proof that the test was run. Record sanitized evidence before marking a lab validated.
- Stop and remove resources when the practice session is complete.

See [Validation Status](../VALIDATION-STATUS.md) and the [Terraform index](../terraform/README.md).
