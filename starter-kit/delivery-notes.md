# DevOps Delivery Notes

## 1. Flow

Flow means moving useful work from idea to a usable result with as little unnecessary delay and rework as possible.

For KijaniKiosk, the workflow is:

1. Break the architecture work into small deliverables.
2. Create a short-lived `feature/*` branch.
3. Complete one logical change at a time.
4. Commit with clear messages.
5. Open a Pull Request into `develop`.
6. Review and integrate the change.
7. Promote stable work from `develop` to `main`.

This keeps changes small and makes it easier to see where work is blocked.

## 2. Feedback

Feedback is built into the workflow rather than waiting until the end.

Examples:

- Pull Request review checks the quality and clarity of the documentation.
- A reviewer can challenge assumptions such as why a private subnet is needed.
- IAM policies can be validated and refined before production use.
- Architecture diagrams make routing decisions visible to the team.
- Small commits make defects easier to trace and correct.

## 3. Learning

Learning means using feedback and results to improve the next change.

For this starter kit, learning could include:

- Reviewing whether the selected cloud services actually meet application needs.
- Checking which IAM permissions the application really uses and removing unused permissions.
- Reviewing incidents or failed deployments to improve the workflow.
- Updating the architecture as traffic, availability requirements and security needs grow.

## Delivery principle

The goal is not to design the most complicated infrastructure. The goal is to create a clear foundation that can be tested, reviewed, improved and extended.

## Example commit sequence

```text
docs: add DevOps delivery notes
docs: document cloud service model
docs: explain region and multi-AZ strategy
security: add least-privilege IAM example
docs: add network topology and routing notes
```
