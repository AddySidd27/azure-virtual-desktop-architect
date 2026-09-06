# Azure Virtual Desktop Architect Portfolio

I created this repository to show how I approach Azure Virtual Desktop as an architect and an engineer. I start with business requirements, identify dependencies and risks, make the architecture decisions, document why I made them, and then translate the design into Terraform, diagrams, validation steps, and operational runbooks.

The repository also gives me one place to practise and revise AVD, and gives other engineers a structured learning path they can follow.

## What I designed and implemented

- I designed a fictional 3,200-user enterprise AVD platform from discovery through landing-zone integration, identity, networking, security, host pools, FSLogix, application delivery, monitoring, scaling, backup, and recovery planning.
- I separated the enterprise platform, AVD landing zone, and AVD workload so ownership, policy inheritance, network dependencies, and Terraform state boundaries are clear.
- I created reusable Terraform modules for both progressive labs and the enterprise reference design.
- I documented architecture decisions instead of presenting one design as the only answer. Each major choice records the requirement, options, trade-offs, risk, and decision.
- I built operational material for session-host health, profile failures, user entitlement, connection quality, RDP Shortpath, scaling, monitoring, and incident troubleshooting.
- I created editable draw.io architecture diagrams and matching SVG exports so every design can be reviewed on GitHub and updated later.

## Recent hands-on AVD work behind this portfolio

This portfolio builds on hands-on projects I completed while developing and testing my AVD engineering skills:

| Project | What I completed | What it demonstrates |
|---|---|---|
| Terraform AVD foundation | Deployed a pooled host pool with two session hosts, application-group assignment, and Azure Files for FSLogix; confirmed the hosts were available and a user profile container was created | End-to-end AVD deployment, access assignment, session-host registration, and profile validation |
| Autoscale and cost optimization | Configured and tested an AVD scaling plan, schedule phases, host-pool association, and operational checks | Capacity planning, power management, user-impact controls, and cost awareness |
| Golden image engineering | Designed the image workflow used to standardize session hosts and support repeatable replacement | Image versioning, validation, controlled rollout, and session-host lifecycle planning |

The Northwind organization and the 15 named scenarios in this repository are fictional. I use them to demonstrate architecture decisions without presenting invented customer work as professional delivery history. The complete Northwind environment has not been deployed as one production platform. See [Validation Status](VALIDATION-STATUS.md) for the exact evidence boundary.

## Hiring manager: recommended review path

1. [Northwind enterprise case study](capstone/README.md) - how I worked from requirements to a 3,200-user AVD reference architecture.
2. [Architecture decisions](capstone/adr/) - how I evaluated alternatives and recorded design decisions.
3. [Terraform implementation](terraform/capstone-northwind/) - how I separated platform, landing-zone, and AVD workload modules.
4. [Architecture diagrams](diagrams/architecture/README.md) - the design views I use to explain ownership, dependencies, and traffic flow.
5. [Citrix-to-AVD migration](scenarios/project-12-citrix-migration.md) - how I would assess, plan, pilot, migrate, and stabilize a workload.
6. [Simulated production incident](scenarios/project-15-production-troubleshooting.md) - how I isolate a fault and control changes under pressure.
7. [Final architecture and operations review](FINAL-REVIEW.md) - the Senior Solutions Architect and Senior Operations Engineer assessment.
8. [Validation status](VALIDATION-STATUS.md) and [Terraform validation record](TERRAFORM-VALIDATION.md) - what passed and what still requires GitHub or Azure execution.

![Northwind enterprise landing zone](diagrams/architecture/capstone-landing-zone-architecture.svg)

## Capabilities demonstrated

| Area | What I demonstrate |
|---|---|
| Architecture | Enterprise landing zone, AVD landing zone, identity, networking, security, profiles, applications, monitoring, scaling, and recovery planning |
| Infrastructure as code | Terraform modules for the learning labs and Northwind reference design |
| Hands-on learning | 20 labs that progress from prerequisites to multi-region validation and cleanup |
| Business scenarios | 15 case studies covering different user, security, performance, cost, and migration requirements |
| Operations | Monitoring, FSLogix, session-host health, connection quality, scaling, and troubleshooting runbooks |
| Interview preparation | Topic-based questions with short answers, senior answers, follow-up points, and scenario discussions |
| Diagrams | Editable draw.io sources with matching SVG files for GitHub viewing |

## Business use cases covered

| Use case | Architecture response |
|---|---|
| Cost-sensitive small business | Right-sized pooled desktops, autoscale, simple operations, and clear cost limits |
| Large enterprise deployment | Landing-zone integration, subscription separation, delegated administration, policy, monitoring, and repeatable Terraform |
| Global and multi-region workforce | Regional host pools, identity and storage dependencies, non-overlapping user assignment, and recovery planning |
| Hybrid Active Directory | Domain connectivity, DNS, site placement, Kerberos dependencies, and controlled modernization |
| Microsoft Entra joined session hosts | Cloud-first identity with application and file-access dependency assessment |
| BYOD and remote access | Conditional Access, endpoint trust levels, redirection controls, and protected access paths |
| High-density call centre | Persona-based sizing, shift-aware scaling, application isolation, and surge-capacity planning |
| Developer and engineering desktops | Personal and pooled choices, administrative boundaries, specialist tools, and lifecycle ownership |
| GPU and CAD workloads | GPU sizing validation, certified driver control, data locality, and performance monitoring |
| RemoteApp delivery | Application grouping, App Attach, entitlement, dependency mapping, and packaging limits |
| Regulated environment | Least privilege, policy, logging, break-glass access, and evidence-based exceptions |
| Citrix migration | Discovery, application mapping, user waves, coexistence, rollback, and stabilization |
| Disaster recovery | Dependency mapping, recovery sequence, capacity decisions, failover tests, and evidence collection |
| Production troubleshooting | A structured isolation method across access, identity, network, host, profile, storage, and application layers |

## Architecture model

I keep the enterprise platform separate from the AVD workload:

| Layer | Responsibility |
|---|---|
| Enterprise platform | Management groups, shared identity, connectivity, policy, monitoring, and security services |
| AVD landing zone | AVD subscriptions, workload policies, workload networking, and delegated administration |
| AVD platform | Host pools, application groups, workspaces, session hosts, FSLogix, scaling, and monitoring |

Official architecture references:

- [Azure landing zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
- [Enterprise-scale support for Azure Virtual Desktop](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/azure-virtual-desktop/enterprise-scale-landing-zone)

## Learning and practice path

### 1. Learn the core topics

Read [Chapters 1-25](SUMMARY.md) in order. They cover service architecture, identity, networking, host pools, session hosts, FSLogix, images, Intune, applications, security, monitoring, scaling, and recovery planning.

### 2. Build the lab environment

Follow [Labs 1-20](labs/) in order:

- Labs 1-10: single-region foundation, AVD deployment, profiles, applications, scaling, monitoring, validation, and cleanup.
- Labs 11-20: multi-region networking, identity, storage, host pools, assignment, scaling, security, disaster recovery design, validation, and teardown.

The lab documents include prerequisites, commands, expected results, validation checks, troubleshooting, cost controls, and cleanup. A lab is not marked Azure validated unless evidence exists.

### 3. Practise business scenarios

The [15 architecture case studies](scenarios/README.md) cover different organization sizes, identity models, security requirements, user personas, application needs, regional designs, migration planning, and operational problems.

Customer names, results, measurements, and requirements in these documents are case-study data unless the document links to separate validation evidence.

### 4. Prepare for interviews

Use the [Interview Material](interviews/README.md) by topic. Answer each question aloud, then compare your answer with the detailed answer in the linked chapter, lab, or scenario.

### 5. Use the troubleshooting runbooks

The [Troubleshooting Runbooks](troubleshooting/README.md) cover common AVD failure areas such as registration, entitlement, FSLogix, sign-in performance, RDP Shortpath, and Teams optimization.

## Northwind enterprise reference design

Northwind Global Manufacturing is a fictional 3,200-user architecture case study. It demonstrates how an AVD architect can move from requirements to a governed enterprise design.

| Part | Scope |
|---|---|
| A | Discovery, requirements, assumptions, and risks |
| B | Enterprise Azure landing zone |
| C | Identity and connectivity foundation |
| D | Governance and security foundation |
| E | AVD landing zone |
| F | AVD platform architecture |
| G | Terraform reference implementation |
| H | Operations, monitoring, scaling, backup, cost management, and recovery gaps |

The documents and reference code for all eight parts are present. The **design package is complete**. This does not mean the full environment has been deployed or production validated.

Run `python tools/validate_repository.py` before publishing. Terraform 1.13.3 successfully parsed and formatted all 230 Terraform files. The [Terraform validation record](TERRAFORM-VALIDATION.md) explains the completed checks and the remaining provider-validation boundary. GitHub Actions checks local links, draw.io/SVG pairs, XML parsing, sensitive file types, Terraform formatting, and every Terraform module that contains a `versions.tf` file.

## Terraform

- `terraform/lab*/` supports the progressive learning labs.
- `terraform/capstone-northwind/` supports the Northwind reference architecture.

Before applying a module:

1. Read its README and prerequisites.
2. Copy `terraform.tfvars.example` to `terraform.tfvars`.
3. Replace every example value.
4. Configure a secure remote state backend.
5. Run `terraform fmt -check`, `terraform init`, `terraform validate`, and `terraform plan`.
6. Review permissions, cost, dependencies, and cleanup.
7. Apply only in an authorized lab or Azure environment.

Provider validation does not prove that a design is correct for a specific tenant, subscription, region, quota, identity model, or business requirement.

Official implementation references:

- [Configure Azure Virtual Desktop with Terraform](https://learn.microsoft.com/en-us/azure/developer/terraform/configure-azure-virtual-desktop)
- [Azure Virtual Desktop prerequisites](https://learn.microsoft.com/en-us/azure/virtual-desktop/prerequisites)
- [Deploy Azure Virtual Desktop](https://learn.microsoft.com/en-us/azure/virtual-desktop/deploy-azure-virtual-desktop)

## Repository map

```text
azure-virtual-desktop-architect/
├── README.md
├── VALIDATION-STATUS.md
├── SUMMARY.md
├── chapters/                       25 learning chapters
├── labs/                           20 progressive labs
├── scenarios/                      15 fictional architecture case studies
├── capstone/                       Northwind enterprise reference design
├── terraform/                      Lab and capstone Terraform modules
├── diagrams/architecture/          Editable draw.io and matching SVG files
├── troubleshooting/                Operations runbooks
├── interviews/                     Interview study index
└── appendices/                     Standards, audit history, and supporting notes
```

## Content standards

- Product statements are checked against Microsoft Learn or the Azure Architecture Center.
- Terraform behavior is also checked against official HashiCorp provider documentation.
- Time-sensitive or unconfirmed details are marked `VERIFY BEFORE IMPLEMENTATION`.
- Diagrams use editable `.drawio` sources with matching `.svg` exports.
- No credentials, state files, private keys, or personal tenant identifiers should be committed.

## Important use statement

This is a learning and portfolio reference, not a production deployment package. A real implementation still requires current documentation, organizational requirements, security review, cost review, change control, and testing in the target Azure environment.

## Navigation

- [Full table of contents](SUMMARY.md)
- [Validation status](VALIDATION-STATUS.md)
- [Final architecture and operations review](FINAL-REVIEW.md)
- [Terraform validation record](TERRAFORM-VALIDATION.md)
- [Source verification](SOURCE-VERIFICATION.md)
- [Northwind capstone](capstone/README.md)
- [Hands-on labs](labs/)
- [Architecture case studies](scenarios/README.md)
- [Interview preparation](interviews/README.md)
- [Troubleshooting runbooks](troubleshooting/README.md)
- [Architecture diagrams](diagrams/architecture/README.md)

## License

Original repository content is provided under the [LICENSE](LICENSE). Microsoft and Citrix product names are used only to describe the technologies discussed.
