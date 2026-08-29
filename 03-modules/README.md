
## Terraform Modules

**File:** `README.md`

Terraform modules provide a structured way to package and reuse Terraform configuration. They help reduce code duplication, standardize infrastructure implementations, and make Terraform projects easier to maintain and scale.

This section covers Terraform Modules from fundamentals through practical implementation.

## What We Learn

* What Terraform modules are
* Why modules are required
* Root modules and child modules
* Local modules
* Git/GitHub modules
* Terraform Registry modules
* Module inputs and outputs
* Module versioning
* Module design best practices
* Security considerations
* Module troubleshooting
* End-to-end module implementation

## Documentation

| Document                           | Description                      |
| ---------------------------------- | -------------------------------- |
| [`01-modules.md`](./01-modules.md) | Complete Terraform Modules guide |

## Practical Project

The [`project-ec2-module`](./project-ec2-module/) directory contains a hands-on implementation demonstrating how to:

1. Build a regular Terraform EC2 project.
2. Identify reusable infrastructure configuration.
3. Convert the EC2 configuration into a child module.
4. Pass input variables to the module.
5. Expose values through module outputs.
6. Consume the module from the root module.
7. Validate and execute the module-based configuration.
8. Destroy the infrastructure after completing the lab.

### Project Structure

```text
project-ec2-module/
├── README.md
├── versions.tf
├── main.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
│
└── modules/
    └── ec2/
        ├── README.md
        ├── versions.tf
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Terraform Workflow

The practical implementation follows the standard Terraform workflow:

```text
Write Configuration
        |
        v
terraform fmt
        |
        v
terraform init
        |
        v
terraform validate
        |
        v
terraform plan
        |
        v
terraform apply
        |
        v
Validate Infrastructure
        |
        v
terraform destroy
```

## Prerequisites

Before executing the project, ensure that the following are available:

* Terraform
* AWS CLI
* AWS account
* Configured AWS authentication
* Git
* GitHub
* A code editor such as VS Code

Verify Terraform:

```bash
terraform version
```

Verify AWS CLI:

```bash
aws --version
```

Verify AWS authentication:

```bash
aws sts get-caller-identity
```

## Cleanup

The lab creates AWS infrastructure. After completing the exercise, destroy the resources:

```bash
terraform destroy
```

Do not delete Terraform state as a substitute for destroying infrastructure.

## Related Section

[02 — Terraform Configuration](../02-terraform-configuration/)

## Learning Outcome

After completing this section, we should be able to design, consume, and maintain reusable Terraform modules and understand how modules fit into a scalable Infrastructure as Code architecture.
