# Pull Request Description

## Title

`docs: add KijaniKiosk DevOps starter kit`

## Summary

This Pull Request adds the initial engineering foundation for the KijaniKiosk platform.

## Included

- DevOps delivery notes covering Flow, Feedback and Learning.
- Cloud service-model reasoning with PaaS as the primary application-hosting approach.
- Region and multi-Availability-Zone reliability reasoning.
- Least-privilege IAM policy for a catalog application component.
- Public/private subnet architecture and routing explanation.
- Network topology diagram.

## Engineering reasoning

The design intentionally favors clear boundaries and managed services over unnecessary infrastructure complexity. The IAM example limits access to a specific S3 bucket and object path, while the network design separates internet-facing resources from private workloads.

## Review checklist

- [ ] Documentation is clear and internally consistent.
- [ ] IAM permissions are scoped to the intended task.
- [ ] Public/private routing is correct.
- [ ] Multi-AZ reasoning is documented.
- [ ] Diagram matches the routing explanation.
- [ ] No secrets or credentials are committed.

## Testing / validation

This is an architecture/documentation change. Validation consists of reviewing the IAM JSON, checking the route logic, and confirming that the diagram and written explanation agree.
