# ADR-CAP-02: Hub-and-Spoke, Not Virtual WAN

**Status:** Accepted
**Date:** August 2026
**Applies to:** [Part C](../parts/part-c-identity-connectivity-foundation.md), section 2

## Context

Northwind's platform spans two Azure regions (East US 2, West Europe), each with ExpressRoute connectivity, requiring a network topology decision at the platform layer before any spoke - identity or workload - could be built.

## Options considered

**Azure Virtual WAN.** Provides automated any-to-any transit and simplified branch connectivity at scale. Microsoft's own guidance, already cited directly in this book's [Chapter 12](../../chapters/ch12-enterprise-topologies-ip-planning.md), states the actual trigger: *"the trigger is more than two regions plus a need for global transit, not spoke count on its own."*

**Hub-and-spoke, one hub per region, directly peered.** The traditional pattern, requiring explicit peering configuration rather than automated transit, but proportionate to a two-region estate with no stated need for global any-to-any transit.

## Decision

Hub-and-spoke, one hub per region, peered directly to each other with no shared transit component.

## Reasoning

Northwind has exactly two regions and no requirement, stated anywhere in this engagement's discovery, for transit beyond what direct hub-to-hub peering already provides. Microsoft's own cited trigger for Virtual WAN is not met. Building Virtual WAN's automation for a two-region estate would be solving a scale problem Northwind does not have.

## Consequences

If Northwind adds a third region with genuine multi-region transit needs, that is the point Virtual WAN's own stated trigger is actually met, and this decision should be revisited then - not before.
