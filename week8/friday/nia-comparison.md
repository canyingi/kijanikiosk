# KijaniKiosk Container Delivery Pipeline: A Strategic Shift

Since Week 5, we have been asking what our engineering efforts actually provide the business. This week's work answers that question with specific, measurable improvements. We have moved from manual deployment methods to a fully automated container pipeline that guarantees consistency, speeds up recovery, and drastically reduces our server footprint.

## What Changed: Week 7 vs. Week 8

| Concern | How Week 7 Addressed It | How Week 8 Addresses It |
| :--- | :--- | :--- |
| **Deployment Mechanism** | Manual configuration and environment-specific scripts. Error-prone and inefficient. | Immutable container images stored in a private registry. Deployments are applied using configuration files and consistently. |
| **Rollback Mechanism** | Re-running legacy deployment scripts and hoping the previous state was accurately captured. | Immediate rollback to any previous version by simply referencing the exact, versioned image tag in the registry. |
| **Failure Recovery** | Manual intervention required to restart crashed services, leading to extended downtime. | Automated self-healing. If a process fails, the orchestrator detects it and automatically restarts a replacement. |
| **Scaling** | Vertical scaling (buying bigger servers) or manual provisioning of new instances. | Horizontal scaling. We can instantly increase the number of running application replicas to handle traffic spikes. |

## The Numbers That Matter

Two specific metrics from this week's engineering work demonstrate the tangible value of this transition.

First, **resilience**. During our failure recovery testing, we manually terminated a running application process to simulate a crash. The system automatically detected the failure and spun up a healthy replacement in exactly **37 seconds**. This means that in a real-world scenario, a server crash results in less than a minute of degraded performance, with zero manual intervention from our engineering team.

Second, **efficiency**. By rebuilding our application using a multi-stage production process, we reduced the final image size to **89.8 MB**. This dramatic reduction means faster deployment times, less storage space required in our registry, and a significantly smaller security attack surface, as we are no longer shipping unnecessary build tools or development dependencies into production.

## What This Does Not Solve Yet

We must be honest about the current limitations as we present this to the board. While this week's deployment pipeline is a massive leap forward, it is not yet fully production-complete. Currently, the system ensures that a replacement process is *running*, but it does not guarantee that the application is fully warmed up and *ready to receive traffic* the moment it starts. If a replacement starts in 37 seconds, there is a brief window where it might receive a user request before it is fully prepared. 

Furthermore, our current configuration ties environment-specific settings directly into the deployment files. Next week, we will introduce dedicated configuration management, separating our application code from the environment it runs in, and introducing strict readiness checks to ensure zero-downtime deployments. We are building a robust foundation, but the final layer of production hardening comes next.
