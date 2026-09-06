# Production Readiness Checklist

Use this checklist before a pilot, production change, or go-live review. Record the owner, evidence link, and decision for every item. A checked box without evidence is not approval.

## 1. Scope and ownership

- [ ] Business owner, service owner, platform owner, identity owner, network owner, security owner, application owner, and service desk owner are named.
- [ ] User personas, locations, working hours, concurrency, application needs, and data classifications are approved.
- [ ] Availability, recovery, performance, security, and cost requirements are measurable.
- [ ] Microsoft-managed and customer-managed responsibilities are understood.
- [ ] Support boundaries and escalation contacts are documented.

## 2. Identity and access

- [ ] Session-host join model is approved and matches application and file-access dependencies.
- [ ] User assignment groups are separate from administrative groups.
- [ ] Azure RBAC uses the narrowest practical scope and role.
- [ ] Conditional Access targets the correct AVD applications and has been tested with pilot accounts.
- [ ] Emergency-access accounts are excluded only where required, monitored, and tested through an approved procedure.
- [ ] Service accounts, managed identities, certificates, secrets, and rotation owners are documented.

## 3. Network and name resolution

- [ ] Session-host subnets have enough addresses for normal growth, updates, and failure capacity.
- [ ] DNS resolution works for domain services, profile storage, applications, and private endpoints.
- [ ] Required AVD FQDNs and endpoints are allowed.
- [ ] The AVD Agent URL Tool passes from a representative session host.
- [ ] No public inbound RDP rule is required for normal AVD user connections.
- [ ] RDP Shortpath policy and firewall paths match the approved client and network design.
- [ ] Hybrid and cross-region routes have an identified owner and test result.

## 4. Host pools and session hosts

- [ ] Host-pool type, load-balancing mode, session limit, and application-group design match the personas.
- [ ] VM family, size, disk type, zones, quota, and regional capacity have been checked.
- [ ] Image version, installed applications, security controls, agents, and exclusions are recorded.
- [ ] New hosts register, report Available, pass health checks, and accept a pilot connection.
- [ ] Drain, user notification, replacement, rollback, and failed-update procedures are documented.
- [ ] Scaling schedules cover business hours, time zones, surge capacity, and user-impact controls.

## 5. Profiles, applications, and user data

- [ ] FSLogix identity model, share-level RBAC, NTFS permissions, private DNS, and network path are tested.
- [ ] Profile storage capacity, performance, redundancy, backup, restore, and alert thresholds are approved.
- [ ] Profile exclusions and container-size limits have been piloted.
- [ ] Application dependencies, licensing, packaging, update ownership, and rollback are recorded.
- [ ] RemoteApp names, icons, command-line settings, assignments, and feed visibility are tested.
- [ ] User data is stored outside disposable session-host operating-system disks.

## 6. Security and compliance

- [ ] MFA and Conditional Access are enforced for normal users and administrators.
- [ ] Defender, vulnerability management, security baselines, and supported endpoint controls are assigned.
- [ ] Clipboard, drive, printer, USB, camera, screen-capture, and watermarking decisions match data risk.
- [ ] Administrative access uses approved management paths and does not expose session hosts publicly.
- [ ] Logging retention, access, alert ownership, and audit evidence meet organizational requirements.
- [ ] Exceptions include a risk owner, compensating control, review date, and expiry date.

## 7. Monitoring and operations

- [ ] AVD resource diagnostics are sent to Log Analytics.
- [ ] Azure Monitor Agent, Data Collection Rules, performance counters, and Windows Event Logs are assigned to session hosts.
- [ ] AVD Insights configuration check is clean for the production host pools.
- [ ] Alerts cover service health, unavailable hosts, registration failures, connection failures, profile storage, capacity, and autoscale failures.
- [ ] Alert severity, notification route, responder, response target, and escalation path are documented.
- [ ] Service desk runbooks and known-error guidance are published and accessible during an incident.
- [ ] Daily, weekly, monthly, and quarterly operational reviews have named owners.

## 8. Resilience and recovery

- [ ] High availability and disaster recovery are documented as separate capabilities.
- [ ] Recovery requirements exist for session hosts, profiles, applications, user data, identity, network, images, and automation state.
- [ ] Secondary-region quota, capacity, DNS, identity, storage, images, and user assignment have been checked.
- [ ] Backup restore and regional recovery exercises have recorded results, duration, issues, and follow-up actions.
- [ ] Failback is documented and tested, not assumed from a successful failover.

## 9. Change, cost, and handover

- [ ] Terraform format, provider validation, plan review, approvals, and rollback evidence are attached to the change.
- [ ] Secrets, `.tfvars`, state, plan files, tokens, and private identifiers are not committed.
- [ ] Subscription budgets, cost alerts, tags, chargeback fields, and cost-review owners are configured.
- [ ] Pilot acceptance criteria and go/no-go authority are agreed.
- [ ] Operations receives architecture diagrams, dependencies, dashboards, alerts, runbooks, access, known risks, and open decisions.
- [ ] A post-go-live review date is scheduled.

## Official Microsoft references

- [AVD prerequisites](https://learn.microsoft.com/en-us/azure/virtual-desktop/prerequisites)
- [Security recommendations for AVD](https://learn.microsoft.com/en-us/azure/virtual-desktop/security-recommendations)
- [Enable AVD Insights](https://learn.microsoft.com/en-us/azure/virtual-desktop/insights)
- [AVD disaster recovery concepts](https://learn.microsoft.com/en-us/azure/virtual-desktop/disaster-recovery-concepts)
- [Required FQDNs and endpoints](https://learn.microsoft.com/en-us/azure/virtual-desktop/required-fqdn-endpoint)
