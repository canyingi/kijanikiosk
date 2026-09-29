# Network Segmentation and Routing

## Addressing example

Use a dedicated VPC such as:

`10.0.0.0/16`

Example subnets:

- Public subnet A: `10.0.1.0/24`
- Private subnet A: `10.0.11.0/24`
- Public subnet B: `10.0.2.0/24`
- Private subnet B: `10.0.12.0/24`

The assignment asks for public/private segmentation. Two AZs are shown to make the reliability model consistent with the region/AZ document.

## Public subnet

The public subnet route table contains:

`0.0.0.0/0 → Internet Gateway`

A resource also needs a public address to be directly reachable through the internet gateway.

Typical public resources can include internet-facing load-balancing or NAT components.

## Private subnet

The private subnet has no direct route to the Internet Gateway.

If private workloads need outbound internet access for updates or external APIs, a production design can place a NAT Gateway in a public subnet and route:

`Private subnet → NAT Gateway → Internet Gateway → Internet`

This provides outbound connectivity without making the private workload directly reachable from the public internet.

## Security reasoning

Segmentation reduces unnecessary exposure:

- Internet-facing components are separated from internal application/data resources.
- Private resources do not need public IP addresses for normal internal operation.
- Security groups can further restrict which application components can communicate.
- Database resources should remain private and accept traffic only from approved application components.

## Availability

For production, consider a NAT Gateway per active AZ so a single-AZ failure does not make private workloads dependent on a NAT component in another AZ.
