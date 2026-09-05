
## Terraform State and S3 Remote Backend — Practical Project

> **File:** `README.md`

## Table of Contents

* [Overview](#overview)
* [Learning Objectives](#learning-objectives)
* [Architecture](#architecture)
* [Project Structure](#project-structure)
* [Tools and Technologies](#tools-and-technologies)
* [Prerequisites](#prerequisites)
* [Terraform and Provider Versions](#terraform-and-provider-versions)
* [Project Configuration](#project-configuration)
  * [`versions.tf`](#versionstf)
  * [`providers.tf`](#providerstf)
  * [`variables.tf`](#variablestf)
  * [`terraform.tfvars.example`](#terraformtfvarsexample)
  * [`main.tf`](#maintf)
  * [`outputs.tf`](#outputstf)
  * [`backend.tf`](#backendtf)
* [Execution Flow](#execution-flow)
* [Phase 1 — Initial Local State](#phase-1--initial-local-state)
  * [1. Prepare the Project](#1-prepare-the-project)
  * [2. Configure Variables](#2-configure-variables)
  * [3. Initialize Terraform](#3-initialize-terraform)
  * [4. Format and Validate](#4-format-and-validate)
  * [5. Review the Plan](#5-review-the-plan)
  * [6. Create the EC2 Instance](#6-create-the-ec2-instance)
* [Phase 2 — Inspect Local State](#phase-2--inspect-local-state)
  * [7. List Managed Resources](#7-list-managed-resources)
  * [8. Inspect State](#8-inspect-state)
  * [9. Inspect the Local Filesystem](#9-inspect-the-local-filesystem)
* [Phase 3 — Create the S3 State Backend](#phase-3--create-the-s3-state-backend)
  * [10. Create the S3 Bucket](#10-create-the-s3-bucket)
  * [11. Configure S3 Security](#11-configure-s3-security)
* [Phase 4 — Configure Remote State](#phase-4--configure-remote-state)
  * [12. Configure `backend.tf`](#12-configure-backendtf)
  * [13. Initialize the S3 Backend](#13-initialize-the-s3-backend)
  * [14. Migrate Local State](#14-migrate-local-state)
* [Phase 5 — Validate Remote State](#phase-5--validate-remote-state)
  * [15. Verify Terraform State](#15-verify-terraform-state)
  * [16. Verify the S3 State Object](#16-verify-the-s3-state-object)
  * [17. Verify Native S3 Locking](#17-verify-native-s3-locking)
  * [18. Verify Provider Lock File](#18-verify-provider-lock-file)
* [Team Workflow](#team-workflow)
* [Security Best Practices](#security-best-practices)
* [Common Troubleshooting](#common-troubleshooting)
* [Validation Checklist](#validation-checklist)
* [Cleanup](#cleanup)
  * [Destroy Terraform Resources](#destroy-terraform-resources)
  * [Remove the Lab State](#remove-the-lab-state)
  * [Remove the S3 Bucket](#remove-the-s3-bucket)
* [Repository Expectations](#repository-expectations)
* [Learning Outcomes](#learning-outcomes)
* [Final Project Flow](#final-project-flow)

## Overview

This project demonstrates how Terraform State evolves from a simple local development setup into a centralized remote State architecture using Amazon S3.

We begin with a local Terraform State:

```text
Developer Machine
└── terraform.tfstate
```

We then create an S3 bucket and migrate the State:

```text
Developer / CI/CD
        |
        v
    Amazon S3
        |
        └── terraform.tfstate
```

The project also demonstrates native S3 State locking using:

```hcl
use_lockfile = true
```

The final architecture uses:

* Terraform State
* Local backend
* Remote S3 backend
* S3 State locking
* S3 encryption
* S3 versioning
* IAM access control
* EC2 demonstration infrastructure
* State inspection
* State migration
* Team-oriented State management

Native S3 locking is the preferred approach for new S3 backend configurations. DynamoDB-based locking is treated as legacy knowledge for existing environments.

## Learning Objectives

By completing this project, we will understand:

* How Terraform creates and maintains State
* Where local State is stored
* How Terraform tracks managed resources
* How to inspect Terraform State
* Why State should not be committed to Git
* What a Terraform backend does
* Why remote State is useful for teams
* How Amazon S3 can store Terraform State
* What the S3 `key` represents
* How to migrate State from local storage to S3
* How native S3 State locking works
* Why State locking is important
* How encryption protects State at rest
* Why S3 Versioning is useful for State recovery
* How Terraform State differs from Terraform source code
* How to validate remote State
* How to troubleshoot common backend problems
* How to safely clean up the lab

## Architecture

### Initial Local-State Architecture

The first stage uses Terraform's default local backend.

```text
                Terraform Configuration
                         |
                         v
                  Terraform CLI
                         |
                         v
                   Local Backend
                         |
                         v
                  terraform.tfstate
                         |
                         v
                  Developer Machine
                         |
                         v
                      AWS EC2
```

Terraform State maintains the relationship between the Terraform resource and the real AWS resource.

```text
aws_instance.demo
        |
        v
Terraform State
        |
        v
EC2 Instance
        |
        v
i-xxxxxxxxxxxxxxxxx
```

### Final Remote-State Architecture

After migration:

```text
                          GitHub
                            |
                            | Terraform Source Code
                            v
                 +---------------------+
                 | Terraform Project   |
                 +----------+----------+
                            |
                            | terraform plan/apply
                            v
                  +-------------------+
                  | Terraform CLI /   |
                  | CI/CD             |
                  +---------+---------+
                            |
                            v
                    +---------------+
                    |   S3 Backend  |
                    +-------+-------+
                            |
                  +---------+---------+
                  |                   |
                  v                   v
          terraform.tfstate  terraform.tfstate.tflock
                  |
                  v
          AWS Infrastructure
```

The important separation is:

```text
GitHub
└── Terraform Source Code

Amazon S3
└── Terraform State
```

Terraform source code and Terraform State therefore have different responsibilities.

## Project Structure

```text
project-terraform-state/
|
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── terraform.tfvars.example
├── outputs.tf
└── backend.tf
```

### File Responsibilities

| File                       | Responsibility                                   |
| -------------------------- | ------------------------------------------------ |
| `README.md`                | Project documentation and execution instructions |
| `versions.tf`              | Terraform and provider requirements              |
| `providers.tf`             | AWS provider configuration                       |
| `main.tf`                  | EC2 demonstration resource                       |
| `variables.tf`             | Input variable definitions                       |
| `terraform.tfvars.example` | Shareable variable template                      |
| `outputs.tf`               | Useful Terraform outputs                         |
| `backend.tf`               | S3 remote State configuration                    |

Terraform may additionally generate:

```text
.terraform/
.terraform.lock.hcl
```

We should:

```text
Commit:
├── Terraform source code
├── README.md
├── terraform.tfvars.example
└── .terraform.lock.hcl

Do not commit:
├── .terraform/
├── terraform.tfstate
├── terraform.tfstate.*
├── terraform.tfvars
└── Saved plan files
```

## Tools and Technologies

| Tool / Technology   | Purpose                           |
| ------------------- | --------------------------------- |
| Terraform           | Infrastructure as Code            |
| HCL                 | Terraform configuration language  |
| AWS Provider        | Terraform integration with AWS    |
| Amazon EC2          | Demonstration infrastructure      |
| Amazon S3           | Remote Terraform State            |
| S3 Native Lock File | State locking                     |
| AWS CLI             | AWS administration and validation |
| Git                 | Version control                   |
| GitHub              | Source-code collaboration         |

## Prerequisites

Before starting, we should have:

### AWS Account

An AWS account with permissions required for:

* EC2
* S3
* Required IAM operations

### Terraform

Verify:

```bash
terraform version
```

The project expects:

```text
Terraform >= 1.15.0
```

### AWS CLI

Verify:

```bash
aws --version
```

### AWS Authentication

Verify:

```bash
aws sts get-caller-identity
```

A successful response confirms that the AWS CLI is authenticated.

## Terraform and Provider Versions

The project uses:

```hcl
terraform {
  required_version = ">= 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
```

Therefore:

```text
Terraform >= 1.15.0
AWS Provider 6.x
```

## Project Configuration

### `versions.tf`

```hcl
terraform {
  required_version = ">= 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
```

This declares the Terraform CLI and AWS provider requirements.

### `providers.tf`

```hcl
provider "aws" {
  region = var.aws_region
}
```

The AWS provider uses the configured AWS region.

### `variables.tf`

```hcl
variable "aws_region" {
  description = "AWS region where the lab resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name used to identify the Terraform State lab resources."
  type        = string
  default     = "terraform-state-demo"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "ami_id" {
  description = "AMI ID used for the EC2 demonstration instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}
```

### `terraform.tfvars.example`

```hcl
# Copy this file to `terraform.tfvars` and update the values
# according to the AWS environment.

aws_region    = "us-east-1"
project_name  = "terraform-state-demo"
environment   = "dev"
ami_id        = "ami-xxxxxxxxxxxxxxxxx"
instance_type = "t3.micro"
```

Create the local variable file.

#### Linux / macOS / Codespaces

```bash
cp terraform.tfvars.example terraform.tfvars
```

#### Windows PowerShell

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

Then replace the placeholder AMI ID with a valid AMI for the selected AWS region.

### `main.tf`

```hcl
resource "aws_instance" "demo" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name        = var.project_name
    Environment = var.environment
  }
}
```

This EC2 instance provides a simple resource that allows us to observe how Terraform State tracks infrastructure.

### `outputs.tf`

```hcl
output "instance_id" {
  description = "ID of the EC2 instance created by Terraform."
  value       = aws_instance.demo.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance."
  value       = aws_instance.demo.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance."
  value       = aws_instance.demo.private_ip
}

output "instance_name" {
  description = "Name of the EC2 instance."
  value       = aws_instance.demo.tags["Name"]
}
```

Outputs expose selected values to the user.

They do not replace the need to secure Terraform State.

### `backend.tf`

The final S3 backend configuration is:

```hcl
terraform {
  backend "s3" {
    # Existing S3 bucket used to store Terraform State.
    bucket = "REPLACE-WITH-YOUR-UNIQUE-STATE-BUCKET"

    # S3 object path where Terraform State is stored.
    key = "terraform-state-demo/terraform.tfstate"

    # AWS region containing the S3 bucket.
    region = "us-east-1"

    # Enable native S3 State locking.
    use_lockfile = true

    # Enable server-side encryption.
    encrypt = true
  }
}
```

Replace:

```text
REPLACE-WITH-YOUR-UNIQUE-STATE-BUCKET
```

with the actual S3 bucket name.

The S3 bucket must already exist before Terraform can normally initialize this backend.

## Execution Flow

The project follows this sequence:

```text
1. Configure Terraform
        |
        v
2. Create EC2 using Local State
        |
        v
3. Inspect terraform.tfstate
        |
        v
4. Create S3 State Bucket
        |
        v
5. Configure S3 Backend
        |
        v
6. terraform init
        |
        v
7. Migrate Local State to S3
        |
        v
8. Enable Native S3 Locking
        |
        v
9. Validate Remote State
        |
        v
10. Verify S3 State Object
        |
        v
11. Cleanup
```

## Phase 1 — Initial Local State

For the first part of the exercise, we intentionally work with the local backend.

Because the final repository contains `backend.tf`, temporarily move or rename `backend.tf` before the initial local-State exercise.

For example:

```text
backend.tf
```

can temporarily become:

```text
backend.tf.disabled
```

This allows Terraform to use the default local backend.

> This temporary step exists only to demonstrate the State lifecycle. After the local-State exercise, restore `backend.tf`.

### 1. Prepare the Project

Navigate into the project:

```bash
cd 04-state-and-backends/project-terraform-state
```

Confirm the files:

```text
README.md
versions.tf
providers.tf
main.tf
variables.tf
terraform.tfvars
outputs.tf
```

### 2. Configure Variables

Create the local variable file if it does not already exist:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Update:

```hcl
ami_id = "ami-xxxxxxxxxxxxxxxxx"
```

with a valid AMI for the selected AWS region.

### 3. Initialize Terraform

Run:

```bash
terraform init
```

Terraform initializes the working directory and downloads the required provider.

### 4. Format and Validate

Format the configuration:

```bash
terraform fmt
```

Validate the configuration:

```bash
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

### 5. Review the Plan

Run:

```bash
terraform plan
```

Review the proposed infrastructure changes.

We should see an EC2 instance planned for creation:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

### 6. Create the EC2 Instance

Run:

```bash
terraform apply
```

Review the plan and confirm:

```text
yes
```

Terraform creates the EC2 instance.

At this point:

```text
Terraform Configuration
        |
        v
    Local Backend
        |
        v
terraform.tfstate
        |
        v
    AWS EC2
```

## Phase 2 — Inspect Local State

### 7. List Managed Resources

Run:

```bash
terraform state list
```

Expected:

```text
aws_instance.demo
```

This confirms that Terraform is tracking the EC2 instance.

### 8. Inspect State

Run:

```bash
terraform show
```

Terraform displays the current State in a human-readable form.

We can also inspect the specific resource:

```bash
terraform state show aws_instance.demo
```

The exact output depends on the AWS provider and EC2 resource.

### 9. Inspect the Local Filesystem

#### Linux / macOS / Codespaces

```bash
ls -la
```

#### Windows PowerShell

```powershell
Get-ChildItem -Force
```

We should see:

```text
terraform.tfstate
```

This demonstrates that the State is currently stored locally.

## Phase 3 — Create the S3 State Backend

### 10. Create the S3 Bucket

The S3 backend bucket must exist before the application Terraform configuration can normally use it.

The bucket name must be globally unique.

Example:

```text
terraform-state-demo-2026-xxxxx
```

The actual bucket name must be unique.

We can create the bucket using the AWS CLI.

For `us-east-1`:

```bash
aws s3api create-bucket \
  --bucket YOUR-UNIQUE-BUCKET-NAME \
  --region us-east-1
```

For another AWS region, use the appropriate `LocationConstraint`.

Verify:

```bash
aws s3 ls
```

### 11. Configure S3 Security

For a production-quality State bucket, we should consider:

```text
Private Bucket
      +
Block Public Access
      +
IAM Access Control
      +
Encryption
      +
Versioning
      +
Audit Controls
```

At minimum, ensure that the bucket is not publicly accessible.

#### Enable Versioning

Example:

```bash
aws s3api put-bucket-versioning \
  --bucket YOUR-UNIQUE-BUCKET-NAME \
  --versioning-configuration Status=Enabled
```

Verify:

```bash
aws s3api get-bucket-versioning \
  --bucket YOUR-UNIQUE-BUCKET-NAME
```

Expected:

```text
Status: Enabled
```

Versioning provides an additional recovery mechanism for State history.

## Phase 4 — Configure Remote State

### 12. Configure `backend.tf`

Restore:

```text
backend.tf
```

if it was temporarily renamed.

Update the bucket:

```hcl
terraform {
  backend "s3" {
    bucket       = "YOUR-UNIQUE-BUCKET-NAME"
    key          = "terraform-state-demo/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
```

The important settings are:

| Setting        | Purpose                              |
| -------------- | ------------------------------------ |
| `bucket`       | S3 bucket containing Terraform State |
| `key`          | State object path                    |
| `region`       | S3 bucket region                     |
| `use_lockfile` | Enables native S3 State locking      |
| `encrypt`      | Enables server-side encryption       |

The State object will conceptually be stored as:

```text
S3 Bucket
|
└── terraform-state-demo/
    |
    └── terraform.tfstate
```

### 13. Initialize the S3 Backend

Run:

```bash
terraform init
```

Terraform detects the backend configuration.

Because an existing local State file is present, Terraform may ask whether we want to migrate the existing State.

For a deliberate migration, we can also use:

```bash
terraform init -migrate-state
```

Review Terraform's output carefully.

### 14. Migrate Local State

The intended migration is:

```text
Local State
     |
     | terraform init -migrate-state
     v
S3 Remote State
```

The existing EC2 instance should remain managed by Terraform.

We should **not** recreate the infrastructure simply because the backend changed.

After successful migration:

```text
Before:

Developer Machine
└── terraform.tfstate


After:

S3 Bucket
└── terraform-state-demo/
    └── terraform.tfstate
```

Do not delete the original State before confirming that migration completed successfully.

## Phase 5 — Validate Remote State

### 15. Verify Terraform State

Run:

```bash
terraform state list
```

Expected:

```text
aws_instance.demo
```

Then:

```bash
terraform show
```

The existing EC2 resource should still be represented in State.

Run:

```bash
terraform plan
```

Ideally, Terraform should report that no infrastructure changes are required:

```text
No changes.
```

This confirms that the State migration preserved the resource mapping.

### 16. Verify the S3 State Object

Use:

```bash
aws s3 ls s3://YOUR-UNIQUE-BUCKET-NAME/terraform-state-demo/
```

Expected:

```text
terraform.tfstate
```

The final State architecture is:

```text
AWS S3
|
└── terraform-state-demo/
    └── terraform.tfstate
```

### 17. Verify Native S3 Locking

The backend contains:

```hcl
use_lockfile = true
```

This enables native S3 State locking.

During an active State-changing operation, the backend may contain:

```text
terraform-state-demo/
|
├── terraform.tfstate
└── terraform.tfstate.tflock
```

The `.tflock` object is the native S3 lock object.

We should not manually delete the lock object while a legitimate Terraform operation is running.

### 18. Verify Provider Lock File

After:

```bash
terraform init
```

Terraform normally generates:

```text
.terraform.lock.hcl
```

Verify:

```bash
ls -la
```

or on PowerShell:

```powershell
Get-ChildItem -Force
```

The repository should contain:

```text
.terraform.lock.hcl
```

and should not contain:

```text
.terraform/
terraform.tfstate
```

The provider lock file should generally be committed to Git.

## Team Workflow

Once State is stored centrally, multiple engineers can work against the same State:

```text
                 GitHub Repository
                        |
                  Terraform Code
                        |
        +---------------+---------------+
        |               |               |
        v               v               v
    Engineer A      Engineer B      Engineer C
        |               |               |
        +---------------+---------------+
                        |
                        v
                 terraform plan
                        |
                        v
                 terraform apply
                        |
                        v
                   S3 Backend
                        |
              +---------+---------+
              |                   |
              v                   v
      terraform.tfstate        .tflock
```

State locking ensures that multiple Terraform operations do not modify the same State simultaneously.

## Security Best Practices

Terraform State should be treated as sensitive infrastructure data.

We should:

* Keep the S3 bucket private
* Enable S3 Block Public Access
* Use IAM-based access control
* Enable encryption
* Enable S3 Versioning
* Use least-privilege permissions
* Protect AWS credentials
* Avoid hard-coded access keys
* Keep State out of Git
* Protect CI/CD access to the backend
* Monitor State access where appropriate

For CI/CD, short-lived federated credentials such as OIDC are preferable to long-lived static credentials.

## Common Troubleshooting

### Backend Bucket Does Not Exist

Error:

```text
Error configuring S3 Backend
```

Verify:

```bash
aws s3 ls
```

Check:

```text
Bucket name
AWS account
AWS region
IAM permissions
```

### Access Denied

Error:

```text
AccessDenied
```

Verify:

```bash
aws sts get-caller-identity
```

Then verify that the execution identity has the required:

```text
S3 State permissions
+
Terraform resource permissions
```

### Incorrect Region

Check the backend:

```hcl
region = "us-east-1"
```

Verify the S3 bucket region:

```bash
aws s3api get-bucket-location \
  --bucket YOUR-UNIQUE-BUCKET-NAME
```

The backend region must correspond to the S3 bucket's actual region.

### Backend Configuration Changed

After modifying:

```hcl
backend "s3" {
  ...
}
```

run:

```bash
terraform init
```

Terraform may detect that the backend configuration has changed.

Review any migration prompt carefully.

### State Lock Error

If Terraform reports that the State is locked:

```text
1. Check whether another Terraform operation is running.
2. Check other terminals.
3. Check CI/CD pipelines.
4. Wait for legitimate operations to finish.
5. Determine whether the lock is stale.
6. Consider force-unlock only when the lock is confirmed stale.
```

Do not routinely use:

```bash
-lock=false
```

and do not manually delete a legitimate lock.

If a lock is confirmed stale, Terraform provides:

```bash
terraform force-unlock LOCK_ID
```

Use this command carefully.

## Validation Checklist

After completing the project:

```text
[ ] Terraform version is compatible
[ ] AWS CLI is installed
[ ] AWS authentication works
[ ] aws sts get-caller-identity succeeds

[ ] Terraform configuration is formatted
[ ] terraform validate succeeds
[ ] EC2 instance is created

[ ] terraform state list shows aws_instance.demo
[ ] terraform show displays State

[ ] S3 backend is configured
[ ] S3 State object exists
[ ] Native S3 locking is enabled
[ ] S3 Versioning is enabled

[ ] .terraform/ is ignored by Git
[ ] terraform.tfstate is ignored by Git
[ ] terraform.tfstate.* is ignored by Git
[ ] terraform.tfvars is ignored by Git

[ ] terraform.tfvars.example is committed
[ ] .terraform.lock.hcl is committed

[ ] S3 bucket is private
[ ] Appropriate IAM permissions are configured
[ ] S3 encryption is enabled
```

## Cleanup

Cleanup should be performed carefully because Terraform State and the S3 backend are infrastructure dependencies.

### Destroy Terraform Resources

First review:

```bash
terraform plan
```

Then destroy the EC2 instance:

```bash
terraform destroy
```

Confirm:

```text
yes
```

Verify:

```bash
terraform state list
```

The EC2 resource should no longer be present.

### Remove the Lab State

Only after the Terraform-managed infrastructure has been destroyed and the State is no longer required should we remove the lab State.

For example:

```bash
aws s3 rm \
  s3://YOUR-UNIQUE-BUCKET-NAME/terraform-state-demo/terraform.tfstate
```

If S3 Versioning is enabled, deleting the current object does not necessarily permanently remove previous versions.

### Remove the S3 Bucket

Only do this when the bucket is dedicated exclusively to this lab.

Remove its contents:

```bash
aws s3 rm \
  s3://YOUR-UNIQUE-BUCKET-NAME \
  --recursive
```

Then remove the bucket:

```bash
aws s3 rb \
  s3://YOUR-UNIQUE-BUCKET-NAME
```

> **Warning:** Never delete a shared or production Terraform State bucket as part of routine lab cleanup.

## Repository Expectations

The committed repository should look like:

```text
project-terraform-state/
|
├── README.md
├── versions.tf
├── providers.tf
├── main.tf
├── variables.tf
├── terraform.tfvars.example
├── outputs.tf
├── backend.tf
└── .terraform.lock.hcl
```

We should not commit:

```text
.terraform/
terraform.tfstate
terraform.tfstate.*
terraform.tfvars
*.tfplan
*.plan
```

The important principle is:

```text
Terraform Source Code
        |
        v
      GitHub


Terraform State
        |
        v
     Amazon S3
```

## Learning Outcomes

After completing this project, we should be able to explain:

1. What Terraform State is
2. Why Terraform requires State
3. How State maps Terraform resources to real infrastructure
4. How local State works
5. What a Terraform backend is
6. Why remote State is useful
7. How S3 stores Terraform State
8. What the S3 `key` represents
9. How State migration works
10. How native S3 locking works
11. Why State locking matters
12. Why State should not be stored in Git
13. Why State should be encrypted
14. Why S3 Versioning is useful
15. How State should be secured
16. How to inspect State
17. How to troubleshoot backend problems
18. How Terraform State fits into a team workflow

## Final Project Flow

The complete project can be remembered as:

```text
                Terraform Configuration
                          |
                          v
                    Terraform CLI
                          |
              +-----------+-----------+
              |                       |
              v                       v
        Terraform State       AWS Infrastructure
              |
              v
        Remote Backend
              |
              v
          Amazon S3
              |
        +-----+------+
        |            |
        v            v
terraform.tfstate  .tflock
                   Native S3 Lock
```

The complete learning progression is:

```text
Local State
    |
    v
Inspect State
    |
    v
Understand State Mapping
    |
    v
Create S3 Backend
    |
    v
Configure Backend
    |
    v
Migrate State
    |
    v
Native S3 Locking
    |
    v
Encryption
    |
    v
Versioning
    |
    v
Team Collaboration
    |
    v
Secure Remote State
```

The key operational principle is:

> Terraform source code belongs in version control; Terraform State belongs in a properly secured remote backend.
