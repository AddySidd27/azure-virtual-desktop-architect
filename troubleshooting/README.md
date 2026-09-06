# Troubleshooting Runbooks

Five standalone, production-format runbooks. Each follows the [operations and troubleshooting standard](../OPERATIONS-AND-TROUBLESHOOTING-STANDARD.md): evidence collected before any remediation is attempted, and no runbook opens with "restart the VM," "reinstall the agent," or "resize the VM" as a first step: those are sometimes the correct fix, but only after evidence points at them.

| # | Runbook | Covers |
|---|---|---|
| 01 | [Session host cannot register](runbook-01-session-host-registration-failure.md) | Registration token expiry, image-capture registration conflicts, network path to the AVD service |
| 02 | [Desktop or RemoteApp not visible](runbook-02-desktop-remoteapp-not-visible.md) | Preferred application group type mismatch, assignment scope, group membership |
| 03 | [FSLogix profile fails to attach](runbook-03-fslogix-profile-attach-failure.md) | Kerberos/identity path failures, permission gaps by identity type, locked containers |
| 04 | [Slow sign-in / logon storm](runbook-04-slow-signin-logon-storm.md) | Decomposing logon time, storage IOPS ceilings, profile bloat, host capacity |
| 05 | [Poor connection quality](runbook-05-connection-quality-shortpath-teams.md) | RDP Shortpath transport fallback, Teams optimisation not engaging, endpoint security interference |

Each runbook contains: symptom, business impact, scope and recent-change questions, evidence to collect first, ranked initial hypotheses, a fast triage decision tree, root-cause indicators, remediation, validation, rollback, prevention, escalation criteria, evidence for a Microsoft support case, and official Microsoft references.

## Where this content came from

These runbooks generalise incident write-ups that already exist inside the book, rather than being written from scratch: [Chapter 18](../chapters/ch18-session-host-lifecycle-hybrid.md) and [Chapter 23](../chapters/ch23-golden-image-engineering.md) for registration and image-capture failures, [Chapter 19](../chapters/ch19-why-profiles-cause-avd-failure.md) through [Chapter 22](../chapters/ch22-profile-operations-failure-recovery.md) for FSLogix, [Project 02](../scenarios/project-02-enterprise-850-users.md) and [Project 07](../scenarios/project-07-call-centre-high-density.md) for logon storms and capacity, [Chapter 14](../chapters/ch14-protocol-optimisation-network-performance.md) and [Chapter 13](../chapters/ch13-hybrid-connectivity-egress-control.md) for connection quality, and [Project 10](../scenarios/project-10-remoteapp-line-of-business.md) for application group assignment failures. Each runbook links back to its source chapters and projects rather than duplicating their explanations.

## Navigation

Back to [the main book](../README.md) | [Full index](../SUMMARY.md) | [Operations standard](../OPERATIONS-AND-TROUBLESHOOTING-STANDARD.md)
