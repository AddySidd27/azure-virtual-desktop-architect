# Operations and Troubleshooting Standard

Operations and troubleshooting content in this book has to be usable at 09:10 on a Monday, with users waiting. Not a list of common problems. Not theory.

This standard applies to every chapter and lab that touches operations or troubleshooting.

---

## 1. Every troubleshooting scenario uses the same format

Revised from Chapter 19 onward. The nine core steps are unchanged. Three fields are added: business impact, architect lesson and interview lesson.

| Step | What it must contain |
|---|---|
| **Problem** | One sentence, as the business would describe it |
| **Symptoms** | What users, the helpdesk and the portal actually report, including the wrong assumptions people make |
| **Business impact** | Who is affected, how many, and what it costs. A number where one exists |
| **Initial assumption** | What an experienced engineer suspects first, and why |
| **Investigation** | Exact steps. Portal paths, PowerShell, Azure CLI, KQL, Event Viewer locations |
| **Evidence** | What the output looks like when the assumption is right, and when it is wrong |
| **Root cause** | The actual cause, stated plainly |
| **Resolution** | Exact commands or portal steps, with anything destructive called out |
| **Validation** | How you prove it is fixed. Not "users say it works" |
| **Prevention** | Monitoring, alerting, process or design change that stops it recurring |
| **Architect lesson** | The design principle worth keeping after the detail fades |
| **Interview lesson** | How to tell this story in an interview, and what it demonstrates |

A scenario that skips Investigation or Validation is not finished.

---

## 2. Commands must be real and complete

- Give the full command, copy and paste ready, with the book's naming convention.
- Say what the command does before showing it.
- Show what correct output looks like.
- List the common errors and what they mean.
- Name the module or extension and any version dependency.
- Never invent syntax. Verify against Microsoft documentation.

Where a check exists in more than one place, show the fastest one first. An engineer under pressure needs the quickest reliable answer, not the most elegant one.

**Portal paths must be exact.** Write the full click path, for example: *Azure portal > Azure Virtual Desktop > Host pools > `hp-avd-lab-eus2-01` > Session hosts*. Not "find your host pool in the portal".

**Event Viewer paths must be exact.** For example: *Event Viewer > Applications and Services Logs > Microsoft > Windows > RemoteDesktopServices-RdpCoreCDV > Operational*.

---

## 3. Three production scenarios minimum

Every major troubleshooting area needs at least three realistic scenarios, drawn from different environments. Do not invent a third one to hit the number. If an area genuinely supports two strong scenarios, use two and say so.

Scenarios should span the settings this book uses throughout: small business, large enterprise, hybrid AD, remote and BYOD workers, call centres, developers, regulated workloads and multi-region deployments.

---

## 4. Every troubleshooting area answers the architect's four questions

State these explicitly, not by implication.

**What do I check first?** The single fastest check that eliminates the largest number of causes.

**What can I safely change right now?** Reversible actions that do not affect other users. Drain mode on one host, restarting an agent, a targeted policy refresh.

**What must not be changed blindly?** Actions that are hard to reverse or that affect everyone. Changing VNet DNS, editing host pool RDP properties in production, rotating storage keys, removing a session host from a host pool, changing an identity source on a storage account, mass logoff.

**When do I escalate to Microsoft?** Give real criteria. Service health shows an active incident. The failure is inside a Microsoft-managed component and you have evidence. You have isolated the cause to platform behaviour that contradicts documentation. Say what evidence to collect before opening the case, because the first thing support asks for is data you may no longer have.

---

## 5. Operations content must cover Day 1 and Day 2

**Day 1, building it.** Provisioning, image build and publish, host pool creation, session host deployment, assignment, first validation, go-live checks, handover to operations.

**Day 2, running it.** Patching, drain mode, session host replacement, image updates and rolling upgrades, FSLogix maintenance, profile cleanup, monitoring and alerting, capacity management, scaling changes, incident response, change management, backup and DR testing, and the runbooks that hold it together.

Every operational procedure must be written so the reader can perform it in the lab environment built in Labs 1 to 20. If a procedure cannot be done in the lab, say so and explain what production would look like.

---

## 6. Runbook format

Operational runbooks in this book use a fixed shape so they can be lifted straight into a customer environment.

```
Runbook: <name>
Trigger:        what causes this to run
Owner:          which role runs it
Prerequisites:  access, tooling, approvals
Impact:         who is affected and how
Rollback:       how to undo it
Steps:          numbered, exact commands
Validation:     how success is confirmed
Escalation:     who to contact and when
```

---

## 7. Honesty rules

- If a fix has a risk, state the risk.
- If an action is irreversible, say so before the command, not after.
- If the real answer is "rebuild the session host", say that. Rebuilding is often correct and faster than repairing.
- If something can only be fixed by Microsoft, say so rather than inventing a workaround.
- Mark anything unverified as `[VERIFY BEFORE IMPLEMENTATION]`.
