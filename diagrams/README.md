# Diagram Index (Tier 1 - Mermaid)

Repository-wide diagram remediation is complete. These 18 files are the full, final set of Mermaid diagrams retained across the entire repository - every one independently classified as a small decision tree, a sequence, or a small object relationship, per [Audit 15](../appendices/audit-15-repository-diagram-inventory.md). No further diagrams are pending replacement.

Solution architecture diagrams live in [`architecture/`](architecture/README.md).

| File | Title | Type |
|---|---|---|
| `ch03-avd-object-model.mermaid` | AVD object model | Decision tree / small object relationship |
| `ch04-avd-connection-flow.mermaid` | AVD connection flow | Sequence |
| `ch05-session-host-os-decision.mermaid` | Session host OS decision | Decision tree / small object relationship |
| `ch06-client-path-decision.mermaid` | AVD client path decision | Decision tree / small object relationship |
| `ch07-join-model-decision.mermaid` | Session host join model decision | Decision tree / small object relationship |
| `ch08-authentication-sequence.mermaid` | AVD authentication sequence | Sequence |
| `ch11-egress-enforcement-points.mermaid` | Where AVD egress rules are enforced | Decision tree / small object relationship |
| `ch12-topology-decision.mermaid` | Landing zone topology decision | Decision tree / small object relationship |
| `ch15-broker-host-selection.mermaid` | Broker session host selection | Sequence |
| `ch15-pooled-vs-personal-decision.mermaid` | Pooled or personal host pool | Decision tree / small object relationship |
| `ch16-management-approach-decision.mermaid` | Host pool management approach decision | Decision tree / small object relationship |
| `ch24-session-host-enrolment-decision.mermaid` | Session host enrolment by join model | Decision tree / small object relationship |
| `lab07-object-model.mermaid` | Lab 7 - AVD object model, no hosts yet | Decision tree / small object relationship |
| `lab09-two-delivery-models.mermaid` | Lab 9 - two host pools, two delivery models | Decision tree / small object relationship |
| `project04-policy-decision-flow.mermaid` | Which policy authority set this value | Decision tree / small object relationship |
| `project05-dependency-disposition.mermaid` | Dependency disposition decision | Decision tree / small object relationship |
| `project05-entra-signin-sequence.mermaid` | Entra joined session host sign-in | Sequence |
| `project10-app-attach-lifecycle.mermaid` | App Attach package lifecycle on a session host | Sequence |
