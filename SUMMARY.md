# Table of Contents

> This is the current content map. Chapters 1-25, Labs 1-20, all 15 fictional architecture case studies, and the Northwind capstone design package are present. See [Validation Status](VALIDATION-STATUS.md) for the difference between documented, implemented, and lab validated.

- [Introduction](README.md)
- [Validation status](VALIDATION-STATUS.md)
- [Source verification](SOURCE-VERIFICATION.md)
- [Writing style guide](STYLE-GUIDE.md)
- [Operations and troubleshooting standard](OPERATIONS-AND-TROUBLESHOOTING-STANDARD.md)
- [Chapter contract](CHAPTER-CONTRACT.md)
- [Project standard](PROJECT-STANDARD.md)
- [Diagram quality standard](DIAGRAM-STANDARD.md)
- [Diagram style guide (locked)](DIAGRAM-STYLE-GUIDE.md)
- [Diagram index (Mermaid)](diagrams/README.md)
- [Architecture diagram index (SVG/drawio)](diagrams/architecture/README.md)
- [Diagram and attribution policy](diagrams/DIAGRAMS-AND-ATTRIBUTION.md)
- [Concept coverage map](appendices/concept-coverage-map.md)
- [Book master plan](appendices/book-master-plan.md)

---

## Part I - AVD Fundamentals

- [Chapter 1 - What Azure Virtual Desktop Actually Is](chapters/ch01-what-avd-actually-is.md)
- [Chapter 2 - Control Plane, Management Plane and Data Plane](chapters/ch02-control-plane-management-plane-data-plane.md)
  - [Lab 1 - Azure Prerequisites, Subscription, Quota and Tooling](labs/lab-01-azure-prerequisites-and-tooling.md)
- [Chapter 3 - The AVD Object Model](chapters/ch03-avd-object-model.md)
  - [Lab 2 - Terraform Foundation, Resource Groups and Governance](labs/lab-02-terraform-foundation-and-governance.md)
- [Chapter 4 - The Connection Flow, End to End](chapters/ch04-connection-flow-end-to-end.md)
  - [Lab 3 - Virtual Network, Subnets, NSGs and DNS](labs/lab-03-vnet-subnets-nsg-dns.md)
- [Chapter 5 - Operating Systems, Multi-session and Licensing](chapters/ch05-operating-systems-multisession-licensing.md)
- [Chapter 6 - Clients and the Endpoint Story](chapters/ch06-clients-and-the-endpoint-story.md)

## Part II - Identity and Authentication

- [Chapter 7 - Identity Architecture Foundations](chapters/ch07-identity-architecture-foundations.md)
  - [Lab 4 - Identity Integration](labs/lab-04-identity-integration.md)
- [Chapter 8 - Authentication Flows in Detail](chapters/ch08-authentication-flows-in-detail.md)
- [Chapter 9 - Conditional Access, MFA and Zero Trust Access](chapters/ch09-conditional-access-mfa-zero-trust.md)
- [Chapter 10 - RBAC, Delegation and the Administrative Model](chapters/ch10-rbac-delegation-administrative-model.md)

## Part III - Network Architecture

- [Chapter 11 - Network Fundamentals and Required Connectivity](chapters/ch11-network-fundamentals-required-connectivity.md)
- [Chapter 12 - Enterprise Topologies and IP Address Planning](chapters/ch12-enterprise-topologies-ip-planning.md)
- [Chapter 13 - Hybrid Connectivity and Egress Control](chapters/ch13-hybrid-connectivity-egress-control.md)
- [Chapter 14 - Protocol Optimisation and Network Performance](chapters/ch14-protocol-optimisation-network-performance.md)

## Part IV - Host Pool and Session Host Architecture

- [Chapter 15 - Host Pool Design Decisions](chapters/ch15-host-pool-design-decisions.md)
- [Chapter 16 - Automated Host Pools and Session Host Configuration](chapters/ch16-automated-host-pools-session-host-configuration.md)
- [Chapter 17 - Session Host Sizing and Compute Selection](chapters/ch17-session-host-sizing-compute-selection.md)
- [Chapter 18 - Session Host Lifecycle and Hybrid Session Hosts](chapters/ch18-session-host-lifecycle-hybrid.md)
  - [Lab 7 - Core AVD Objects](labs/lab-07-avd-host-pool.md)
  - [Lab 8 - Session Hosts](labs/lab-08-session-hosts.md)

## Part V - FSLogix, Profiles and Storage

- [Chapter 19 - Why Profiles Are the Number One Cause of AVD Failure](chapters/ch19-why-profiles-cause-avd-failure.md)
- [Chapter 20 - Profile Storage Architecture](chapters/ch20-profile-storage-architecture.md)
  - [Lab 5 - Profile Storage](labs/lab-05-storage.md)
- [Chapter 21 - FSLogix Production Implementation](chapters/ch21-fslogix-production-implementation.md)
  - [Lab 6 - FSLogix Configuration](labs/lab-06-fslogix.md)
- [Chapter 22 - Profile Operations, Failure and Recovery](chapters/ch22-profile-operations-failure-recovery.md)

## Part VI - Images, Endpoint Management and Application Delivery

- [Chapter 23 - Golden Image Engineering](chapters/ch23-golden-image-engineering.md)
- [Chapter 24 - Intune and AVD: Endpoint Management Architecture](chapters/ch24-intune-and-avd-endpoint-management.md)
- [Chapter 25 - Application Delivery Strategy and RemoteApp Design](chapters/ch25-application-delivery-remoteapp-design.md)
  - [Lab 9 - Application Delivery](labs/lab-09-application-groups.md)

App Attach in practice (originally planned as Chapter 26) is covered inside [Project 10](scenarios/project-10-remoteapp-line-of-business.md), per [Structure change 03](appendices/structure-change-03-project-led.md).

> **Lab numbering note.** Workspace creation was folded into Lab 7, and user assignment was included where application groups are created. Lab 10 covers scaling, monitoring, and operational validation. Labs 11-20 then extend the environment into multi-region design and validation.

## Part VII to X - Security, Monitoring, Scaling and HA/DR (as originally planned)

Chapters 27-38, as originally planned, were never written as standalone chapters. Per [Structure change 03](appendices/structure-change-03-project-led.md), every one of these topics is delivered inside a published project instead, at the point an engineer would actually need it. Nothing was dropped; the table below is the honest map from the old chapter number to where the content actually lives.

| Originally planned as | Delivered in |
|---|---|
| Ch 27 - Zero Trust reference architecture for AVD | [Project 11](scenarios/project-11-highly-secure-regulated.md) |
| Ch 28 - Session host and session hardening | [Project 06](scenarios/project-06-byod-remote-workforce.md), [Project 11](scenarios/project-11-highly-secure-regulated.md) |
| Ch 29 - Data, storage and administrative security | [Project 11](scenarios/project-11-highly-secure-regulated.md) |
| Ch 30 - Monitoring architecture | [Project 02](scenarios/project-02-enterprise-850-users.md) |
| Ch 31 - AVD Insights and the operational dashboard | [Project 02](scenarios/project-02-enterprise-850-users.md), [Project 03](scenarios/project-03-global-enterprise-governance.md) |
| Ch 32 - Day-2 operations and alerting | [Project 02](scenarios/project-02-enterprise-850-users.md), [Project 15](scenarios/project-15-production-troubleshooting.md) |
| Ch 33 - Scaling plans and dynamic autoscaling | [Project 07](scenarios/project-07-call-centre-high-density.md) |
| Ch 34 - Density and performance economics | [Project 07](scenarios/project-07-call-centre-high-density.md) |
| Ch 35 - Cost architecture | [Project 03](scenarios/project-03-global-enterprise-governance.md) |
| Ch 36 - HA within a region | [Project 13](scenarios/project-13-multi-region-architecture.md) |
| Ch 37 - Multi-region and DR architecture | [Project 13](scenarios/project-13-multi-region-architecture.md) |
| Ch 38 - Backup, recovery and DR testing | [Project 14](scenarios/project-14-disaster-recovery.md) |

Labs 11-20 are built: see the [Labs 11-20 plan](appendices/labs-11-20-plan.md) for the full ten-lab breakdown (multi-region network, regional identity and storage, active-active host pools, FSLogix Cloud Cache replication, user-region assignment, regional autoscaling and monitoring, contrasted active-passive DR, and end-to-end validation and teardown).

## Part XI - Architecture Case Studies

See the [project index](scenarios/README.md). These are 15 fictional case studies, each following the [project standard](PROJECT-STANDARD.md).

- [Project 01 - SMB, cost sensitive](scenarios/project-01-smb-cost-sensitive.md)
- [Project 02 - 850 user enterprise](scenarios/project-02-enterprise-850-users.md)
- [Project 03 - 3,000+ user global enterprise governance](scenarios/project-03-global-enterprise-governance.md)
- [Project 04 - Hybrid Active Directory](scenarios/project-04-hybrid-active-directory.md)
- [Project 05 - Entra-only, cloud native](scenarios/project-05-entra-only-cloud-native.md)
- [Project 06 - BYOD and remote workforce](scenarios/project-06-byod-remote-workforce.md)
- [Project 07 - Call centre, high density](scenarios/project-07-call-centre-high-density.md)
- [Project 08 - Developer and engineering](scenarios/project-08-developer-engineering.md)
- [Project 09 - GPU and CAD](scenarios/project-09-gpu-cad.md)
- [Project 10 - RemoteApp and line of business](scenarios/project-10-remoteapp-line-of-business.md)
- [Project 11 - Highly secure and regulated](scenarios/project-11-highly-secure-regulated.md)
- [Project 12 - Citrix to AVD migration](scenarios/project-12-citrix-migration.md)
- [Project 13 - Multi-region architecture](scenarios/project-13-multi-region-architecture.md)
- [Project 14 - Disaster recovery](scenarios/project-14-disaster-recovery.md)
- [Project 15 - Production troubleshooting](scenarios/project-15-production-troubleshooting.md)

All 15 of 15 projects are published. No project on the original plan remains outstanding.

## Part XIII and XIV - Automation and Troubleshooting Playbook (as originally planned)

| Originally planned as | Delivered in |
|---|---|
| Ch 42 - PowerShell and CLI operational toolkit | Distributed across projects, used at the point each is needed, not centralised |
| Ch 43 - Infrastructure as code for AVD | [Project 03](scenarios/project-03-global-enterprise-governance.md) |
| Ch 44 - Operational automation | [Project 03](scenarios/project-03-global-enterprise-governance.md), [Project 15](scenarios/project-15-production-troubleshooting.md) |
| Ch 45 - The 10-layer isolation method | [Project 15](scenarios/project-15-production-troubleshooting.md) |
| Ch 46 - Connection, access and identity failures | [Project 15](scenarios/project-15-production-troubleshooting.md), and the [troubleshooting runbooks](troubleshooting/README.md) |
| Ch 47 - Experience, profile, storage and performance failures | [Project 15](scenarios/project-15-production-troubleshooting.md), and the [troubleshooting runbooks](troubleshooting/README.md) |

Lab 20 is built as this lab set's end-to-end validation, cost, and teardown lab, mirroring Lab 10's role for Labs 1-9. Troubleshooting-specific hands-on labs remain covered by the standalone [troubleshooting runbooks](troubleshooting/README.md) rather than a dedicated numbered lab.

## Part XV-XVI - Interview Preparation

Chapters 48-51, as originally planned, were never written as standalone chapters. The content exists instead as a single [interview index](interviews/interview-index.md) (193 questions across chapters, labs and all 15 projects) plus five full mock interview scenarios in the same file. A separately assembled Part XV/XVI document, organised by seniority tier rather than by source chapter, has not yet been built; the underlying content is complete and indexed.

## Part XVII - Decision Frameworks

Chapter 52, as originally planned, was never written as a standalone chapter. Every project's architecture decisions section and ADRs (see, for example, [Project 03](scenarios/project-03-global-enterprise-governance.md#7-architecture-decision-records)) function as decision frameworks in practice. A separately assembled Part XVII document consolidating them into named decision matrices has not yet been built.

## Part XVIII - Capstone

- [Northwind capstone overview](capstone/README.md)
- [Part A - Discovery and requirements](capstone/parts/part-a-discovery-and-requirements.md)
- [Part B - Enterprise landing zone](capstone/parts/part-b-enterprise-landing-zone.md)
- [Part C - Identity and connectivity](capstone/parts/part-c-identity-connectivity-foundation.md)
- [Part D - Governance and security](capstone/parts/part-d-governance-security-foundation.md)
- [Part E - AVD landing zone](capstone/parts/part-e-avd-landing-zone.md)
- [Part F - AVD platform](capstone/parts/part-f-avd-platform-architecture.md)
- [Part G - Terraform implementation](capstone/parts/part-g-terraform-implementation.md)
- [Part H - Operations, DR, monitoring, and FinOps](capstone/parts/part-h-operations-dr-monitoring-finops.md)
- [Implementation tracker](capstone/implementation-tracker.md)

Northwind is a fictional reference architecture. Its complete design package is present; the full environment has not been deployed or production validated.

---

## Appendices

- [A - Book master plan](appendices/book-master-plan.md)
- [Intune and AVD Support Matrix](appendices/intune-avd-support-matrix.md)
- [Structure change 01 - Intune as a first-class topic](appendices/structure-change-01-intune.md)
- [B - Production Readiness Checklist](appendices/production-readiness-checklist.md)
- [C - Troubleshooting Cheat Sheet](appendices/troubleshooting-cheat-sheet.md)
- [D - Interview Cheat Sheet](appendices/interview-cheat-sheet.md)
- [E - PowerShell and Azure CLI Command Reference](appendices/command-reference.md)
- [F - KQL Query Library](appendices/kql-query-library.md)
- [G - Glossary and Abbreviations](appendices/glossary.md)
- [H - Current AVD Changes to Review](appendices/whats-new.md)

---

## Terraform

- [Lab 2 - Foundation](terraform/lab02-foundation/README.md)
- [Lab 3 - Network](terraform/lab03-network/README.md)
- [Lab 4 - Identity](terraform/lab04-identity/README.md)
- [Lab 5 - Storage](terraform/lab05-storage/README.md)
- [Lab 7 - Core AVD Objects](terraform/lab07-avd-core/README.md)
- [Lab 8 - Session Hosts](terraform/lab08-session-hosts/README.md)
- [Lab 9 - Application Delivery](terraform/lab09-app-delivery/README.md)
- [Lab 10 - Operations](terraform/lab10-operations/README.md)
- [Lab 11 - Multi-Region Network Foundation](labs/lab-11-multiregion-network-foundation.md)
- [Lab 12 - Regional Identity](labs/lab-12-regional-identity.md)
- [Lab 13 - Regional Storage Foundation](labs/lab-13-regional-storage-foundation.md)
- [Lab 14 - Active-Active Host Pools, Workspaces and Application Groups](labs/lab-14-active-active-hostpools-workspaces.md)
- [Lab 15 - FSLogix Cloud Cache Active-Active Replication](labs/lab-15-cloud-cache-replication.md)
- [Lab 16 - User-to-Region Assignment and Routing Strategy](labs/lab-16-user-region-assignment.md)
- [Lab 17 - Regional Autoscaling with Power Management Autoscale](labs/lab-17-regional-autoscaling.md)
- [Lab 18 - Regional Security and Monitoring](labs/lab-18-regional-security-monitoring.md)
- [Lab 19 - Disaster Recovery and Failover (Active-Passive)](labs/lab-19-disaster-recovery-failover.md)
- [Lab 20 - End-to-End Validation, Cost Control and Teardown](labs/lab-20-validation-cost-teardown.md)

The numbering gaps in the Terraform folders are intentional. Lab 1 is prerequisites only. Lab 6 configures FSLogix on resources created by other modules. Lab 15 uses the Lab 13 and Lab 14 resources. Lab 20 validates and removes the environment.

Lab 6 (FSLogix) has no dedicated Terraform module: it configures host-side registry settings and validates storage mechanics against resources Labs 4 and 5 already created, applied via `az vm run-command` in Lab 8 rather than as declared infrastructure. See [labs/lab-06-fslogix.md](labs/lab-06-fslogix.md) for the reasoning.

---

## Contributor and project-management history

This section is for anyone maintaining or auditing the repository, not for a reader following the book. It has no bearing on the technical content and is kept out of the primary navigation above for that reason.

See [Development history](appendices/development-history.md) for a summary of how the repository was built and reviewed in phases: diagram quality, the content retrofit, publication remediation, the multi-region labs, and the capstone build. The detailed pass-by-pass records it links to remain in the repository for full traceability.

**Structure changes**

- [Structure change 01 - Intune as a first-class topic](appendices/structure-change-01-intune.md)
- [Structure change 02 - Real-world projects expanded](appendices/structure-change-02-projects.md)
- [Structure change 03 - Project-led delivery](appendices/structure-change-03-project-led.md)

**Labs 11-20**

- [Labs 11-20 plan](appendices/labs-11-20-plan.md): active-active multi-region AVD, all 10 labs built and validated. Product-accuracy findings verified against current Microsoft Learn documentation: Regional Host Pools are Preview and explicitly excluded; Session Host Configuration's Terraform/PowerShell/AzAPI tooling is Preview or nonexistent (see the [ADR](appendices/adr-shc-vs-standard-host-pools.md)) and is therefore optional-only, not a required dependency; standard host-pool management and Power Management Autoscale are the required, GA-safe implementation throughout
- [Lab 19 correction report](appendices/lab-19-correction-report.md): two post-acceptance corrections to disaster recovery - removed the DR region's identity dependency on the failed region it was meant to protect (westus2 now peers to centralus as well as eastus2, with centralus's domain controller as primary), and corrected the Capacity Reservation cost model (bills continuously regardless of VM deployment, confirmed against Microsoft's own documentation; the variable now defaults off)
