
## Project — AWS EC2 Instance Provisioning Using Terraform

> **Path:** `Terraform-Guide/01-getting-started/project-ec2-instance/`

## Table of Contents

1. [Project Objective](#1-project-objective)
2. [What We Will Learn](#2-what-we-will-learn)
3. [Prerequisites](#3-prerequisites)
4. [Project Structure](#4-project-structure)
5. [AWS Authentication](#5-aws-authentication)
6. [Configure the AWS Region](#6-configure-the-aws-region)
7. [Select a Valid AMI](#7-select-a-valid-ami)
8. [Review the Terraform Configuration](#8-review-the-terraform-configuration)
9. [Format the Configuration](#9-format-the-configuration)
10. [Initialize Terraform](#10-initialize-terraform)
11. [Validate the Configuration](#11-validate-the-configuration)
12. [Generate a Terraform Plan](#12-generate-a-terraform-plan)
13. [Apply the Configuration](#13-apply-the-configuration)
14. [Verify the EC2 Instance](#14-verify-the-ec2-instance)
15. [Inspect Terraform State](#15-inspect-terraform-state)
16. [Modify the Infrastructure](#16-modify-the-infrastructure)
17. [Review the Updated Plan](#17-review-the-updated-plan)
18. [Destroy the Infrastructure](#18-destroy-the-infrastructure)
19. [Verify Destruction](#19-verify-destruction)
20. [Complete Terraform Lifecycle](#20-complete-terraform-lifecycle)
21. [Troubleshooting](#21-troubleshooting)
22. [Security Rules](#22-security-rules)
23. [Project Completion Criteria](#23-project-completion-criteria)
24. [Key Learning](#24-key-learning)
25. [Command Reference](#25-command-reference)

## 1. Project Objective

The objective of this project is to provision an **Amazon EC2 instance using Terraform**.

This is our first practical Terraform project and demonstrates the fundamental Infrastructure as Code workflow:

```text
Terraform Configuration
        ↓
terraform init
        ↓
terraform validate
        ↓
terraform plan
        ↓
terraform apply
        ↓
AWS EC2 Instance
        ↓
Terraform State
        ↓
terraform destroy
```

The project intentionally keeps the infrastructure simple.

We are focusing on:

* Terraform configuration
* AWS provider
* Terraform resources
* EC2 provisioning
* AMI selection
* Instance type
* Tags
* Terraform initialization
* Terraform validation
* Terraform planning
* Terraform application
* Terraform state
* Terraform destruction

We are **not** introducing VPC, subnet, security group, networking, or SSH configuration in this first project. Those concepts can be covered in dedicated AWS/Terraform projects later.

## 2. What We Will Learn

By completing this project, we will understand how Terraform:

1. Defines infrastructure using HCL.
2. Uses a provider to communicate with AWS.
3. Represents infrastructure using resources.
4. Initializes provider dependencies.
5. Validates Terraform configuration.
6. Generates an execution plan.
7. Creates AWS infrastructure.
8. Tracks managed infrastructure using state.
9. Detects configuration changes.
10. Destroys managed infrastructure.

The fundamental Terraform model is:

```text
HCL Configuration
        ↓
     Terraform
        ↓
   AWS Provider
        ↓
      AWS API
        ↓
   AWS Infrastructure
```

## 3. Prerequisites

Before starting, verify that the following are available:

* AWS account
* Terraform
* AWS CLI
* Git
* Text editor or VS Code
* Appropriate AWS permissions

### Verify Terraform

Run:

```bash
terraform version
```

Example:

```text
Terraform v1.x.x
```

The exact version may differ depending on the environment.

### Verify AWS CLI

Run:

```bash
aws --version
```

### Verify AWS Authentication

Run:

```bash
aws sts get-caller-identity
```

A successful response confirms that the AWS CLI can authenticate with AWS.

> We should verify AWS authentication before running Terraform.

## 4. Project Structure

The project contains only the files required for this introductory exercise:

```text
project-ec2-instance/
├── main.tf
└── README.md
```

### `main.tf`

Contains the Terraform configuration.

### `README.md`

Contains the project documentation and execution steps.

After running Terraform, additional local files/directories will be created:

```text
project-ec2-instance/
├── .terraform/
├── .terraform.lock.hcl
├── main.tf
├── README.md
└── terraform.tfstate
```

The generated Terraform files should be handled according to the project's Git strategy.

## 5. AWS Authentication

Terraform needs permission to communicate with AWS.

For local learning, we can configure AWS CLI credentials using:

```bash
aws configure
```

The CLI may request:

```text
AWS Access Key ID
AWS Secret Access Key
Default region name
Default output format
```

Example:

```text
AWS Access Key ID:     <ACCESS-KEY>
AWS Secret Access Key: <SECRET-KEY>
Default region name:  us-east-1
Default output format: json
```

Never replace these placeholders with real credentials in documentation.

Verify authentication:

```bash
aws sts get-caller-identity
```

### Important

We should **not** place AWS credentials inside `main.tf`.

Avoid configurations such as:

```hcl
provider "aws" {
  access_key = "REAL_ACCESS_KEY"
  secret_key = "REAL_SECRET_KEY"
}
```

Terraform can use AWS's standard credential resolution mechanisms.

## 6. Configure the AWS Region

The project uses:

```text
us-east-1
```

which is the AWS **US East (N. Virginia)** region.

The provider configuration is:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

We can change the region if required:

```hcl
provider "aws" {
  region = "ap-south-1"
}
```

For example, `ap-south-1` is the AWS Mumbai region.

> The AMI selected for the project must be valid in the region configured in the provider.

## 7. Select a Valid AMI

An EC2 instance requires an Amazon Machine Image (AMI).

The AMI provides the operating-system/image template used to launch the instance.

Examples include:

```text
Amazon Linux
Ubuntu
Red Hat Enterprise Linux
```

For this project, we use a placeholder:

```hcl
ami = "REPLACE_WITH_VALID_AMI_ID"
```

Before running Terraform, replace it with a valid AMI ID for the selected AWS region.

Example format:

```hcl
ami = "ami-xxxxxxxxxxxxxxxxx"
```

### Important

AMI IDs are generally region-specific.

For example:

```text
us-east-1
    ↓
AMI-A

ap-south-1
    ↓
AMI-B
```

Therefore, we should never blindly copy an AMI ID from another region.

### Finding an AMI

We can use the AWS EC2 console and identify an appropriate AMI for the selected region.

The important requirement is:

```text
Terraform Provider Region
        =
AMI Region
```

## 8. Review the Terraform Configuration

Our complete `main.tf` is:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "terraform_demo" {
  ami           = "REPLACE_WITH_VALID_AMI_ID"
  instance_type = "t3.micro"

  tags = {
    Name        = "terraform-ec2-instance"
    Environment = "learning"
    ManagedBy   = "Terraform"
  }
}
```

Let's understand each section.

### Terraform Block

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
```

This declares the AWS provider dependency.

The provider source is:

```text
hashicorp/aws
```

The version constraint:

```text
~> 6.0
```

allows compatible AWS provider releases within the 6.x series according to Terraform's version constraint semantics.

Terraform uses this information during:

```bash
terraform init
```

### Provider Block

```hcl
provider "aws" {
  region = "us-east-1"
}
```

This tells Terraform:

```text
Provider → AWS
Region   → us-east-1
```

The provider configuration does **not** contain our AWS secret credentials.

### Resource Block

```hcl
resource "aws_instance" "terraform_demo" {
```

The first value:

```text
aws_instance
```

is the Terraform resource type.

The second value:

```text
terraform_demo
```

is the local Terraform resource name.

Together they identify the resource inside Terraform:

```text
aws_instance.terraform_demo
```

### AMI

```hcl
ami = "REPLACE_WITH_VALID_AMI_ID"
```

The AMI specifies the image used to launch the EC2 instance.

Before execution, replace the placeholder with a valid AMI ID.

### Instance Type

```hcl
instance_type = "t3.micro"
```

This specifies the EC2 instance type.

For a learning exercise, a small instance type may be appropriate, subject to AWS availability, account restrictions, and current pricing.

### Tags

```hcl
tags = {
  Name        = "terraform-ec2-instance"
  Environment = "learning"
  ManagedBy   = "Terraform"
}
```

Tags help us identify and organize resources.

The `Name` tag allows the instance to be easily identified in the AWS console.

## 9. Format the Configuration

From the project directory, run:

```bash
terraform fmt
```

Terraform formats the configuration according to standard Terraform formatting conventions.

Expected behavior:

```text
main.tf
  ↓
terraform fmt
  ↓
Formatted Terraform configuration
```

## 10. Initialize Terraform

Run:

```bash
terraform init
```

Terraform will:

1. Read the configuration.
2. Identify the required provider.
3. Download the AWS provider.
4. Create the local `.terraform/` working directory.
5. Generate or update `.terraform.lock.hcl`.
6. Prepare the project for Terraform operations.

The simplified flow is:

```text
main.tf
   ↓
terraform init
   ↓
Read required provider
   ↓
Download AWS Provider
   ↓
Initialize working directory
```

A successful initialization should end with a message similar to:

```text
Terraform has been successfully initialized!
```

## 11. Validate the Configuration

Run:

```bash
terraform validate
```

A successful validation should produce output similar to:

```text
Success! The configuration is valid.
```

Validation checks whether the Terraform configuration is syntactically and structurally valid.

> `terraform validate` does not prove that the AWS infrastructure can actually be created. AWS permissions, AMI availability, quotas, and other runtime conditions are evaluated when Terraform interacts with AWS.

## 12. Generate a Terraform Plan

Run:

```bash
terraform plan
```

Terraform evaluates the configuration and determines the changes required.

For a new project, we should expect approximately:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

The exact output can vary depending on the selected AMI and AWS environment.

Before proceeding, review:

```text
AWS Provider
AWS Region
AMI
Instance Type
Tags
```

The plan is an important review point.

```text
Terraform Configuration
        ↓
terraform plan
        ↓
Review Proposed Changes
        ↓
terraform apply
```

If the plan does not look correct, stop and fix the configuration before applying it.

## 13. Apply the Configuration

Run:

```bash
terraform apply
```

Terraform displays the proposed changes and normally asks for confirmation.

Example:

```text
Do you want to perform these actions?

  Only 'yes' will be accepted to approve.
```

Enter:

```text
yes
```

Terraform then:

```text
Terraform
    ↓
AWS Provider
    ↓
AWS API
    ↓
EC2 Instance
```

A successful operation should end with output similar to:

```text
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

## 14. Verify the EC2 Instance

Open the AWS EC2 console and navigate to:

```text
EC2
→ Instances
```

Verify that the Terraform-managed instance exists.

The instance should have the tag:

```text
Name = terraform-ec2-instance
```

We can also identify the Terraform resource using:

```text
aws_instance.terraform_demo
```

> This project is intentionally focused on provisioning the instance. SSH access, security groups, networking, and application deployment will be covered separately.

## 15. Inspect Terraform State

After a successful `terraform apply`, Terraform creates local state:

```text
terraform.tfstate
```

State is used by Terraform to track managed infrastructure.

The simplified relationship is:

```text
main.tf
   ↓
Desired Configuration
   ↓
Terraform
   ↓
terraform.tfstate
   ↓
Managed Infrastructure
```

### List Managed Resources

Run:

```bash
terraform state list
```

Expected:

```text
aws_instance.terraform_demo
```

This confirms that Terraform is tracking the EC2 instance.

## 16. Modify the Infrastructure

Let's make a small change.

Change:

```hcl
instance_type = "t3.micro"
```

to:

```hcl
instance_type = "t3.small"
```

Save the file.

We have now changed the desired configuration.

```text
Before:

instance_type = "t3.micro"

After:

instance_type = "t3.small"
```

## 17. Review the Updated Plan

Run:

```bash
terraform plan
```

Terraform evaluates the difference between the desired configuration and the currently managed infrastructure.

Depending on AWS and the provider behavior for the particular change, Terraform will determine whether the instance can be modified in place or must be replaced.

The important learning point is:

```text
Configuration Change
        ↓
terraform plan
        ↓
Terraform Determines Required Action
        ↓
Review
        ↓
terraform apply
```

If we want to apply the change:

```bash
terraform apply
```

Review the plan and confirm with:

```text
yes
```

## 18. Destroy the Infrastructure

After completing the lab, clean up the infrastructure.

Run:

```bash
terraform destroy
```

Terraform calculates which managed resources should be removed.

Review the proposed destruction carefully.

Confirm:

```text
yes
```

Terraform then removes the Terraform-managed EC2 instance.

A successful operation should produce output similar to:

```text
Destroy complete! Resources: 1 destroyed.
```

> Always clean up learning resources when they are no longer required to avoid unnecessary AWS charges.

## 19. Verify Destruction

Run:

```bash
terraform state list
```

The EC2 resource should no longer be listed after successful destruction.

We should also verify in the AWS console:

```text
EC2
→ Instances
```

The Terraform-managed instance should no longer be running.

## 20. Complete Terraform Lifecycle

The complete lifecycle demonstrated by this project is:

```text
┌──────────────────────────┐
│ Write main.tf            │
└────────────┬─────────────┘
             ↓
┌──────────────────────────┐
│ terraform fmt            │
│ Format                   │
└────────────┬─────────────┘
             ↓
┌──────────────────────────┐
│ terraform init           │
│ Initialize               │
└────────────┬─────────────┘
             ↓
┌──────────────────────────┐
│ terraform validate       │
│ Validate                 │
└────────────┬─────────────┘
             ↓
┌──────────────────────────┐
│ terraform plan           │
│ Preview                  │
└────────────┬─────────────┘
             ↓
┌──────────────────────────┐
│ terraform apply          │
│ Provision                │
└────────────┬─────────────┘
             ↓
┌──────────────────────────┐
│ AWS EC2 Instance         │
└────────────┬─────────────┘
             ↓
┌──────────────────────────┐
│ Terraform State          │
│ terraform.tfstate        │
└────────────┬─────────────┘
             ↓
┌──────────────────────────┐
│ terraform destroy        │
│ Cleanup                  │
└──────────────────────────┘
```

## 21. Troubleshooting

### Error: Invalid AMI

**Cause:**

The AMI does not exist or is not available in the configured region.

**Solution:**

Verify that the selected AMI belongs to the same region configured in:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

### Error: No Credentials Found

Verify AWS authentication:

```bash
aws sts get-caller-identity
```

If authentication fails, configure the AWS CLI or use another approved AWS credential mechanism.

### Error: AccessDenied

**Cause:**

The AWS identity does not have sufficient permissions.

First identify the current AWS identity:

```bash
aws sts get-caller-identity
```

Then review the IAM permissions associated with that identity.

### Error: Instance Type Not Available

**Cause:**

The selected instance type may not be available in the selected region, account, or environment.

**Solution:**

Verify current EC2 instance-type availability and account restrictions for the selected region.

### Error: Insufficient Capacity

**Cause:**

AWS may temporarily have insufficient capacity for the requested instance type/AZ combination.

**Solution:**

Review the AWS error message and consider another compatible instance type or configuration.

## 22. Security Rules

Never commit sensitive credentials to Git.

Do not commit:

```text
AWS Access Keys
AWS Secret Access Keys
Private SSH Keys
Passwords
Tokens
Secrets
```

Do not hard-code credentials into:

```text
main.tf
provider.tf
variables.tf
```

Avoid committing Terraform state files without understanding their contents and security implications.

A typical `.gitignore` for Terraform projects includes:

```gitignore
.terraform/

*.tfstate
*.tfstate.*

*.tfvars
*.tfvars.json

crash.log
crash.*.log
```

For production environments, state should normally be stored using an appropriate remote backend with suitable access control, encryption, locking/concurrency controls, and backup/recovery practices.

## 23. Project Completion Criteria

The project is complete when we have successfully:

* Installed Terraform.
* Installed AWS CLI.
* Authenticated with AWS.
* Selected an appropriate AWS region.
* Selected a valid AMI.
* Configured the AWS provider.
* Declared the AWS provider dependency.
* Created an `aws_instance` resource.
* Formatted the configuration.
* Initialized Terraform.
* Validated the configuration.
* Reviewed the Terraform plan.
* Created the EC2 instance.
* Verified the instance in AWS.
* Inspected Terraform state.
* Performed a configuration change.
* Reviewed the resulting plan.
* Destroyed the EC2 instance.
* Verified that the infrastructure was removed.

## 24. Key Learning

This project demonstrates the fundamental Terraform workflow:

```text
Configuration
      ↓
Initialization
      ↓
Validation
      ↓
Planning
      ↓
Application
      ↓
State Tracking
      ↓
Infrastructure
      ↓
Change Management
      ↓
Destruction
```

The most important conceptual flow is:

```text
HCL
 ↓
Terraform
 ↓
Provider
 ↓
AWS API
 ↓
Infrastructure
```

### Key Concepts

| Concept              | Meaning                                                       |
| -------------------- | ------------------------------------------------------------- |
| Terraform            | Infrastructure as Code tool                                   |
| HCL                  | Terraform configuration language                              |
| Provider             | Plugin that allows Terraform to interact with a platform      |
| AWS Provider         | Provider used to manage AWS infrastructure                    |
| Resource             | Infrastructure object managed by Terraform                    |
| `aws_instance`       | AWS EC2 resource type                                         |
| `terraform init`     | Initializes the Terraform working directory                   |
| `terraform fmt`      | Formats Terraform configuration                               |
| `terraform validate` | Validates configuration                                       |
| `terraform plan`     | Previews infrastructure changes                               |
| `terraform apply`    | Applies infrastructure changes                                |
| Terraform State      | Records information Terraform uses to track managed resources |
| `terraform destroy`  | Removes managed infrastructure                                |

## 25. Command Reference

| Command                | Purpose                                      |
| ---------------------- | -------------------------------------------- |
| `terraform version`    | Display Terraform version                    |
| `terraform fmt`        | Format Terraform configuration               |
| `terraform init`       | Initialize the project and install providers |
| `terraform validate`   | Validate the configuration                   |
| `terraform plan`       | Preview infrastructure changes               |
| `terraform apply`      | Create or modify infrastructure              |
| `terraform show`       | Display Terraform state                      |
| `terraform state list` | List resources tracked by Terraform          |
| `terraform destroy`    | Destroy managed infrastructure               |

## Final Project Flow

```text
                    AWS EC2 PROVISIONING

                         Developer
                             │
                             ▼
                       Write main.tf
                             │
                             ▼
                       terraform fmt
                             │
                             ▼
                       terraform init
                             │
                             ▼
                     terraform validate
                             │
                             ▼
                       terraform plan
                             │
                       Review Changes
                             │
                             ▼
                      terraform apply
                             │
                             ▼
                       AWS Provider
                             │
                             ▼
                          AWS API
                             │
                             ▼
                       EC2 Instance
                             │
                             ▼
                     Terraform State
                    terraform.tfstate
                             │
                             │
                      Managed Resource
                             │
                             ▼
                     terraform destroy
                             │
                             ▼
                      EC2 Terminated
```

> **Next Step:** With the basic EC2 provisioning workflow understood, we can move to more advanced Terraform concepts such as variables, outputs, data sources, resource dependencies, state management, and reusable project structure.
