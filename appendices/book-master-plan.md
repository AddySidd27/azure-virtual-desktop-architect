# Azure Virtual Desktop - Architect to Hands-on Implementation

**Enterprise Architecture, Real-World Design, Step-by-Step Labs, Operations, Troubleshooting & Senior Architect Interview Preparation**

---

## PHASE 0 - MASTER PLAN (Approval Required Before Chapter 1)

This document delivers the ten planning artifacts requested. No chapter content is written yet.

> **Archive note:** This is the original planning document. Its scope figures and delivery status are historical targets, not the repository's current inventory. Use the [main README](../README.md), [table of contents](../SUMMARY.md), and [validation status](../VALIDATION-STATUS.md) for the current position. The final repository contains 25 chapters, 20 labs, 15 fictional architecture case studies, and 196 indexed interview questions.

**Plan version:** 1.0 | **Technical baseline date:** August 2026 | **Target reader:** Experienced cloud/infrastructure engineer moving to Senior AVD Architect

---

## 0. CRITICAL CURRENCY NOTE - READ FIRST

Several things changed in AVD during 2025-2026 that invalidate most books, blogs, and training courses currently in circulation. This book is anchored to the **August 2026** state of the platform, and every chapter that touches a moving feature carries a `CURRENCY FLAG` box.

Verified current-state items that shape the structure of this book:

| Change | State as of Aug 2026 | Impact on book |
|---|---|---|
| **MSIX App Attach → App Attach** | Original MSIX-only App Attach retired 1 June 2025. Successor "App Attach" delivers MSIX, Appx **and App-V** packages | Part VI is written against App Attach, not MSIX App Attach. Legacy called out as legacy only |
| **App Attach on Windows Server** | Server 2022 and 2025 supported as of April 2026 | Adds a server-OS app delivery scenario |
| **Automated Host Pools / Session Host Configuration (SHC)** | GA June 2026 | Part IV restructured - SHC-first, classic manual host pool taught as the fallback/brownfield model |
| **Dynamic Autoscaling** | GA June 2026 | Part IX teaches scaling plans *and* dynamic autoscaling as distinct tools |
| **Ephemeral OS disks for AVD session hosts** | Available for pooled host pools with session host configuration | Document the stateless-workload, lifecycle, VM-size and scaling constraints |
| **RDP Multipath (redundant TCP)** | GA July 2026 | Part I connection flow + Part III network design updated |
| **Context-Based Redirections** | GA June 2026 | Part VII BYOD/security controls |
| **Arc-enabled session hosts** | Announced May 2026 - session hosts on any hypervisor/bare-metal Windows Server via Azure Arc extension | New hybrid deployment chapter |
| **Windows App vs MSRDC** | Remote Desktop client for Windows (MSRDC) retired March 2026; Windows App is the strategic client | Client chapter rewritten; migration guidance included |
| **AVD (classic)** | Support ends September 2026 | Covered only as historical/migration context |

**Rule for the whole book:** anything above, plus SKUs, limits, quotas, and PowerShell cmdlet syntax, gets re-verified against Microsoft Learn at the moment that chapter is written - not from memory.

---

## 1. COMPLETE TABLE OF CONTENTS

### FRONT MATTER
- How to use this book
- Reader prerequisites and self-assessment
- Terminology and naming conventions used throughout
- The Architect's Mental Model (the 10-layer stack used for every troubleshooting exercise)

---

### PART I - AVD FUNDAMENTALS AND THE ARCHITECT'S MENTAL MODEL

**Ch 1 - What AVD Actually Is (and What It Is Not)**
Service definition, evolution from RDS → WVD → AVD → current, positioning vs Windows 365 vs Citrix DaaS vs on-prem VDI, when *not* to choose AVD.

**Ch 2 - The Control Plane, Management Plane and Data Plane**
Microsoft-managed vs customer-managed responsibility split, broker, gateway, diagnostics, web client service, what happens when each fails.

**Ch 3 - AVD Object Model: Host Pools, Session Hosts, Application Groups, Workspaces**
Object relationships and cardinality rules, pooled vs personal, desktop vs RemoteApp application groups, assignment model, why the object model causes the most common design mistakes.

**Ch 4 - The Connection Flow, End to End**
Feed discovery → subscription → authentication → broker → orchestration → reverse connect → gateway → session host → SxS stack → Windows logon. Reverse Connect explained properly. RDP Shortpath (managed and public networks), RDP Multipath. Full packet-level walkthrough.

**Ch 5 - Operating Systems, Multi-session, and Licensing**
Windows 11/10 Enterprise multi-session, single-session, Windows Server session hosts, supported OS matrix, entitlement and licensing models, per-user access pricing, the licensing questions interviewers actually ask.

**Ch 6 - Clients and the Endpoint Story**
Windows App, web client, macOS/iOS/Android/Linux, thin clients, MSRDC retirement and migration, client-side settings, protocol/feature parity table.

---

### PART II - IDENTITY & AUTHENTICATION

**Ch 7 - Identity Architecture Foundations**
AD DS, Microsoft Entra ID, Entra Domain Services, Entra Connect / Cloud Sync, the three join types (AD DS domain join, Hybrid Entra join, Entra join), what each one enables and forbids in AVD.

**Ch 8 - Authentication Flows in Detail**
Feed auth vs session host auth vs in-session (SSO) auth - three distinct authentications most engineers conflate. Kerberos, PRT, Entra Kerberos for Azure Files, single sign-on configuration, in-session credential behaviour, smart card and passwordless paths.

**Ch 9 - Conditional Access, MFA and Zero Trust Access**
Targeting the correct cloud apps, sign-in frequency behaviour in AVD, device filters, session controls, the classic "MFA prompts every 60 minutes" problem, break-glass design.

**Ch 10 - RBAC, Delegation and Administrative Model**
AVD built-in roles, custom roles, scope design, management group strategy, helpdesk delegation model, PIM, managed identities, service principal usage.

*Knowledge check block + identity troubleshooting scenarios.*

---

### PART III - NETWORK ARCHITECTURE

**Ch 11 - AVD Network Fundamentals and Required Connectivity**
Required FQDN/service tags, what genuinely must reach the internet vs what can stay private, session host outbound requirements, private link for AVD, DNS design (on-prem DNS, Azure DNS, Private DNS zones, conditional forwarders).

**Ch 12 - Enterprise Topologies**
Hub-and-spoke, Virtual WAN, landing zone alignment (Azure Landing Zone / AVD accelerator), subnet sizing math, IP address planning for scale, NSG and ASG design, UDR and forced tunnelling implications.

**Ch 13 - Hybrid Connectivity and Egress Control**
ExpressRoute, S2S VPN, P2P/P2S, Azure Firewall vs NVA vs proxy, TLS inspection pitfalls, NAT Gateway, asymmetric routing failures, latency budgets and region selection methodology.

**Ch 14 - Protocol Optimisation and Network Performance**
RDP Shortpath managed/public, RDP Multipath, bandwidth per user persona, QoS/DSCP, Teams media optimisation path, multimedia redirection, measuring and defending round-trip time.

*Diagrams: 6 network diagrams. Knowledge check block.*

---

### PART IV - HOST POOL AND SESSION HOST ARCHITECTURE

**Ch 15 - Host Pool Design Decisions**
Pooled vs personal, breadth-first vs depth-first, max session limit derivation, validation environment, host pool sprawl vs consolidation, naming and tagging standards, multiple host pools per persona.

**Ch 16 - Automated Host Pools, Session Host Configuration and Lifecycle (Current Model)**
SHC object model, rolling session host updates, image version swaps, what SHC replaces, brownfield migration from manually managed pools, plus the session host lifecycle it controls: registration tokens, agent and SxS stack, drain mode, and image-replace vs in-place patching strategy. `CURRENCY FLAG`

**Ch 17 - Session Host Sizing, Compute Selection and Placement**
Arc-enabled session hosts for on-premises and other-hypervisor deployments. VM SKU families for EUC, vCPU:user ratios by persona with a defensible sizing methodology, memory/pagefile, disk types, Ephemeral OS Disks decision matrix, GPU SKUs and driver strategy, Availability Zones vs Availability Sets, Trusted Launch, capacity/quota planning.

**Ch 18 - Endpoint Management for Session Hosts: Intune, Configuration Manager and Group Policy**
AVD + Intune architecture, Entra join as the management prerequisite, session host enrolment, configuration profiles and the Settings catalog, device scope vs user scope, the multi-session supported/unsupported matrix, application deployment in system context, Windows Update management for multi-session, compliance policies feeding Conditional Access, Defender and endpoint security policies, GPO vs Intune, Configuration Manager vs Intune and co-management, and Intune-specific AVD troubleshooting. `CURRENCY FLAG`

> Session host lifecycle (registration tokens, agent and SxS stack, drain mode, patching strategy) moved to **Ch 16**; Arc-enabled session hosts moved to **Ch 17**. See [Intune integration note](structure-change-01-intune.md).

---

### PART V - FSLOGIX, PROFILES AND STORAGE (DEEP)

**Ch 19 - Why Profiles Are the Number One Cause of AVD Failure**
Profile theory, roaming profile history, what a container actually is, VHD/VHDX/CIM, profile vs Office container, ODFC, redirections.xml, the profile lifecycle at logon and logoff.

**Ch 20 - Profile Storage Architecture**
Azure Files (Standard/Premium), Azure NetApp Files (tiers), Storage Account limits and IOPS math, identity-based auth (AD DS / Entra Kerberos), share-level RBAC vs NTFS ACLs - the two-permission model, sizing formula, per-region placement, quota strategy.

**Ch 21 - FSLogix Production Implementation**
Every registry value that matters and why, VHDLocations vs CloudCache, concurrent access, ProfileType, redirection, exclusions, antivirus exclusions, Defender configuration, OneDrive/Teams/Outlook cache design, logging configuration.

**Ch 22 - Profile Operations, Failure and Recovery**
Temporary profiles, locked/orphaned VHDs, corruption, bloat and shrink, cleanup automation, backup of profile data vs backup of profile containers (they are not the same decision), profile storage HA and DR, migration from other profile solutions.

*Full production FSLogix lab is Lab 6. Knowledge check block.*

---

### PART VI - IMAGES, ENDPOINT MANAGEMENT AND APPLICATION DELIVERY

> Revised August 2026 - see [Structure change 01](structure-change-01-intune.md). Chapter count unchanged at 54.

**Ch 23 - Golden Image Engineering**
Image strategy, Azure Compute Gallery, image versioning and replication, VM optimisation, Windows optimisation tooling, sysprep and generalisation failures, language packs, image build automation (Packer / Azure Image Builder overview).

**Ch 24 - Intune and AVD: Endpoint Management Architecture**
AVD + Intune reference architecture. Entra join and Entra hybrid join. Enrolment with device credentials and why enrolment must never be baked into an image. Configuration profiles and the Settings catalog, device scope versus user scope. Application deployment in system context. Windows Update management and why update rings don't apply to multi-session. Compliance policies feeding Conditional Access. Security baselines, Endpoint Security and Defender for Endpoint onboarding. Multi-session as a distinct OS edition and the "Not applicable" problem. The persistent-device assumption versus disposable session hosts. `CURRENCY FLAG`

**Ch 25 - Application Delivery Strategy and RemoteApp Design**
The four delivery routes (baked-in image, App Attach, Intune/Configuration Manager, published RemoteApp) with a selection framework. RemoteApp versus full desktop, application group strategy, LOB app patterns, licensing servers, printing, isolation, per-persona application mapping. Application dependency and compatibility assessment.

**Ch 26 - App Attach in Practice**
Current App Attach architecture, MSIX / Appx / App-V package support, image formats (CIM vs VHDX) and why CIM is preferred, certificate and signing requirements, share permissions, host pool and user assignment, Windows Server support, troubleshooting stuck packages. `CURRENCY FLAG`

---

### PART VII - SECURITY ARCHITECTURE

**Ch 27 - Zero Trust Reference Architecture for AVD**
Trust boundaries, identity/device/network/session/data layers, mapping AVD components to Zero Trust pillars, a complete secure reference architecture diagram with rationale for each control.

**Ch 28 - Session Host and Session Hardening**
Security baselines, Defender for Endpoint and Defender for Cloud, attack surface reduction, AppLocker/WDAC, local admin elimination, LAPS, screen capture protection, watermarking, clipboard/drive/USB redirection controls, context-based redirections for BYOD. `CURRENCY FLAG`

**Ch 29 - Data, Storage and Administrative Security**
Encryption at rest/in transit, customer-managed keys, private endpoints for storage, storage firewall, key rotation, PIM and just-in-time admin, audit logging, compliance mapping, data residency.

---

### PART VIII - MONITORING AND OPERATIONS

> Revised August 2026. Day 1 and Day 2 operations are covered as performable procedures against the Lab 1 to 20 environment, with runbooks in the standard runbook format.

**Ch 30 - Monitoring Architecture**
What to collect and why, diagnostic settings per resource type, Log Analytics workspace design and cost control, retention, data volume estimation, agent strategy.

**Ch 31 - AVD Insights and the Operational Dashboard**
Insights configuration and its known gaps, connection diagnostics, session host health, logon duration breakdown, KQL query library, custom workbooks, an operational dashboard specification you can hand to an ops team.

**Ch 32 - Day-2 Operations and Alerting**
Alert catalogue with thresholds and rationale, capacity monitoring, patch/update operations, drain and maintenance procedures, change management, runbook structure, SLO/SLA definition for a desktop service.

---

### PART IX - SCALING AND COST OPTIMISATION

**Ch 33 - Scaling Plans and Dynamic Autoscaling**
Scaling plan schedules for pooled and personal pools, ramp-up/peak/ramp-down/off-peak, drain behaviour, forced logoff policy, dynamic autoscaling model and how it differs from schedule-based scaling, scaling with SHC. `CURRENCY FLAG`

**Ch 34 - Density and Performance Economics**
Deriving users-per-host from real telemetry, benchmarking methodology, the density/performance/cost triangle, GPU cost modelling.

**Ch 35 - Cost Architecture**
Full cost model (compute, storage, network, licensing, monitoring), reservations vs savings plans vs spot, off-hours strategies, non-production strategy, storage tiering, Log Analytics cost control, worked numeric examples with assumptions clearly labelled, cost review checklist.

---

### PART X - HIGH AVAILABILITY AND DISASTER RECOVERY

**Ch 36 - HA Within a Region**
Availability Zones for session hosts, zonal storage options, control plane metadata location and what that means, dependency mapping, single points of failure audit.

**Ch 37 - Multi-Region and DR Architecture**
Active/active vs active/passive vs cold rebuild, profile replication strategies and their honest limitations, identity and DNS DR, application DR, data DR, RTO/RPO derivation per persona.

**Ch 38 - Backup, Recovery and DR Testing**
What must be backed up vs what can be redeployed (a core architect distinction), IaC as a recovery mechanism, DR runbook, DR test plan and evidence, failback.

---

### PART XI - REAL-WORLD ARCHITECTURE SCENARIOS

**Ch 39 - Scenarios 1-5** (100-user SMB, 500-user enterprise, 1,000-user enterprise, 5,000-user global, Hybrid AD enterprise)
**Ch 40 - Scenarios 6-10** (Entra-only, Remote/BYOD, Call centre, Developers/engineering, GPU/CAD)
**Ch 41 - Scenarios 11-15** (RemoteApp-only, Personal desktop, Highly secure/regulated, Multi-region, Disaster recovery)

Each of the 15 scenarios follows the fixed 18-section template (requirements → assumptions → personas → architecture → network → identity → host pools → sizing methodology → FSLogix → applications → security → monitoring → scaling → HA/DR → cost → implementation steps → validation → troubleshooting → interview questions).

---

### PART XII - HANDS-ON LAB ENVIRONMENT (Labs 1-20)

Delivered as a separate progressive lab track. See section 3 below.

---

### PART XIII - AUTOMATION FOR ARCHITECTS

**Ch 42 - PowerShell and CLI Operational Toolkit**
Az.DesktopVirtualization module, module version dependencies, the 30 commands an AVD architect must be fluent in, error handling, safe destructive operations.

**Ch 43 - Infrastructure as Code for AVD**
ARM/Bicep and Terraform concepts applied to AVD specifically, what should and should not be in IaC, state and drift, the AVD Landing Zone accelerator, environment promotion.

**Ch 44 - Operational Automation**
Azure Automation, managed identities, Logic Apps/Functions for AVD ops, image pipeline automation, session host lifecycle automation, self-service patterns, guardrails.

---

### PART XIV - PRODUCTION TROUBLESHOOTING PLAYBOOK

> Revised August 2026. All operations and troubleshooting content follows the [operations and troubleshooting standard](../OPERATIONS-AND-TROUBLESHOOTING-STANDARD.md): nine step scenario format, exact portal, PowerShell, CLI, KQL and Event Viewer detail, minimum three production scenarios per area, plus the architect's four questions and escalation criteria. Troubleshooting is not confined to Part XIV. Every chapter with an operational surface carries scenarios in the same format.

**Ch 45 - The 10-Layer Isolation Method**
Identity → Authorization → AVD resource config → Network → Session host → Windows → Profile/FSLogix → Application → Performance → Monitoring. How to bisect a problem in under five minutes.

**Ch 46 - Connection, Access and Identity Failures**
Cannot log in, no feed/workspace, no desktop icon, application group misassignment, host unavailable, host not registered, RDP failure, black screen, disconnect loops, CA/MFA failures, certificate issues.

**Ch 47 - Experience, Profile, Storage and Performance Failures**
Slow logon (with a logon-time decomposition method), slow session, temporary profile, FSLogix mount failures, Azure Files permission failures, DNS failures, storage throttling, CPU/RAM saturation, scaling failures, application failures, monitoring blind spots.

Every issue uses: **Problem → Symptoms → Possible causes → Investigation → Commands → Resolution → Prevention**.

---

### PART XV - ARCHITECT INTERVIEW MASTER SECTION

**Ch 48 - Interview Questions: Foundation to Senior Engineer** (Q1-60)
**Ch 49 - Interview Questions: Senior Architect and Domain Deep-Dives** (Q61-120) - architecture design, security, networking, FSLogix, identity, HA/DR, cost
**Ch 50 - Interview Questions: Scenario, Troubleshooting and Leadership** (Q121-165)

165 questions total. Important questions carry: question → strong answer → why it's strong → real-world example → likely follow-up → **30-second / 2-minute / deep-dive** verbal versions.

---

### PART XVI - ARCHITECTURE DESIGN INTERVIEW SIMULATIONS

**Ch 51 - 20 Full Mock Interviews**
Each simulation runs the complete 16-step arc from discovery questions through to follow-up defence.

---

### PART XVII - ARCHITECT DECISION FRAMEWORKS

**Ch 52 - 16 Decision Matrices**
GPO vs Intune vs Configuration Manager · Pooled vs Personal · Multi-session vs Single-session · Azure Files vs Azure NetApp Files · Hybrid AD vs Entra-only · Single vs Multi-region · Availability Zones vs Availability Sets · Hub-Spoke vs Virtual WAN · Azure Firewall vs alternative egress control · RemoteApp vs Full Desktop · Breadth-first vs Depth-first · VM sizing approaches · Image-baked vs App Attach vs Intune delivery · Ephemeral vs Managed OS disk · SHC/Automated host pools vs classic host pools · **Group Policy vs Intune for session hosts** · **Configuration Manager vs Intune vs co-management**.

Format for each: Requirements → Option A → Option B → Pros → Cons → Recommendation → **When not to use**.

---

### PART XVIII - CAPSTONE PROJECT

**Ch 53 - Capstone: "Northwind Global" End-to-End Design**
**Ch 54 - Capstone: Implementation, Testing, Documentation and Architecture Review**

---

### APPENDICES
- **A** - AVD Architect Production Readiness Checklist
- **B** - Architecture Review / Pre-Production / Go-Live / Day-2 / DR Test Checklists
- **C** - Troubleshooting Cheat Sheet
- **D** - Interview Cheat Sheet (one-page recall)
- **E** - PowerShell / CLI Command Reference
- **F** - KQL Query Library
- **G** - Glossary and Abbreviations
- **H** - "What Has Changed in Current AVD" (living currency appendix)
- **I** - Official Microsoft Reference Index (per chapter)

---

## 2. TOTAL CHAPTER COUNT

| Component | Count |
|---|---|
| Numbered chapters | **54** |
| Parts | 18 |
| Hands-on labs | 20 |
| Real-world scenarios | 15 |
| Mock interview simulations | 20 |
| Interview questions | 165 |
| Decision matrices | 15 |
| Architecture diagrams | 60+ |
| Appendices | 9 |

**Estimated final length:** 320,000-380,000 words. This is a multi-session build.

---

## 3. LAB ROADMAP

All labs build on one another into a single environment: **`avdlab.local` / Contoso-style tenant**. Nothing is thrown away until Lab 20.

| Lab | Title | Builds on | Azure resources added | Est. time |
|---|---|---|---|---|
| 1 | Azure prerequisites, subscription, quota, tooling | - | Subscription, quota increase, modules | 45 min |
| 2 | Resource groups, naming, tagging, governance | 1 | RGs, policy, tags | 45 min |
| 3 | VNet, subnets, NSG, DNS, Bastion | 2 | VNet, 4 subnets, NSGs, Bastion | 90 min |
| 4 | Identity - DC deployment, Entra Connect, join model | 3 | DC VM, Entra Connect | 120 min |
| 5 | Storage - Azure Files, identity-based auth, permissions | 4 | Storage account, file share, RBAC + NTFS | 90 min |
| 6 | FSLogix production configuration | 5 | GPO/registry, exclusions, logging | 90 min |
| 7 | Host pool creation (both classic and SHC/automated) | 4 | Host pool, registration token | 60 min |
| 8 | Session hosts - image, deploy, register, enrol in Intune, validate | 6,7 | Compute Gallery, session host VMs | 135 min |
| 9 | Application groups - desktop and RemoteApp | 8 | App groups | 45 min |
| 10 | Workspace and feed validation | 9 | Workspace | 30 min |
| 11 | User and group assignment, personas | 10 | Entra groups, role assignments | 45 min |
| 12 | Authentication, SSO, Entra Kerberos for Azure Files | 11 | SSO config | 75 min |
| 13 | Conditional Access and MFA for AVD | 12 | CA policies | 60 min |
| 14 | Monitoring - diagnostics, Log Analytics, Insights, KQL | 13 | LAW, diagnostic settings, workbook | 90 min |
| 15 | Scaling - scaling plan + dynamic autoscaling | 14 | Scaling plan | 75 min |
| 16 | Endpoint management and security hardening with Intune - configuration profiles, Settings catalog, compliance, endpoint security, Defender, update settings | 15 | Intune policies, Defender | 120 min |
| 17 | Troubleshooting - 14 deliberately broken scenarios to fix, including two Intune failures | 16 | (break/fix) | 165 min |
| 18 | High availability - zones, storage resilience, failure injection | 17 | Zonal hosts | 90 min |
| 19 | Disaster recovery - second region, failover, DR test | 18 | Region 2 stack | 150 min |
| 20 | Full production-style deployment via IaC, end to end | all | Bicep/Terraform deployment | 180 min |

**Every lab includes:** Objective · Architecture diagram · Prerequisites · Resources · Portal steps · PowerShell · CLI (where useful) · Configuration detail · Validation checklist · Expected result · Troubleshooting · Cleanup guidance · Interview questions.

**Estimated total lab time:** ~27 hours. **Estimated Azure cost if run continuously:** flagged per lab, with a shutdown strategy that keeps the full lab under a stated monthly budget.

---

## 4. REAL-WORLD SCENARIO ROADMAP

| # | Scenario | Primary architectural lesson |
|---|---|---|
| 1 | 100-user small business | Simplicity, single region, cost floor, when AVD is over-engineering |
| 2 | 500-user enterprise | First real persona split, storage sizing, monitoring baseline |
| 3 | 1,000-user enterprise | Host pool segmentation, ANF threshold, operational maturity |
| 4 | 5,000-user global | Multi-region, multi-identity, image pipeline, governance at scale |
| 5 | Hybrid AD enterprise | Domain dependency, DC placement, DNS, hybrid join failure modes |
| 6 | Entra ID-only | Cloud-native design, Entra Kerberos storage, what breaks without AD |
| 7 | Remote workers / BYOD | Zero Trust, redirection control, unmanaged devices, data exfiltration |
| 8 | Call centre | Extreme density, breadth-first, logon storms, Teams optimisation |
| 9 | Developers / engineering | Personal desktops, local admin, high resource, nested virtualisation |
| 10 | GPU / CAD | GPU SKUs, drivers, protocol tuning, cost defence |
| 11 | RemoteApp-only | App-centric delivery, licensing, seamless windows |
| 12 | Personal desktop estate | 1:1 economics, patching, personal pool scaling, hibernate |
| 13 | Highly secure / regulated | Private-only, no internet egress, CMK, audit, compliance evidence |
| 14 | Multi-region enterprise | Latency, data residency, global feed experience, traffic steering |
| 15 | Disaster recovery | RTO/RPO derivation, profile replication reality, DR test evidence |

---

## 5. INTERVIEW PREPARATION ROADMAP

| Band | Questions | Focus |
|---|---|---|
| Beginner | Q1-20 | Terminology, object model, basic flow |
| Intermediate | Q21-45 | Configuration, FSLogix basics, monitoring |
| Senior Engineer | Q46-75 | Deep troubleshooting, performance, operations |
| Senior Architect | Q76-100 | Design trade-offs, scale, governance |
| Architecture Design | Q101-115 | Greenfield and brownfield design |
| Security | Q116-125 | Zero Trust, hardening, compliance |
| Networking | Q126-130 | Topology, egress, protocol |
| Endpoint management (Intune) | Q131-140 | Join dependency, scope, Not applicable, updates, co-management |
| FSLogix / Storage | Q141-148 | The single highest-yield interview topic |
| Identity | Q149-154 | Join models, auth flows, CA |
| HA / DR | Q155-159 | Resilience reasoning |
| Cost Optimisation | Q160-163 | Defending spend to a CFO |
| Leadership / Decision | Q164-165 | Stakeholder communication, saying no |

**Verbal delivery layers on every major question:** 30-second answer → 2-minute answer → deep-dive under challenge.

**20 mock interviews** in Ch 51 span: 3,000-user NA+EU design · Citrix-to-AVD migration · regulated financial services · call centre consolidation · GPU engineering firm · cost-reduction mandate · post-incident review · DR design challenge · BYOD/M&A · Entra-only greenfield · brownfield rescue · plus 9 more.

---

## 6. CAPSTONE PROJECT OVERVIEW

### "Northwind Global Manufacturing"

**Profile:** 3,200 users · HQ Chicago, EMEA hub Amsterdam, engineering site Bangalore · hybrid AD with Entra Connect · ExpressRoute at two sites · 900 remote/BYOD users · SAP + a licensed CAD suite + 40 LOB apps · SOX-relevant financial data · 99.5% desktop availability target · budget under existing on-prem VDI run cost.

**Personas:** Task workers (1,400) · Knowledge workers (1,100) · Finance/regulated (250) · Engineers/CAD (180) · Developers (170) · Executives (100).

**Deliverable sequence:** Requirements → Architecture → Network → Identity → Host Pools → Session Hosts → Applications → FSLogix → Security → Monitoring → Scaling → HA → DR → Testing → Documentation → Operations → **Architecture Review Board defence**.

The reader must produce a real design document, a bill of materials, a cost model, an IaC skeleton, and a 15-minute architecture presentation - then defend it against a written review-board challenge set.

---

## 7. ARCHITECTURE DIAGRAM ROADMAP

All diagrams in Mermaid where the structure allows; layered ASCII/description where Mermaid cannot express it. **Every diagram is followed by a numbered step-by-step traffic/flow explanation.**

| Group | Diagrams | Chapters |
|---|---|---|
| Service anatomy | Control/management/data plane split; responsibility model | 2 |
| Object model | Host pool ↔ app group ↔ workspace relationships | 3 |
| Connection flow | Feed discovery; full connection sequence; reverse connect; Shortpath; Multipath | 4, 14 |
| Identity | Three join models; three authentication flows; SSO; CA evaluation | 7-9 |
| Network | Hub-spoke; vWAN; required egress; private endpoint design; DNS resolution; forced tunnel | 11-13 |
| Host pool | Pooled vs personal; SHC/automated pool lifecycle; load balancing behaviour | 15-17 |
| Storage/profile | FSLogix mount flow; permission model (two-layer); storage topology; ANF vs Files | 19-21 |
| Application | Delivery decision tree; App Attach mount flow | 24-25 |
| Endpoint management | AVD + Intune architecture; join type to management options; policy applicability flow | 18 |
| Security | Zero Trust reference architecture; trust boundaries; secure enterprise reference | 27-29 |
| Monitoring | Telemetry pipeline; dashboard layout | 30-31 |
| Scaling | Scaling plan state machine; autoscale decision flow | 33 |
| HA/DR | Single-region HA; multi-region active/passive; multi-region active/active; DR failover sequence | 36-38 |
| Scenarios | 1 architecture diagram per scenario | 39-41 |
| Labs | 1 per lab | Labs 1-20 |
| Capstone | Full stack + network + identity + DR | 53-54 |

**Target: 60+ diagrams.**

---

## 8. SOURCE / REFERENCE STRATEGY

**Tier 1 - Authoritative (used for all factual claims)**
- Microsoft Learn AVD documentation
- Microsoft Learn "What's new in Azure Virtual Desktop" and "What's new in the AVD Agent"
- FSLogix official documentation
- Azure Files / Azure NetApp Files documentation
- Microsoft Entra documentation
- Azure Well-Architected Framework and Cloud Adoption Framework (AVD landing zone accelerator)
- Azure service limits and quota documentation
- Az PowerShell / Azure CLI command references

**Tier 2 - Supporting (used for context, never as sole basis for a technical claim)**
- Microsoft Tech Community AVD blog and official announcements
- Microsoft-published reference architectures

**Tier 3 - Excluded from factual claims**
- Community blogs, forums, third-party vendor content. May be mentioned as "field practice" and clearly labelled as such.

**Rules enforced in every chapter:**
1. No invented cmdlets, parameters, SKUs, limits, ports, or FQDNs. If unverified at write time, it is marked `[VERIFY]` rather than guessed.
2. Every PowerShell/CLI command states: what it does, module and minimum version, prerequisites, expected output, common errors.
3. Current vs legacy architecture explicitly separated - no legacy design presented as current.
4. Microsoft-supported vs optional/third-party clearly labelled.
5. Numeric guidance (density, sizing, cost) is always presented as **methodology + worked example + labelled assumptions**, never as a universal truth.
6. Each chapter ends with an "Official references" list rather than "see the docs" hand-waving.
7. Anything verified after the general knowledge baseline gets a dated `CURRENCY FLAG`.

---

## 9. COVERAGE MATRIX

| Topic | Covered | Chapter(s) | Lab | Interview Qs | Diagram |
|---|---|---|---|---|---|
| AVD service architecture / planes | ✅ | 1, 2 | 1 | ✅ | ✅ |
| Object model (pools/app groups/workspaces) | ✅ | 3 | 7, 9, 10 | ✅ | ✅ |
| Connection flow / reverse connect | ✅ | 4 | 10 | ✅ | ✅ |
| RDP Shortpath / Multipath | ✅ | 4, 14 | 3 | ✅ | ✅ |
| OS support / multi-session / licensing | ✅ | 5 | 8 | ✅ | - |
| Clients / Windows App / MSRDC retirement | ✅ | 6 | 10 | ✅ | - |
| AD DS / Entra ID / join models | ✅ | 7 | 4 | ✅ | ✅ |
| Authentication flows / SSO | ✅ | 8 | 12 | ✅ | ✅ |
| MFA / Conditional Access | ✅ | 9 | 13 | ✅ | ✅ |
| RBAC / PIM / delegation | ✅ | 10 | 11 | ✅ | ✅ |
| Required connectivity / DNS / Private Link | ✅ | 11 | 3 | ✅ | ✅ |
| Hub-spoke / vWAN / landing zone | ✅ | 12 | 3 | ✅ | ✅ |
| ExpressRoute / VPN / firewall / egress | ✅ | 13 | 3 | ✅ | ✅ |
| Protocol and network performance | ✅ | 14 | 17 | ✅ | ✅ |
| Host pool design / load balancing | ✅ | 15 | 7 | ✅ | ✅ |
| Automated host pools / SHC | ✅ | 16 | 7 | ✅ | ✅ |
| VM sizing / SKUs / GPU / zones / disks | ✅ | 17 | 8 | ✅ | ✅ |
| Session host lifecycle | ✅ | 16 | 8 | ✅ | ✅ |
| Arc-enabled session hosts | ✅ | 17 | - | ✅ | ✅ |
| AVD + Intune architecture | ✅ | 18 | 8, 16 | ✅ | ✅ |
| Intune configuration, compliance, updates | ✅ | 18, 32 | 16 | ✅ | ✅ |
| GPO vs Intune vs Configuration Manager | ✅ | 18, 52 | 16 | ✅ | ✅ |
| Profile theory / containers | ✅ | 19 | 6 | ✅ | ✅ |
| Azure Files / ANF / permissions | ✅ | 20 | 5 | ✅ | ✅ |
| FSLogix configuration | ✅ | 21 | 6 | ✅ | ✅ |
| Profile failure / recovery / DR | ✅ | 22 | 17, 19 | ✅ | ✅ |
| Golden images / Compute Gallery | ✅ | 23 | 8 | ✅ | ✅ |
| App delivery strategy | ✅ | 24 | 9 | ✅ | ✅ |
| Intune + AVD management architecture | ✅ | 24 | 8, 16 | ✅ | ✅ |
| Intune enrolment and lifecycle | ✅ | 18, 24 | 8, 16 | ✅ | ✅ |
| Intune configuration profiles / Settings catalog | ✅ | 24 | 16 | ✅ | ✅ |
| Intune app deployment (system/user context) | ✅ | 24, 25 | 16 | ✅ | ✅ |
| Windows Update via Intune (multi-session limits) | ✅ | 24, 32 | 16 | ✅ | - |
| Compliance policies + Conditional Access | ✅ | 9, 24 | 13, 16 | ✅ | ✅ |
| Security baselines / Endpoint Security / Defender | ✅ | 24, 28 | 16 | ✅ | ✅ |
| GPO vs Intune, ConfigMgr vs Intune | ✅ | 24, 52 | 16 | ✅ | ✅ |
| App Attach (MSIX/Appx/App-V) | ✅ | 26 | 9 | ✅ | ✅ |
| RemoteApp / LOB apps | ✅ | 25 | 9 | ✅ | ✅ |
| Zero Trust reference architecture | ✅ | 27 | 16 | ✅ | ✅ |
| Session host hardening / Defender (via Intune) | ✅ | 28, 18 | 16 | ✅ | ✅ |
| Redirection & BYOD controls | ✅ | 28 | 16 | ✅ | ✅ |
| Data/storage/admin security | ✅ | 29 | 16 | ✅ | ✅ |
| Monitoring architecture | ✅ | 30 | 14 | ✅ | ✅ |
| AVD Insights / KQL / dashboards | ✅ | 31 | 14 | ✅ | ✅ |
| Day-2 operations / alerting | ✅ | 32 | 14 | ✅ | - |
| Scaling plans / dynamic autoscale | ✅ | 33 | 15 | ✅ | ✅ |
| Density / benchmarking | ✅ | 34 | 15 | ✅ | - |
| Cost architecture | ✅ | 35 | 15 | ✅ | ✅ |
| HA / Availability Zones | ✅ | 36 | 18 | ✅ | ✅ |
| Multi-region / DR design | ✅ | 37 | 19 | ✅ | ✅ |
| Backup / recovery / DR testing | ✅ | 38 | 19 | ✅ | ✅ |
| 15 real-world scenarios | ✅ | 39-41 | - | ✅ | ✅ |
| PowerShell / CLI | ✅ | 42 | all | ✅ | - |
| Bicep / Terraform / IaC | ✅ | 43 | 20 | ✅ | ✅ |
| Operational automation | ✅ | 44 | 20 | ✅ | ✅ |
| Troubleshooting methodology | ✅ | 45 | 17 | ✅ | ✅ |
| Connection/identity failures | ✅ | 46 | 17 | ✅ | - |
| Profile/performance failures | ✅ | 47 | 17 | ✅ | - |
| Interview preparation (165 Qs) | ✅ | 48-50 | - | ✅ | - |
| Mock interviews (20) | ✅ | 51 | - | ✅ | ✅ |
| Decision frameworks (14) | ✅ | 52 | - | ✅ | - |
| Capstone | ✅ | 53-54 | 20 | ✅ | ✅ |
| Checklists / cheat sheets / glossary | ✅ | App A-I | - | ✅ | - |

**Intune integration (August 2026):** added as a first-class topic without increasing the chapter count. Full detail in [Structure change 01](structure-change-01-intune.md). New appendix: [Intune and AVD Support Matrix](intune-avd-support-matrix.md).

**Gap audit result:** topics added beyond the original outline because they are unavoidable in real senior interviews and real deployments - **golden image engineering (Ch 23)**, **Session Host Configuration / automated host pools (Ch 16)**, **Ephemeral OS disks (Ch 17)**, **Arc-enabled session hosts (Ch 18)**, **Teams/multimedia optimisation (Ch 14)**, **KQL query library (App F)**, **AVD vs Windows 365 vs Citrix positioning (Ch 1)**, and **capacity/quota planning (Ch 17)**.

---

## 10. RECOMMENDED COMPLETION ORDER

The book is written in dependency order, not TOC order, so that labs stay executable as they are produced.

| Wave | Content | Why this order |
|---|---|---|
| **Wave 1 - Foundation** | Ch 1-6 + Labs 1-3 | Nothing else is meaningful without the object model and connection flow |
| **Wave 2 - Identity** | Ch 7-10 + Lab 4 | Identity gates everything downstream |
| **Wave 3 - Network** | Ch 11-14 | Must be settled before hosts exist |
| **Wave 4 - Compute** | Ch 15-18 + Labs 7-8 | Host pool and session hosts |
| **Wave 5 - Profiles** | Ch 19-22 + Labs 5-6 | Highest-value section; deliberately given its own wave |
| **Wave 6 - Apps, images & endpoint management** | Ch 23-26 + Labs 9-11 | Environment now usable end-to-end; Intune architecture lands here |
| **Wave 7 - Security** | Ch 27-29 + Labs 12-13, 16 | Hardening applied to a working environment |
| **Wave 8 - Operate** | Ch 30-35 + Labs 14-15 | Monitoring, scaling, cost |
| **Wave 9 - Resilience** | Ch 36-38 + Labs 18-19 | HA/DR |
| **Wave 10 - Troubleshooting** | Ch 45-47 + Lab 17 | Requires everything above to break realistically |
| **Wave 11 - Automation** | Ch 42-44 + Lab 20 | Codifies the whole build |
| **Wave 12 - Scenarios** | Ch 39-41 | Synthesis across all domains |
| **Wave 13 - Interview** | Ch 48-52 | Written last so answers match book content exactly |
| **Wave 14 - Capstone & appendices** | Ch 53-54, App A-I | Final integration + currency appendix refreshed at the end |

**Per-chapter contract.** Every chapter opens with: chapter number · objective · prerequisites · dependencies · estimated lab time · Azure resources required. Every chapter closes with: what was completed · what to test · what comes next · interview preparation.

---

## AWAITING APPROVAL

Confirm or adjust any of the following, then Chapter 1 begins:

1. **Chapter count (54)** - expand, trim, or accept
2. **Lab tenancy** - real Azure subscription (recommended, costed) vs read-only walkthrough
3. **Capstone profile** - Northwind Global (3,200 users) vs a profile closer to your own target employer
4. **IaC preference** - Bicep-first, Terraform-first, or both in parallel
5. **Delivery format** - one markdown file per chapter, or a single accumulating book file
6. **Wave order** - accept the dependency order above, or jump straight to the sections most relevant to an imminent interview
