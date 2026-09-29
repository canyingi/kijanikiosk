# Cloud Service Model

## Decision

For the KijaniKiosk platform, the recommended starting model is a **combination of PaaS and selected IaaS**, with SaaS used for supporting business capabilities where appropriate.

For this Week 1 foundation, the primary application hosting choice is **PaaS**.

## Why PaaS?

KijaniKiosk needs to focus on building and operating an online platform rather than spending most of its early engineering effort maintaining operating systems and servers.

A PaaS approach can provide:

- Managed application runtime.
- Managed scaling options.
- Integrated monitoring and deployment capabilities.
- Reduced operating-system maintenance.
- Faster delivery for a small engineering team.

This supports the DevOps goal of delivering application changes frequently while reducing undifferentiated infrastructure work.

## Where IaaS still fits

IaaS can be used where the team needs more control, for example:

- A custom virtual machine workload.
- Special networking requirements.
- Legacy software that cannot run on the selected PaaS.
- Infrastructure components that require operating-system-level control.

The architecture should avoid choosing IaaS simply because it provides more control. More control also means more responsibility for patching, hardening, monitoring and availability.

## SaaS

SaaS can be appropriate for supporting functions such as collaboration, email, issue tracking or other business tools where KijaniKiosk does not need to operate the underlying software.

## Decision principle

Start with managed services where they meet the requirements. Introduce lower-level infrastructure only when a real technical requirement justifies the additional operational responsibility.
