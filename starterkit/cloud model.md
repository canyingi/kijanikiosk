# Cloud Service Model

## Decision

KijaniKiosk should primarily use a combination of PaaS and selected IaaS services, with SaaS used for supporting business functions where appropriate.

For the initial application hosting approach, PaaS is the preferred model.

## Why PaaS?

KijaniKiosk is an online platform and the engineering team should focus on application functionality rather than spending most of its time managing operating systems and servers.

PaaS can provide:

- Managed application runtime.
- Easier deployment.
- Scaling capabilities.
- Reduced operating system maintenance.
- Integrated monitoring and deployment capabilities.

This supports the DevOps objective of delivering changes efficiently.

## Where IaaS may be used

IaaS can be introduced when the team needs greater infrastructure control.

Examples include:

- Custom virtual machine workloads.
- Specific networking requirements.
- Applications that require operating-system-level configuration.
- Legacy applications that cannot run on the selected PaaS platform.

IaaS provides more control but also creates additional responsibility for patching, security and maintenance.

## SaaS

SaaS can be used for supporting business capabilities such as:

- Email.
- Collaboration.
- Issue tracking.
- Other managed business applications.

## Decision principle

KijaniKiosk should prefer managed services where they satisfy the technical requirements and introduce lower-level infrastructure only when there is a clear reason to do so.
