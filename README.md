# KijaniKiosk DevOps Foundation

This repository contains the DevOps Starter Kit for the KijaniKiosk online platform.

## Project objectives

The project documents the engineering foundations required before launching the KijaniKiosk platform:

- DevOps Flow, Feedback and Learning
- Git collaboration and branching
- Cloud service model selection
- Region and Availability Zone reliability
- IAM least privilege
- Public/private network segmentation

## Repository workflow

The project uses the following Git workflow:

main
  |
develop
  |
feature/starter-kit-files

Feature work is developed on a feature branch, reviewed through a Pull Request into develop, and stable changes can later be promoted to main.

## Starter Kit

The `starter-kit` directory contains:

- `delivery-notes.md`
- `cloud-model.md`
- `regions-azs.md`
- `iam-least-privilege.md`
- `network-routing.md`
- `network-topology.png`

## Architecture

The network design uses:

- VPC: `10.0.0.0/16`
- Public subnet: `10.0.0.0/24`
- Private subnet: `10.0.11.0/24`
- Internet Gateway attached to the VPC
- Internet routing only from the public subnet
- Least-privilege IAM access for a defined application task
