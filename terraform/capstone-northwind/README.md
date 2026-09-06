# Northwind Terraform Reference

This is the Terraform reference implementation for the fictional Northwind AVD architecture. It has not been applied as one complete customer environment.

## Layers

| Layer | Directories | Responsibility |
|---|---|---|
| Enterprise platform | `platform/` | Management groups, connectivity, identity, policy, RBAC, security, monitoring, and budgets |
| AVD landing zone | `avd-landing-zone/` | Workload subscriptions, spokes, AVD policy, and delegated RBAC |
| AVD platform | `avd-platform/` | Host pools, application groups, workspaces, FSLogix, autoscale, monitoring, and backup |

The layers use separate state because they have different responsibilities and change rates. Downstream modules read only the outputs they require.

## Safe review order

1. `platform/management-groups`
2. `platform/connectivity`, `platform/identity`, and `platform/monitoring`
3. `platform/policy`, `platform/rbac`, `platform/security`, and `platform/finops`
4. `avd-landing-zone/network-spokes`, `policy`, and `rbac`
5. `avd-platform/fslogix` and `host-pools`
6. `avd-platform/workspace-appgroups`, `autoscaling`, `monitoring`, and `backup`

This order describes dependencies. It is not an authorization to apply the modules.

## Before use

- Review the related [capstone documents](../../capstone/README.md) and ADRs.
- Replace all example identifiers and backend settings.
- Confirm subscriptions, management-group access, provider registration, quota, regions, DNS, identity, and licensing.
- Run formatting, initialization, provider validation, and a reviewed plan in every module.
- Resolve all `VERIFY BEFORE IMPLEMENTATION` notes that apply to the target environment.
- Test backup restore and recovery procedures; policy configuration alone is not recovery evidence.

See [Validation Status](../../VALIDATION-STATUS.md).
