# IAM Least-Privilege Design

## Use case

The KijaniKiosk application has an application component that needs to read and write product/catalog objects in one S3 bucket.

The component does **not** need:

- IAM administration.
- EC2 administration.
- Access to every S3 bucket.
- Permission to delete the entire bucket.
- Access to unrelated AWS services.

## Example role

Role name:

`KijaniKioskCatalogAppRole`

The role is intended for an application workload, not for human administrators.

## Example policy

Replace the example bucket ARN with the actual production resource ARN before use.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ListOnlyCatalogBucket",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": "arn:aws:s3:::kijaniosk-catalog-prod"
    },
    {
      "Sid": "ReadWriteCatalogObjects",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::kijaniosk-catalog-prod/products/*"
    }
  ]
}
```

## Why this is least privilege

The policy is scoped by both action and resource:

- `s3:ListBucket` applies only to the catalog bucket.
- `s3:GetObject` and `s3:PutObject` apply only to objects under `products/*`.
- No `s3:*` wildcard is granted.
- No delete permission is granted.
- No unrelated AWS service permissions are included.

The role should use temporary credentials supplied to the workload rather than embedding long-lived access keys in application code.

## Improvement after deployment

Permissions should be reviewed using actual access activity. Unused permissions should be removed and the policy refined as the workload becomes better understood.

## Important note

This is a design example for the assignment. Before production deployment, validate the policy with AWS IAM Access Analyzer and confirm the exact resources and actions required by the application.
