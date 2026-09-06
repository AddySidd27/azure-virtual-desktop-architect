# ADR-CAP-07: No Active-Passive DR Capability Exists; Recommend Finance-First Investment, Conditional on Approval

**Status:** Accepted as an honest finding and a conditional recommendation - not as a completed capability
**Date:** August 2026
**Applies to:** [Part H](../parts/part-h-operations-dr-monitoring-finops.md), section 2

## Context

The master plan's H2 names "active-passive cross-region relationship" as Northwind's intended DR pattern. Part H's own inspection, before any new design work began, confirmed by direct search across the entire capstone Terraform tree that **no such infrastructure exists anywhere** - no warm-standby toggle, no cross-region failover target, no rehearsed runbook, for any of the five personas, in either direction.

## What exists today, and why it is not disaster recovery

Two independently active regions (Parts E-F) and cross-region FSLogix data redundancy via Cloud Cache (Part F9) are real, built capabilities. Neither is disaster recovery. Redundant data with no compute path to reach it - no host pool, no reserved capacity, no workspace assignment in the surviving region for the failed region's users - is not a working recovery, only a component of one.

## Options considered

**Build full active-passive DR for all five personas, both directions, now.** Would require approximately ten additional warm-standby host pools - close to doubling Part F's already-built footprint - using [Lab 19](../../labs/lab-19-disaster-recovery-failover.md)'s proven `deploy_active`-gated pattern. Rejected for this pass: a cost commitment of this scale requires Northwind's explicit approval, which this engagement does not have authority to grant on the customer's behalf, exactly as [Project 14](../../scenarios/project-14-disaster-recovery.md)'s DR engagement required explicit customer sign-off before building anything.

**Build nothing, note the gap, move on.** Rejected: naming a real gap without a reasoned next step would leave the finding inert.

**Recommend a specific, justified starting point, built only once approved.** Finance: the smallest pooled persona, the compliance weight that makes downtime costliest to justify after the fact, and a natural extension of the storage-isolation conversation ADR-CAP-06 already opened.

## Decision

No DR infrastructure is built in this pass. The recommendation - finance-first, using Lab 19's proven pattern - is recorded as a conditional next step, explicitly requiring Northwind's business and compliance stakeholders to approve the cost before any Terraform is written for it.

## Consequences

This capstone's own architecture is not claimed as "DR-complete." The per-component RTO/RPO table in Part H, section 2.7, states plainly where a real recovery mechanism exists and where none does. Any future work building the finance-first recommendation should update this ADR's status, not silently supersede it.
