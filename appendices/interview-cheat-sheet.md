# Senior Interview Cheat Sheet

Use this structure for architecture and operations questions.

## Architecture answer structure

1. Restate the business requirement and affected users.
2. Identify identity, network, profile, application, security, operations, and recovery dependencies.
3. Present the realistic options.
4. Explain the trade-off and make a decision.
5. Describe validation, rollback, ownership, monitoring, and cost.

## Operations answer structure

1. Define the scope and business impact.
2. Check service health and recent changes.
3. Collect evidence and compare affected with healthy scope.
4. Change one thing at a time, starting with a reversible action.
5. Validate technically and with a controlled user test.
6. Record root cause, prevention, and escalation evidence.

## Questions a senior answer should cover

| Topic | Points to include |
|---|---|
| Design from scratch | Personas, concurrency, application dependencies, identity model, landing zone, network, profiles, host pools, images, security, monitoring, scaling, recovery, cost, pilot |
| Pooled or personal | Sharing, isolation, persistence, specialist software, administration, density, cost |
| Hybrid or Entra join | Application authentication, file access, management, SSO, domain dependencies, modernization path |
| FSLogix | Storage choice, identity, two permission layers, private DNS, performance, exclusions, backup, restore, locked containers |
| Multi-region | User placement, independent dependencies, capacity, data behavior, assignment, failover and failback |
| Security | MFA, Conditional Access, RBAC, endpoint controls, redirection, admin access, logging, emergency access, exceptions |
| Cost optimization | Persona sizing, concurrency measurement, autoscale, image and storage cost, monitoring ingestion, review cadence |
| Incident response | Scope, recent changes, evidence, affected versus healthy comparison, reversible action, validation, prevention |

## Credibility rules

- Say what you personally designed, implemented, tested, or operated.
- Separate a worked case study from real delivery experience.
- Do not claim a saving, recovery time, or production result without evidence.
- State assumptions and open decisions.
- If a feature changes quickly, say that you confirm current Microsoft guidance before implementation.

For all 193 questions and five mock interviews, use the [interview index](../interviews/interview-index.md).
