# Structure Change 03 - Project-Led Delivery

**Date:** August 2026
**Status:** Applied
**Reason:** Completing a chapter sequence is not the goal. Teaching how AVD is actually designed, deployed, migrated, supported and troubleshot in an enterprise is.

---

## 1. What changes

From this point, the fifteen projects are the primary vehicle for the rest of the book.

Remaining concept chapters are not written for the sake of the sequence. Where a project needs a concept the book has not yet covered, the concept is introduced inside that project, at the point an engineer would actually need it, taught practically and briefly.

**What this does not mean.** It does not mean the remaining topics are dropped. Every topic in the original plan is still covered. It means the delivery vehicle changes from a chapter to an engagement, which is closer to how the knowledge is actually used.

---

## 2. Chapters 1 to 25 stand

The twenty-five published chapters are the foundation and remain unchanged. They cover the service, identity, networking, host pools, compute, profiles, storage, images, endpoint management and application delivery. Those are the concepts a reader needs before any engagement makes sense.

Projects reference them rather than repeating them.

---

## 3. Where the remaining concepts are taught

| Original chapter | Topic | Now taught in |
|---|---|---|
| 26 | App Attach in practice | Project 10, RemoteApp and line of business, where packaging is the actual work |
| 27 | Zero Trust reference architecture | Project 11, highly secure and regulated |
| 28 | Session host and session hardening | Project 06, BYOD, where session controls are the control |
| 29 | Data, storage and administrative security | Project 11 |
| 30 | Monitoring architecture | Project 02, the first estate large enough to need it |
| 31 | AVD Insights and the operational dashboard | Project 02, extended in Project 03 |
| 32 | Day-2 operations and alerting | Project 02, extended in Project 15 |
| 33 | Scaling plans and dynamic autoscaling | Project 07, the call centre, where scaling is the design |
| 34 | Density and performance economics | Project 07 |
| 35 | Cost architecture | Project 03, where cost governance is the engagement |
| 36 | HA within a region | Project 13, multi-region |
| 37 | Multi-region and DR architecture | Projects 13 and 14 |
| 38 | Backup, recovery and DR testing | Project 14 |
| 42 | PowerShell and CLI toolkit | Distributed across projects as used |
| 43 | Infrastructure as code for AVD | Project 03, where IaC at scale is the problem |
| 44 | Operational automation | Project 03 and Project 15 |
| 45 | The 10-layer isolation method | Project 15, the live incident |
| 46 | Connection, access and identity failures | Project 15 |
| 47 | Experience, profile, storage and performance failures | Project 15 |
| 48 to 51 | Interview questions and mock interviews | Assembled from project interview sections into Part XV |
| 52 | Decision frameworks | Assembled from project architecture decisions into Part XVII |
| 53 to 54 | Capstone | Unchanged. Northwind Global Manufacturing |

Nothing is lost. The [concept coverage map](concept-coverage-map.md) tracks every topic and where it is taught, and is updated as each project is written.

---

## 4. Why this is better

**Concepts stick when they solve a problem.** A reader learns scaling plans faster inside a call centre engagement with a 06:00 shift start than in a chapter about scaling plans.

**It removes repetition.** Security, monitoring and governance would otherwise be explained once in theory and again in every project. Now they are explained once, in the engagement where they matter most, and referenced afterwards.

**It matches how the knowledge is used.** Nobody is asked to explain Chapter 33. They are asked to design for a call centre.

**It removes filler.** Some remaining chapters would have been thin. Chapter 34 on density economics is three pages of real content wrapped in structure. Inside Project 07 it is the heart of the engagement.

---

## 5. What this does not change

- Chapters 1 to 25 and their numbering
- The 20 labs and their dependency chain
- The chapter contract, operations standard and diagram standard, which projects also follow
- Northwind Global Manufacturing, reserved for the capstone
- Naming conventions, terminology, Terraform patterns

---

## 6. Revised project order

Reordered so that concepts are introduced where they are most needed, and so each project can build on the previous ones.

| Order | Project | Concepts introduced here |
|---|---|---|
| 1 | 01 SMB, cost sensitive | Published. Cost modelling at small scale |
| 2 | 02 500 to 1,000 user enterprise | Monitoring architecture, AVD Insights, KQL, alerting, day-2 operations |
| 3 | 07 Call centre, high density | Scaling plans, dynamic autoscaling, density economics |
| 4 | 06 BYOD and remote workforce | Session hardening, redirection controls, screen capture protection |
| 5 | 04 Hybrid Active Directory | GPO and Intune coexistence, DC placement at scale |
| 6 | 05 Entra-only, cloud native | Cloud-native operating model |
| 7 | 08 Developer and engineering | Personal pools at scale, local admin risk |
| 8 | 10 RemoteApp and line of business | App Attach packaging in practice |
| 9 | 09 GPU and CAD | GPU sizing, drivers, capacity |
| 10 | 11 Highly secure and regulated | Zero Trust, Private Link, data security, audit evidence |
| 11 | 13 Multi-region architecture | HA within a region, multi-region design |
| 12 | 14 Disaster recovery | Backup, recovery, DR testing |
| 13 | 12 Citrix to AVD migration | Brownfield migration, parallel run, application assessment |
| 14 | 03 3,000+ user global enterprise | IaC at scale, cost governance, operational automation |
| 15 | 15 Production troubleshooting | The 10-layer isolation method, incident recovery |

Project 03 moves late deliberately. A global enterprise engagement is the synthesis of everything before it, and writing it early would mean explaining concepts twice.
