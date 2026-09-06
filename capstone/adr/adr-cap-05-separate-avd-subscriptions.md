# ADR-CAP-05: Separate Platform and AVD Landing Zone Subscriptions

**Status:** Accepted
**Date:** August 2026
**Applies to:** [Part B](../parts/part-b-enterprise-landing-zone.md), section 2.2; [Part E](../parts/part-e-avd-landing-zone.md), section 1

## Context

The enterprise landing zone (Parts B-D) and the AVD Landing Zone (Part E) needed a decision about whether they share a subscription or are genuinely separate billing and governance boundaries - a decision that determines whether the platform/workload distinction this capstone is built around is real or only a documentation convention.

## Options considered

**One shared subscription for the whole estate.** Simpler subscription management, fewer moving parts to track.

**Separate subscriptions - three platform, two AVD - each in its correct management group node.** More subscriptions to manage, but a real, enforced blast-radius boundary.

## Decision

Five distinct subscriptions: `sub-northwind-identity`, `sub-northwind-connectivity`, `sub-northwind-management` (Platform), `sub-northwind-avd-prod`, `sub-northwind-avd-nonprod` (Corp landing zone).

## Reasoning

A subscription is Azure's actual enforcement boundary for budget, RBAC scope, and policy assignment - not a naming convention. [Project 03](../../scenarios/project-03-global-enterprise-governance.md) already proved this distinction matters at a different customer: a single shared subscription means a policy mistake or compromised credential in the AVD workload can reach identity and connectivity directly. Separate subscriptions mean it structurally cannot.

## Consequences

This is the decision that makes every "AVD consumes, does not own" claim throughout Parts E-H checkable, not just asserted - a reader can verify the boundary by checking which subscription a resource lives in, not by trusting a diagram's color-coding.
