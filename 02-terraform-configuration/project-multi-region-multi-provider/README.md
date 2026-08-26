
## Project — `project-multi-region-multi-provider`

Terraform Advanced Configuration — Multi-Region AWS Infrastructure with Variables, Conditional Expressions, Outputs, Functions, and Provider Configuration

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Project Objectives](#2-project-objectives)
3. [Prerequisites](#3-prerequisites)
   - [Required Tools](#required-tools)
4. [Project Files](#4-project-files)
   - [`versions.tf`](#versionstf)
   - [`providers.tf`](#providerstf)
   - [`variables.tf`](#variablestf)
   - [`main.tf`](#maintf)
   - [`outputs.tf`](#outputstf)
   - [`terraform.tfvars.example`](#terraformtfvarsexample)
   - [`.gitignore`](#gitignore)
5. [Project Execution](#5-project-execution)
   - [Step 1 — Initialize](#step-1--initialize)
   - [Step 2 — Format](#step-2--format)
   - [Step 3 — Validate](#step-3--validate)
   - [Step 4 — Plan](#step-4--plan)
   - [Step 5 — Apply](#step-5--apply)
   - [Step 6 — Inspect Outputs](#step-6--inspect-outputs)
6. [Project Validation](#6-project-validation)
   - [AWS Console Validation](#aws-console-validation)
7. [Testing the Conditional Expression](#7-testing-the-conditional-expression)
8. [Project Cleanup](#8-project-cleanup)
9. [Project Troubleshooting](#9-project-troubleshooting)
   - [Provider Authentication Error](#provider-authentication-error)
   - [Invalid AMI](#invalid-ami)
   - [Provider Alias Error](#provider-alias-error)
   - [Variable Missing](#variable-missing)
   - [State/Provider Error](#stateprovider-error)
   - [Terraform Configuration Error](#terraform-configuration-error)
10. [Professional Git Workflow](#10-professional-git-workflow)
11. [Final Project Flow](#11-final-project-flow)

## 1. Project Overview

> This project brings the major concepts together into one reusable Terraform configuration.

The project demonstrates:

* Provider configuration
* Explicit provider requirements
* AWS provider aliases
* Multi-region infrastructure
* Input variables
* Output values
* `.tfvars` configuration
* Conditional expressions
* Built-in functions
* Terraform formatting
* Terraform validation
* Terraform planning
* Terraform apply
* Terraform debugging
* Professional Terraform file organization
* Resource cleanup

The architecture follows this model:

```text
                         Terraform Configuration
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
              AWS Provider                 Variables
                    │                           │
          ┌─────────┴─────────┐                 │
          │                   │                 │
    aws.us_east_1       aws.us_west_2           │
          │                   │                 │
          ▼                   ▼                 ▼
   EC2 Instance A      EC2 Instance B    terraform.tfvars
          │                   │
          └─────────┬─────────┘
                    │
                 Outputs
                    │
                    ▼
             Instance IDs/IPs
```

> **Note:** The project uses a default AWS provider configuration for the primary region and an aliased AWS provider configuration for the secondary region. The alias allows resources to explicitly select the secondary region.

## 2. Project Objectives

By completing this project, we should be able to:

1. Configure Terraform providers correctly.
2. Declare provider source and version constraints.
3. Configure multiple AWS regions.
4. Assign provider aliases to resources.
5. Parameterize infrastructure using variables.
6. Supply variable values through `.tfvars`.
7. Produce useful Terraform outputs.
8. Apply conditional expressions.
9. Use Terraform built-in functions.
10. Format and validate Terraform code.
11. Diagnose configuration problems.
12. Destroy all resources after practice.

## 3. Prerequisites

### Required tools

| Tool                        | Recommended baseline               |
| --------------------------- | ---------------------------------- |
| Terraform CLI               | 1.15.9                             |
| AWS CLI                     | Current stable release             |
| Git                         | Current stable release             |
| VS Code                     | Current stable release             |
| Terraform VS Code extension | Current                            |
| AWS account                 | Required for AWS resource creation |
| AWS credentials             | Configured securely                |

> **Version note:** Terraform 1.15.9 is used as the current stable 1.15 patch baseline for this project. Version availability changes over time, so production projects should verify the currently supported Terraform release before implementation.

AWS credentials should **not** be hard-coded in Terraform configuration.

The AWS provider supports several credential mechanisms, including environment variables, shared AWS configuration/credentials files, IAM roles, web identity/OIDC, and other AWS-supported authentication mechanisms.

For example:

```bash
aws sts get-caller-identity
```

This allows us to verify that the AWS CLI can authenticate successfully before we troubleshoot Terraform authentication.

## 4. Project Files

A recommended project structure is:

```text
project-multi-region-multi-provider/
│
├── versions.tf
├── providers.tf
├── variables.tf
├── main.tf
├── outputs.tf
├── terraform.tfvars.example
└── .gitignore
```

The purpose of the files is:

| File                       | Purpose                                                 |
| -------------------------- | ------------------------------------------------------- |
| `versions.tf`              | Terraform and provider requirements                     |
| `providers.tf`             | AWS provider configurations                             |
| `variables.tf`             | Input variable declarations                             |
| `main.tf`                  | AWS infrastructure resources                            |
| `outputs.tf`               | Values returned after deployment                        |
| `terraform.tfvars.example` | Example variable values                                 |
| `.gitignore`               | Prevents generated/sensitive files from being committed |

### `versions.tf`

```hcl
terraform {
  # Terraform version constraint for this project.
  required_version = "~> 1.15.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"

      # Allow compatible AWS provider 6.x releases.
      version = "~> 6.0"
    }
  }
}
```

The `required_providers` block is the modern location for provider source addresses and version constraints.

The AWS provider source is:

```text
hashicorp/aws
```

The `~> 6.0` constraint allows compatible AWS provider 6.x releases while preventing an automatic move to a future incompatible major version.

> **Historical note:** Older Terraform material sometimes placed provider version constraints inside the `provider` block. That approach is deprecated. Modern Terraform configurations should declare provider source and version constraints inside `terraform.required_providers`.

### `providers.tf`

```hcl
# Default AWS provider configuration.
# This provider targets the primary region.

provider "aws" {
  region = var.primary_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Additional AWS provider configuration.
# The alias allows resources to explicitly use this region.

provider "aws" {
  alias  = "secondary"
  region = var.secondary_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
```

> Provider aliases are the standard Terraform mechanism for multiple configurations of the same provider, such as different AWS regions.

The first provider configuration is the **default provider configuration**.

The second provider configuration has:

```hcl
alias = "secondary"
```

Therefore, resources can explicitly select it using:

```hcl
provider = aws.secondary
```

The architecture is:

```text
Terraform
   │
   ├── AWS default provider
   │      │
   │      └── primary_region
   │
   └── AWS secondary provider
          │
          └── secondary_region
```

### `variables.tf`

```hcl
variable "project_name" {
  type        = string
  description = "Name of the Terraform project."
  default     = "terraform-advanced-configuration"
}

variable "environment" {
  type        = string
  description = "Deployment environment."
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "primary_region" {
  type        = string
  description = "Primary AWS region."
  default     = "us-east-1"
}

variable "secondary_region" {
  type        = string
  description = "Secondary AWS region."
  default     = "us-west-2"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type."
  default     = "t3.micro"
}

variable "primary_ami_id" {
  type        = string
  description = "AMI ID for the primary AWS region."
}

variable "secondary_ami_id" {
  type        = string
  description = "AMI ID for the secondary AWS region."
}

variable "create_secondary_instance" {
  type        = bool
  description = "Whether to create the secondary-region EC2 instance."
  default     = true
}
```

Terraform supports variable type constraints, defaults, validation, sensitivity, nullability, and other variable controls.

The `environment` variable demonstrates input validation:

```hcl
validation {
  condition = contains(
    ["dev", "staging", "prod"],
    var.environment
  )

  error_message = "Environment must be dev, staging, or prod."
}
```

Therefore, values such as:

```text
dev
staging
prod
```

are accepted, while an unexpected value such as:

```text
testing
```

will fail validation.

### `main.tf`

```hcl
# Primary-region EC2 instance.

resource "aws_instance" "primary" {
  ami           = var.primary_ami_id
  instance_type = var.instance_type

  tags = {
    Name = "${var.project_name}-primary"
  }
}

# Secondary-region EC2 instance.
#
# The conditional expression controls whether this resource exists.

resource "aws_instance" "secondary" {
  count = var.create_secondary_instance ? 1 : 0

  provider = aws.secondary

  ami           = var.secondary_ami_id
  instance_type = var.instance_type

  tags = {
    Name = "${var.project_name}-secondary"
  }
}
```

The primary instance does not specify a provider:

```hcl
resource "aws_instance" "primary" {
```

Therefore, Terraform uses the default AWS provider configuration.

The secondary instance explicitly specifies:

```hcl
provider = aws.secondary
```

Therefore, Terraform uses the aliased provider configuration.

The conditional expression:

```hcl
count = var.create_secondary_instance ? 1 : 0
```

means:

```text
create_secondary_instance
          │
          ├── true  → count = 1 → create instance
          │
          └── false → count = 0 → do not create instance
```

This demonstrates how conditional expressions can control resource creation.

### `outputs.tf`

```hcl
output "primary_instance_id" {
  type        = string
  description = "ID of the primary EC2 instance."

  value = aws_instance.primary.id
}

output "primary_public_ip" {
  type        = string
  description = "Public IP of the primary EC2 instance."

  value = aws_instance.primary.public_ip
}

output "secondary_instance_id" {
  type        = string
  description = "ID of the secondary EC2 instance."

  value = try(aws_instance.secondary[0].id, null)
}

output "secondary_public_ip" {
  type        = string
  description = "Public IP of the secondary EC2 instance."

  value = try(aws_instance.secondary[0].public_ip, null)
}

output "project_summary" {
  type        = string
  description = "Human-readable project summary."

  value = format(
    "%s infrastructure deployed in %s and %s",
    var.project_name,
    var.primary_region,
    var.secondary_region
  )
}
```

The following output demonstrates the `try()` built-in function:

```hcl
value = try(aws_instance.secondary[0].id, null)
```

If the secondary instance exists, Terraform returns its ID.

If the secondary instance was not created because:

```hcl
create_secondary_instance = false
```

the expression can fall back to:

```text
null
```

The project also demonstrates the `format()` function:

```hcl
format(
  "%s infrastructure deployed in %s and %s",
  var.project_name,
  var.primary_region,
  var.secondary_region
)
```

Root-module outputs are displayed after `terraform apply` and can also be consumed by other Terraform configurations and automation.

### `terraform.tfvars.example`

```hcl
project_name = "terraform-advanced-configuration"

environment = "dev"

primary_region   = "us-east-1"
secondary_region = "us-west-2"

instance_type = "t3.micro"

# Replace these with valid AMIs for the selected regions.

primary_ami_id   = "ami-xxxxxxxxxxxxxxxxx"
secondary_ami_id = "ami-yyyyyyyyyyyyyyyyy"

create_secondary_instance = true
```

Create a local:

```text
terraform.tfvars
```

from this example and provide real values.

For example:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

Then replace:

```text
ami-xxxxxxxxxxxxxxxxx
ami-yyyyyyyyyyyyyyyyy
```

with valid AMI IDs.

> **Important:** AMI IDs are region-specific. An AMI that exists in `us-east-1` may not exist in `us-west-2`.

Do not commit real secrets or sensitive variable values.

### `.gitignore`

```gitignore
# Terraform working directory

.terraform/

# Terraform state

*.tfstate
*.tfstate.*

# Crash logs

crash.log
crash.*.log

# Variable files that may contain secrets

*.tfvars
*.tfvars.json

# Exception: example files are safe to commit

!terraform.tfvars.example

# Terraform plan files

*.tfplan

# Override files

override.tf
override.tf.json
*_override.tf
*_override.tf.json

# CLI configuration

.terraformrc
terraform.rc
```

Terraform state can contain sensitive information even when variables are marked:

```hcl
sensitive = true
```

Therefore, state must be treated as sensitive and excluded from normal Git workflows.

> **Important:** `.terraform.lock.hcl` is intentionally **not** included in `.gitignore`.

After `terraform init`, Terraform normally creates:

```text
.terraform.lock.hcl
```

> This file should normally be committed to version control.

## 5. Project Execution

### Step 1 — Initialize

Run:

```bash
terraform init
```

Terraform downloads the required provider and creates or updates:

```text
.terraform.lock.hcl
```

The lock file records the selected provider version and checksums.

The normal workflow is:

```text
terraform init
       │
       ├── Download provider
       │
       ├── Resolve provider version
       │
       └── Create/update .terraform.lock.hcl
```

The lock file should normally be committed because it allows teams and automated environments to use consistent provider versions.

### Step 2 — Format

Run:

```bash
terraform fmt -recursive
```

This formats Terraform configuration files according to Terraform's standard formatting rules.

> We should run formatting before committing Terraform code.

### Step 3 — Validate

Run:

```bash
terraform validate
```

This checks whether the Terraform configuration is syntactically valid and internally consistent.

A successful result should look conceptually like:

```text
Success! The configuration is valid.
```

### Step 4 — Plan

Run:

```bash
terraform plan
```

Terraform evaluates the configuration and shows the proposed infrastructure changes.

> Before applying the configuration, we should review the plan carefully.

The expected architecture is:

```text
Primary AWS Region
└── EC2 Instance

Secondary AWS Region
└── EC2 Instance
```

### Step 5 — Apply

Run:

```bash
terraform apply
```

Terraform displays the proposed changes.

Review the plan and confirm the operation.

When prompted:

```text
Do you want to perform these actions?
```

enter:

```text
yes
```

Terraform then creates the requested AWS resources.

### Step 6 — Inspect Outputs

Run:

```bash
terraform output
```

This displays the root-module outputs.

To retrieve one specific output:

```bash
terraform output primary_public_ip
```

For automation:

```bash
terraform output -json
```

The `terraform output` command retrieves output values from Terraform state.

## 6. Project Validation

Verify the following:

```text
terraform init
        ↓
Successful provider installation

terraform fmt
        ↓
Consistent formatting

terraform validate
        ↓
Configuration valid

terraform plan
        ↓
Expected resources

terraform apply
        ↓
Resources created

terraform output
        ↓
Expected IDs/IPs
```

### AWS Console Validation

Open the AWS Console and verify the two regions.

```text
AWS Console
   │
   ├── us-east-1
   │      └── Primary EC2
   │
   └── us-west-2
          └── Secondary EC2
```

The primary instance should exist in:

```text
us-east-1
```

and the secondary instance should exist in:

```text
us-west-2
```

when:

```hcl
create_secondary_instance = true
```

## 7. Testing the Conditional Expression

The project contains:

```hcl
create_secondary_instance = true
```

Therefore, both instances should be created.

We can test the conditional behavior by changing:

```hcl
create_secondary_instance = false
```

Then run:

```bash
terraform plan
```

Terraform should propose removing the secondary instance while keeping the primary instance.

The behavior is:

```text
create_secondary_instance = true
                │
                ▼
             count = 1
                │
                ▼
       Secondary EC2 created


create_secondary_instance = false
                │
                ▼
             count = 0
                │
                ▼
       Secondary EC2 not created
```

This demonstrates the connection between:

```text
Variables
   ↓
Conditional Expression
   ↓
count
   ↓
Resource Creation
```

## 8. Project Cleanup

> Never leave paid cloud resources running after a learning lab.

Run:

```bash
terraform destroy
```

Terraform displays the resources that will be removed.

Confirm the operation.

When prompted:

```text
Do you want to destroy all resources?
```

enter:

```text
yes
```

After destruction completes, run:

```bash
terraform plan
```

The expected result should indicate that there are no resources left to create or change.

Conceptually:

```text
terraform destroy
       │
       ▼
AWS resources removed
       │
       ▼
terraform plan
       │
       ▼
No infrastructure changes required
```

### Important

Do not delete:

```text
.terraform.lock.hcl
```

as part of normal cleanup.

> The lock file is a repository file and should normally remain committed.

If we intentionally want to reset provider dependency selections, that is a separate operation.

## 9. Project Troubleshooting

### Provider Authentication Error

Run:

```bash
aws sts get-caller-identity
```

If this fails, fix AWS authentication before troubleshooting Terraform.

We should first verify:

```text
AWS CLI authentication
        ↓
AWS account access
        ↓
Terraform provider authentication
```

### Invalid AMI

AMI IDs are region-specific.

For example:

```text
ami-123...
```

may be valid in:

```text
us-east-1
```

but unavailable in:

```text
us-west-2
```

Therefore, verify that:

```text
primary_ami_id
```

belongs to:

```text
primary_region
```

and:

```text
secondary_ami_id
```

belongs to:

```text
secondary_region
```

### Provider Alias Error

Ensure the resource contains:

```hcl
provider = aws.secondary
```

and the provider configuration contains:

```hcl
provider "aws" {
  alias = "secondary"
}
```

The names must match.

For example:

```text
provider alias
      │
      ▼
secondary
      │
      ▼
provider = aws.secondary
```

### Variable Missing

If Terraform reports that a required variable is missing, ensure that we have created:

```text
terraform.tfvars
```

from:

```text
terraform.tfvars.example
```

Alternatively, explicitly specify the file:

```bash
terraform plan -var-file="terraform.tfvars"
```

A file named:

```text
terraform.tfvars
```

is automatically loaded by Terraform.

A file named:

```text
dev.tfvars
```

is **not** automatically loaded merely because it ends in `.tfvars`.

It must be explicitly selected:

```bash
terraform plan -var-file="dev.tfvars"
```

### State/Provider Error

Do not immediately delete Terraform state.

First inspect:

```bash
terraform state list
```

and:

```bash
terraform providers
```

`terraform state list` helps us understand which resources Terraform currently tracks.

`terraform providers` helps us understand the provider requirements associated with the configuration and state.

Provider configuration information is retained in Terraform state because Terraform may need the appropriate provider configuration for operations involving existing resources, including destruction.

### Terraform Configuration Error

Start with:

```bash
terraform fmt
```

then:

```bash
terraform validate
```

and finally:

```bash
terraform plan
```

A useful troubleshooting sequence is:

```text
terraform fmt
      ↓
terraform validate
      ↓
terraform plan
      ↓
Review error
      ↓
Inspect configuration/state
      ↓
Correct problem
      ↓
terraform plan
```

## 10. Professional Git Workflow

After creating and validating the project, review the files:

```text
versions.tf
providers.tf
variables.tf
main.tf
outputs.tf
terraform.tfvars.example
.gitignore
.terraform.lock.hcl
```

Check Git status:

```bash
git status
```

We should confirm that:

```text
terraform.tfvars
```

is not staged or committed.

We should normally see:

```text
.terraform.lock.hcl
```

as a trackable file.

We should not commit:

```text
.terraform/
*.tfstate
*.tfstate.*
terraform.tfvars
*.tfplan
```

## 11. Final Project Flow

The complete learning flow is:

```text
                   Terraform Project
                           │
                           ▼
                      versions.tf
                           │
                           ▼
                 Provider Requirements
                           │
                           ▼
                      providers.tf
                           │
                           ▼
              Multiple AWS Configurations
                           │
                ┌──────────┴──────────┐
                ▼                     ▼
         Primary Region      Secondary Region
                │                     │
                └──────────┬──────────┘
                           ▼
                     variables.tf
                           │
                           ▼
                    Input Variables
                           │
                           ▼
                    terraform.tfvars
                           │
                           ▼
                        main.tf
                           │
             ┌─────────────┴─────────────┐
             ▼                           ▼
       Primary EC2                 Conditional EC2
                                         │
                                         ▼
                              create_secondary_instance
                                         │
                                         ▼
                                       count
                           │
                           ▼
                      outputs.tf
                           │
                           ▼
                  IDs / IPs / Summary
                           │
                           ▼
                    fmt → validate
                           │
                           ▼
                         plan
                           │
                           ▼
                         apply
                           │
                           ▼
                  Validate AWS Resources
                           │
                           ▼
                        destroy
                           │
                           ▼
                   Final terraform plan
```

This project therefore connects the 02-terraform-configuration concepts into one practical workflow:

```text
Providers
   +
Provider Requirements
   +
Provider Aliases
   +
Multiple Regions
   +
Variables
   +
.tfvars
   +
Conditional Expressions
   +
Built-in Functions
   +
Outputs
   +
Validation
   +
Planning
   +
Apply
   +
Troubleshooting
   +
Cleanup
   =
Reusable Terraform Configuration
```

> **Historical compatibility note:** older Terraform examples may contain deprecated provider-version syntax, older `map()` usage, or other legacy constructs. Those examples are useful for understanding Terraform's evolution, but modern projects should follow the current `required_providers`, modern expression syntax, and current provider documentation.
