# DevOps Delivery Notes

## Flow

Flow means moving work from an idea to a usable result efficiently while reducing unnecessary delays and rework.

For KijaniKiosk, the workflow is:

1. Break the architecture work into small deliverables.
2. Create a short-lived feature branch.
3. Make one logical change at a time.
4. Commit changes using clear commit messages.
5. Open a Pull Request into `develop`.
6. Review the changes.
7. Merge approved work into `develop`.
8. Promote stable work to `main`.

This approach keeps changes small and makes it easier to identify where work is blocked.

## Feedback

Feedback is included throughout the development process.

Examples include:

- Pull Request reviews.
- Reviewing architecture decisions.
- Checking IAM permissions before deployment.
- Reviewing network routing.
- Comparing the network diagram with the written architecture.
- Using Git history to understand changes.

Feedback allows the team to identify problems before they become production issues.

## Learning

Learning means using feedback and experience to improve future work.

For KijaniKiosk, learning includes:

- Reviewing whether selected cloud services meet application requirements.
- Reviewing IAM access and removing permissions that are not required.
- Learning from deployment or infrastructure problems.
- Improving documentation based on team feedback.
- Updating the architecture as the platform grows.

## Git collaboration

The repository uses:

- `main` for stable work.
- `develop` for integrated development work.
- `feature/*` for individual changes.

The feature branch used for this project is:

`feature/starter-kit-files`

Changes are submitted through a Pull Request before being merged into `develop`.

## DevOps principle

The goal is to continuously improve the system through small changes, fast feedback and learning rather than waiting until the end of the project to discover problems.
