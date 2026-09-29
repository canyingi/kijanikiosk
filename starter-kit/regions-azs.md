# Region and Availability Zone Design

## Proposed AWS region

For this learning architecture, use **AWS Africa (Cape Town), `af-south-1`**, as the example deployment region.

The final production region should be confirmed against latency, service availability, data-residency requirements, disaster-recovery requirements and cost before launch.

## Why a region matters

An AWS Region is a separate geographic area containing multiple Availability Zones. Choosing a region close to the primary customer base can reduce network latency, while regulatory and data-residency requirements may also affect the decision.

For a Kenya-focused platform, Cape Town is a reasonable regional starting point for this exercise because it is an African AWS region. It should not be treated as an automatic production decision; actual latency and business requirements should be measured.

## Multi-Availability-Zone thinking

Do not put every production component into one Availability Zone.

A stronger design distributes failure-sensitive components across at least two Availability Zones where the selected AWS services support it.

Example:

```text
AWS Region: af-south-1
|
+-- Availability Zone A
|   +-- Public subnet
|   +-- Application capacity
|
+-- Availability Zone B
    +-- Public subnet
    +-- Application capacity
```

For a production design, private application and database tiers should also be considered across multiple AZs where supported.

## Reliability reasoning

An AZ-level failure should not automatically make the whole application unavailable.

Multi-AZ design helps reduce the blast radius of:

- Power or facility failures.
- Network failures affecting an AZ.
- Maintenance events.
- Local infrastructure failures.

Multi-AZ does not remove every failure mode. Application bugs, bad deployments, data corruption and account-level incidents can still affect multiple AZs, so backups, monitoring, deployment controls and recovery procedures remain necessary.

## Practical starter architecture

For this Week 1 exercise:

- One AWS Region.
- At least two AZs for the application tier in the conceptual design.
- Public entry points only where required.
- Private application/data resources where direct internet exposure is unnecessary.
- Backups and recovery planning as a separate reliability control.
