# ADR-CAP-03: Bangalore Served via Internet Path, Not a Dedicated Region

**Status:** Accepted
**Date:** August 2026
**Applies to:** [Part E](../parts/part-e-avd-landing-zone.md), section 4

## Context

Bangalore has no ExpressRoute (Part A, C-02) and is not assigned to either Azure region by any existing chapter. Its connectivity had to be resolved once the AVD Landing Zone's network spokes existed to connect into, not before.

## Options considered

**A dedicated third Azure region for Bangalore.** Lower latency for Bangalore's users, at the cost of a new hub, a new identity footprint, and real ongoing platform cost - directly against the cost ceiling (Part A, BR-05).

**Internet-based access to the West Europe AVD workspace, secured by Conditional Access.** No new platform region, no new hub. Bangalore users connect over the public internet, with Conditional Access requiring a compliant device and MFA before a session is granted.

## Decision

Bangalore connects to the West Europe AVD workspace over the internet, secured by Conditional Access.

## Reasoning

The entire resolution lives inside the AVD Landing Zone's workload-layer configuration - no platform-level change is required at all, which is itself the point of separating the enterprise landing zone from the AVD Landing Zone: a workload-scoped decision should not need to reach into the platform to be made. A dedicated region's cost is not justified by Bangalore's share of the estate against a hard cost ceiling that Conditional Access already satisfies.

## Consequences

West Europe's scaling plan (Part H4) carries a deliberately wider active window than East US 2's specifically to cover Bangalore's business hours across the real timezone gap with Amsterdam - a direct, ongoing consequence of this decision, not an unrelated design choice.
