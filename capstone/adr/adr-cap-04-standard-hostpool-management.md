# ADR-CAP-04: Standard Host-Pool Management, Not Session Host Configuration

**Status:** Accepted
**Date:** August 2026
**Applies to:** [Part F](../parts/part-f-avd-platform-architecture.md), sections 2-3

## Context

Chapter 16 originally designed Northwind's three pooled host pools (task, knowledge, finance) around Session Host Configuration (Automated Host Pools), written before this book's Labs 11-20 rigorously verified SHC's actual tooling maturity.

## Options considered

**Session Host Configuration**, as Chapter 16 originally assumed. Centralized image and configuration management, well-suited to large, homogeneous, frequently-updated pools.

**Standard host-pool management**, per the existing [book-wide ADR](../../appendices/adr-shc-vs-standard-host-pools.md). Requires explicit drain-and-replace for updates, but uses fully GA, stable tooling throughout.

## Decision

Standard host-pool management for all ten of Northwind's host pools (five personas x two regions).

## Reasoning

Labs 11-20 found no stable Terraform resource for SHC, PowerShell cmdlets marked explicitly preview, and an ARM API that has never shipped non-preview. A production platform for 3,200 users should not depend on three simultaneously-unstable tooling paths for a required capability. Chapter 16's underlying intent - that large, homogeneous pools benefit from centralized management - is preserved as the architectural rationale; the implementation mechanism is corrected.

## Consequences

Session host updates require the explicit drain-and-replace discipline this book has used since Labs 14-20, not SHC's automated in-place update model. This is documented in Part F as the accepted operational cost of using GA-safe tooling.
