
## Terraform Modules

> **File:** `01-modules.md`

## Table of Contents

1. [Overview](#1-overview)
2. [Prerequisites and Required Knowledge](#2-prerequisites-and-required-knowledge)
3. [What Is a Terraform Module?](#3-what-is-a-terraform-module)
4. [Why Do We Need Modules?](#4-why-do-we-need-modules)
5. [Terraform Root Module and Child Modules](#5-terraform-root-module-and-child-modules)
6. [Types of Terraform Modules](#6-types-of-terraform-modules)
7. [Advantages of Modules](#7-advantages-of-modules)
8. [Development Environment and Lab Prerequisites](#8-development-environment-and-lab-prerequisites)
9. [Lab 1 — Build a Regular Terraform Project](#9-lab-1--build-a-regular-terraform-project)
10. [Executing and Validating the Initial Project](#10-executing-and-validating-the-initial-project)
11. [Terraform Output Values](#11-terraform-output-values)
12. [Recommended Project Structure](#12-recommended-project-structure)
13. [Lab 2 — Convert the Project into a Terraform Module](#13-lab-2--convert-the-project-into-a-terraform-module)
14. [Calling a Local Module](#14-calling-a-local-module)
15. [Module Inputs and Outputs](#15-module-inputs-and-outputs)
16. [Remote Git/GitHub Modules](#16-remote-gitgithub-modules)
17. [Terraform Registry Modules](#17-terraform-registry-modules)
18. [Module Versioning](#18-module-versioning)
19. [Module Design Best Practices](#19-module-design-best-practices)
20. [Security Considerations](#20-security-considerations)
21. [Troubleshooting](#21-troubleshooting)
22. [End-to-End Module Lab](#22-end-to-end-module-lab)
23. [Execution Workflow](#23-execution-workflow)
24. [Cleanup](#24-cleanup)
25. [Key Takeaways](#25-key-takeaways)
26. [Interview Questions and Answers](#26-interview-questions-and-answers)

## 1. Overview

Terraform modules are one of the most important concepts for building **reusable, maintainable, and scalable Infrastructure as Code (IaC)**.

As Terraform configurations grow, keeping every resource in one large configuration can become difficult to understand, maintain, test, and reuse.

For example, an organization may manage:

* EC2 instances
* VPCs
* Subnets
* Security Groups
* Load Balancers
* RDS databases
* IAM resources
* EKS clusters

If all of these resources are implemented directly in one large Terraform configuration, the configuration can become difficult to manage.

Terraform modules solve this problem by allowing related Terraform resources and configuration to be packaged into **reusable building blocks**.

A module can then be called from another Terraform configuration and supplied with different inputs.

```text
                    Terraform Module
                           |
             +-------------+-------------+
             |             |             |
            Dev           Test          Prod
             |             |             |
          Resources     Resources     Resources
```

The implementation remains centralized while the configuration can vary through inputs.

## 2. Prerequisites and Required Knowledge

Before starting Terraform Modules, we should understand the important Terraform concepts covered in the previous sections.

We should be familiar with:

* Terraform providers
* Multiple providers
* Provider aliases
* Multiple AWS regions
* `required_providers`
* Input variables
* Variable definition files
* `.tfvars`
* Conditional expressions
* Built-in functions
* Outputs
* `terraform init`
* `terraform fmt`
* `terraform validate`
* `terraform plan`
* `terraform apply`
* `terraform destroy`

The general Terraform workflow is:

```text
Terraform Configuration
        |
        v
terraform init
        |
        v
terraform fmt
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
AWS Infrastructure
```

As the configuration grows, this model can become increasingly difficult to manage.

Modules provide a way to organize and reuse this configuration.

## 3. What Is a Terraform Module?

### 3.1 Definition

A **Terraform module** is a collection of Terraform configuration files that are managed together and can be reused by another Terraform configuration.

A module can contain:

* Resources
* Data sources
* Variables
* Outputs
* Locals
* Provider requirements
* Other modules

For example:

```text
EC2 Module
│
├── main.tf
├── variables.tf
├── outputs.tf
└── versions.tf
```

The module can then be called from another Terraform configuration:

```hcl
module "ec2" {
  source = "./modules/ec2"

  instance_type = "t3.micro"
}
```

Instead of repeatedly writing the EC2 resource configuration, we can reuse the module.

### 3.2 Module Analogy

Consider a company that manufactures computers.

Instead of designing every computer completely from scratch, the company can create reusable components:

```text
CPU Module
RAM Module
Storage Module
Network Module
Power Module
```

These components can be combined to build different computers.

Terraform modules work similarly.

```text
EC2 Module
     |
     +---- Dev Environment
     |
     +---- Test Environment
     |
     +---- Production Environment
```

The implementation is centralized while the configuration can vary.

## 4. Why Do We Need Modules?

Consider a large Terraform project:

```text
main.tf
variables.tf
outputs.tf
network.tf
security.tf
database.tf
compute.tf
loadbalancer.tf
iam.tf
...
```

As the project grows, the configuration can become difficult to maintain.

We may also need the same infrastructure multiple times.

For example:

```text
Development
    └── EC2

Testing
    └── EC2

Staging
    └── EC2

Production
    └── EC2
```

Without modules, we may duplicate similar Terraform code.

With modules:

```text
                    EC2 Module
                       |
          +------------+------------+
          |            |            |
         Dev          QA          Prod
          |            |            |
        EC2-1        EC2-2        EC2-3
```

The implementation remains reusable.

Only the inputs change.

## 5. Terraform Root Module and Child Modules

Terraform modules have an important parent-child relationship.

### 5.1 Root Module

The **root module** is the Terraform configuration from which we execute Terraform commands.

For example:

```text
project/
├── main.tf
├── variables.tf
├── outputs.tf
└── terraform.tfvars
```

When we run:

```bash
terraform init
terraform plan
terraform apply
```

from this directory, this configuration is the **root module**.

### 5.2 Child Module

A module called by another module is a **child module**.

For example:

```text
project/
│
├── main.tf                  # Root module
│
└── modules/
    └── ec2/
        ├── main.tf          # Child module
        ├── variables.tf
        └── outputs.tf
```

The relationship is:

```text
Root Module
     |
     | calls
     v
Child Module
     |
     +---- aws_instance
     +---- security group
     +---- other resources
```

A root module can call multiple child modules, and a child module can itself call other modules.

## 6. Types of Terraform Modules

Terraform modules can be consumed from several sources.

### 6.1 Local Modules

A module can exist inside the same repository.

```hcl
module "ec2" {
  source = "./modules/ec2"
}
```

Local modules are particularly useful while developing our own modules.

Example:

```text
project/
├── main.tf
└── modules/
    └── ec2/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### 6.2 Git/GitHub Modules

A module can be stored in a Git repository.

Example:

```hcl
module "ec2" {
  source = "git::https://github.com/example-org/terraform-aws-ec2.git"
}
```

A specific Git tag can be selected:

```hcl
module "ec2" {
  source = "git::https://github.com/example-org/terraform-aws-ec2.git?ref=v1.0.0"
}
```

A Git revision such as a branch, tag, or commit SHA can be referenced.

For production environments, immutable references such as release tags or commit SHAs are preferable to continuously tracking a branch.

### 6.3 Terraform Registry Modules

Terraform also supports modules published to the Terraform Registry.

Example:

```hcl
module "example" {
  source  = "namespace/module/provider"
  version = "1.0.0"
}
```

The Terraform Registry provides reusable modules from HashiCorp, partners, and the community.

Organizations can also use private module registries through HCP Terraform/Terraform Enterprise.

## 7. Advantages of Modules

### 7.1 Reusability

A module can be used multiple times.

```hcl
module "dev_ec2" {
  source = "./modules/ec2"
}

module "prod_ec2" {
  source = "./modules/ec2"
}
```

The same implementation can be reused with different inputs.

### 7.2 Reduced Code Duplication

Instead of copying the same resource configuration multiple times:

```hcl
resource "aws_instance" "example" {
  ...
}
```

we maintain the implementation once inside the module.

### 7.3 Standardization

An organization can create a standard EC2 module that enforces:

* Required tags
* Approved instance types
* Security standards
* Monitoring configuration
* Naming conventions
* Encryption requirements

Teams can then consume the approved module instead of implementing everything independently.

### 7.4 Maintainability

When the implementation is centralized, changes can be made in one place.

For example:

```text
EC2 Module
    |
    +---- Dev
    +---- Test
    +---- Staging
    +---- Production
```

A module update can then be adopted by the environments that consume it.

### 7.5 Scalability

Modules allow Terraform configurations to grow without putting every resource directly into a single configuration.

A larger architecture might look like:

```text
Root Module
│
├── Network Module
├── Security Module
├── Database Module
├── Compute Module
└── Monitoring Module
```

Each module can have a focused responsibility.

## 8. Development Environment and Lab Prerequisites

For the practical lab, we need:

| Tool        | Purpose                             |
| ----------- | ----------------------------------- |
| Terraform   | Infrastructure as Code              |
| AWS CLI     | AWS command-line access             |
| Git         | Version control                     |
| AWS Account | Infrastructure deployment           |
| Code Editor | Terraform configuration development |

### 8.1 Verify Terraform

Run:

```bash
terraform version
```

The project should be executed using a currently supported Terraform CLI release.

Record the exact Terraform version used for the project so that the execution environment remains reproducible.

### 8.2 Verify AWS CLI

Run:

```bash
aws --version
```

### 8.3 Verify AWS Authentication

Run:

```bash
aws sts get-caller-identity
```

A successful response confirms that the AWS CLI can authenticate with the configured AWS account.

## 9. Lab 1 — Build a Regular Terraform Project

Before introducing modules, we first create a normal Terraform project.

The initial project directly manages an EC2 instance.

Example:

```text
project-ec2-instance/
├── versions.tf
├── main.tf
├── variables.tf
├── terraform.tfvars
└── outputs.tf
```

The resource is initially defined directly in the root module.

```hcl
resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name        = var.instance_name
    Environment = var.environment
  }
}
```

This helps us understand what the configuration looks like before introducing a module.

## 10. Executing and Validating the Initial Project

From the project directory:

```bash
terraform init
```

Format the configuration:

```bash
terraform fmt
```

Validate the configuration:

```bash
terraform validate
```

Create an execution plan:

```bash
terraform plan
```

Apply the configuration:

```bash
terraform apply
```

Review the proposed changes and confirm:

```text
yes
```

Terraform then creates the EC2 instance.

## 11. Terraform Output Values

Terraform outputs allow us to expose useful values from resources.

Example:

```hcl
output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.this.id
}
```

After applying the configuration, we can inspect outputs:

```bash
terraform output
```

Outputs become particularly important when working with modules because they provide a controlled interface between a child module and its caller.

## 12. Recommended Project Structure

A simple Terraform module project can use the following structure:

```text
project-ec2-module/
│
├── README.md
├── versions.tf
├── main.tf
├── variables.tf
├── terraform.tfvars.example
├── outputs.tf
│
└── modules/
    └── ec2/
        ├── versions.tf
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

The root module is responsible for project-level configuration.

The child module contains the reusable EC2 implementation.

## 13. Lab 2 — Convert the Project into a Terraform Module

We now convert the direct EC2 resource into a reusable child module.

The architecture becomes:

```text
Root Module
│
├── Provider Configuration
├── Root Variables
├── Module Call
└── Root Outputs
        |
        v
    EC2 Module
        |
        └── aws_instance
```

The EC2 resource moves from the root module into:

```text
modules/ec2/main.tf
```

The root module calls it:

```hcl
module "ec2" {
  source = "./modules/ec2"

  ami_id        = var.ami_id
  instance_type = var.instance_type
  instance_name = var.instance_name
  environment   = var.environment
}
```

This creates a clear separation between:

* Project-level configuration
* Reusable infrastructure implementation

## 14. Calling a Local Module

A local module is called using the `source` argument.

```hcl
module "ec2" {
  source = "./modules/ec2"
}
```

The `source` tells Terraform where the module configuration should be obtained from.

For example:

```hcl
source = "./modules/ec2"
```

or:

```hcl
source = "terraform-aws-modules/vpc/aws"
```

For our project, we use a local module:

```text
project-ec2-module/
└── modules/
    └── ec2/
```

## 15. Module Inputs and Outputs

Modules communicate with their callers using **inputs and outputs**.

### 15.1 Module Inputs

The child module defines variables:

```hcl
variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}
```

The root module supplies the value:

```hcl
module "ec2" {
  source = "./modules/ec2"

  instance_type = var.instance_type
}
```

The value flows from:

```text
Root Variable
     |
     v
Module Input
     |
     v
EC2 Resource
```

### 15.2 Module Outputs

The child module defines an output:

```hcl
output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.this.id
}
```

The root module can then expose that output:

```hcl
output "instance_id" {
  description = "EC2 instance ID."
  value       = module.ec2.instance_id
}
```

The value flows through:

```text
EC2 Resource
     |
     v
Child Module Output
     |
     v
Root Module
     |
     v
Root Output
```

This provides a controlled interface between modules.

## 16. Remote Git/GitHub Modules

Instead of storing a module inside the same repository, we can store it in a Git repository.

Example:

```hcl
module "ec2" {
  source = "git::https://github.com/example-org/terraform-aws-ec2.git"
}
```

A Git tag can be selected:

```hcl
module "ec2" {
  source = "git::https://github.com/example-org/terraform-aws-ec2.git?ref=v1.0.0"
}
```

A commit SHA can also be referenced.

Using a specific immutable revision provides more predictable behavior than continuously tracking a changing branch.

## 17. Terraform Registry Modules

Terraform Registry modules can be consumed using a registry source.

Example:

```hcl
module "example" {
  source  = "namespace/module/provider"
  version = "1.0.0"
}
```

This allows us to reuse modules maintained by:

* HashiCorp
* Partners
* Community contributors
* Organizations through private registries

Registry modules can significantly reduce the amount of infrastructure code we need to implement ourselves.

## 18. Module Versioning

Module versioning is important when consuming remote modules.

For example:

```hcl
module "example" {
  source  = "namespace/module/provider"
  version = "1.2.0"
}
```

### Why Versioning Matters

Without version control:

```text
Production
    |
    v
Latest Module
    |
    v
Unexpected change
```

With version control:

```text
Production
    |
    v
EC2 Module v1.2.0
    |
    v
Predictable infrastructure
```

Production infrastructure should use deliberate version constraints and controlled upgrades.

### Important Distinction: Modules vs Providers

Terraform's `.terraform.lock.hcl` records the selected **provider versions and checksums**.

It does not serve as a lock file for remote module versions.

```text
Provider
   |
   +---- .terraform.lock.hcl

Module
   |
   +---- version constraint in module block
```

This distinction is important when managing Terraform dependencies.

### Updating Modules

If we change a module source or module version, run:

```bash
terraform init
```

To reconsider and upgrade already-installed dependencies:

```bash
terraform init -upgrade
```

We should then inspect the resulting plan:

```bash
terraform plan
```

Module upgrades should never be blindly applied to production infrastructure.

## 19. Module Design Best Practices

A production-quality module should be designed as a reusable interface rather than simply being a folder containing copied Terraform resources.

### 19.1 Keep Modules Focused

A module should have a clear responsibility.

Good:

```text
modules/
├── ec2/
├── vpc/
├── security-group/
└── rds/
```

We should avoid creating one enormous module containing unrelated infrastructure unless there is a deliberate architectural reason.

### 19.2 Use Variables for Customization

Instead of hard-coding:

```hcl
instance_type = "t3.micro"
```

use:

```hcl
instance_type = var.instance_type
```

This makes the module reusable.

### 19.3 Use Outputs Deliberately

Expose values that callers actually need.

```hcl
output "instance_id" {
  value = aws_instance.this.id
}
```

Avoid exposing every internal implementation detail.

### 19.4 Document the Module

A reusable module should contain documentation.

```text
README.md
```

The documentation should explain:

* Purpose
* Inputs
* Outputs
* Requirements
* Providers
* Usage
* Examples
* Versioning
* Limitations
* Security considerations

### 19.5 Declare Provider Requirements

Reusable modules should declare the providers they require.

Example:

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
```

Provider requirements identify the provider source and compatible provider versions.

The reusable module should declare its own provider requirements.

### 19.6 Root Modules and Child Modules Have Different Versioning Goals

A reusable module can generally specify a minimum compatible Terraform or provider version.

A root module can impose the versions appropriate for the overall deployment.

This allows reusable modules to remain broadly compatible while root configurations can use tighter constraints for controlled deployments.

### 19.7 Standard Module Structure

A conventional module can look like:

```text
modules/
└── ec2/
    ├── README.md
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── versions.tf
```

This structure makes the module easier to understand and consume.

## 20. Security Considerations

Modules should follow the same security principles as other Terraform configurations.

### 20.1 Never Hard-Code Credentials

Do not place AWS credentials directly inside Terraform configuration.

Avoid:

```hcl
provider "aws" {
  access_key = "..."
  secret_key = "..."
}
```

Modern authentication mechanisms can include:

* IAM roles
* AWS CLI profiles
* OIDC
* Web identity
* Short-lived credentials
* CI/CD federation

### 20.2 Protect Variable Files

Variable files may contain sensitive configuration.

Do not commit sensitive values into Git.

A common pattern is:

```text
terraform.tfvars.example
```

for the committed template, while the actual:

```text
terraform.tfvars
```

remains local and is excluded through `.gitignore` when it contains sensitive values.

### 20.3 Review Module Sources

Before consuming a third-party module, review:

* Source repository
* Module implementation
* Inputs
* Outputs
* Provider requirements
* Version
* Security implications
* Maintenance status

Do not blindly consume infrastructure code simply because it is publicly available.

## 21. Troubleshooting

### Problem 1 — Module Not Found

If Terraform cannot find a local module, verify:

```hcl
source = "./modules/ec2"
```

Also verify that the directory exists:

```text
modules/
└── ec2/
```

Then run:

```bash
terraform init
```

### Problem 2 — Module Source Changed

After changing:

```hcl
source = "./modules/ec2"
```

or changing a remote module source, run:

```bash
terraform init
```

### Problem 3 — Changed Registry Module Version

After changing:

```hcl
version = "1.0.0"
```

to:

```hcl
version = "1.1.0"
```

run:

```bash
terraform init
```

Then review:

```bash
terraform plan
```

### Problem 4 — Output Not Found

Incorrect:

```hcl
module.ec2.id
```

Correct:

```hcl
module.ec2.instance_id
```

The final component must match the output declared by the child module.

### Problem 5 — Variable Not Defined

If the child module contains:

```hcl
var.instance_type
```

then the child module must define:

```hcl
variable "instance_type" {
  type = string
}
```

The caller must then provide the value:

```hcl
module "ec2" {
  source = "./modules/ec2"

  instance_type = "t3.micro"
}
```

### Problem 6 — Provider Configuration Issues

Provider configuration and provider requirements are different concepts.

A child module should declare that it requires AWS:

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
```

The caller normally provides the actual AWS provider configuration.

```text
Root Module
│
├── Provider Requirement
├── Provider Configuration
│
└── Child Module
    │
    ├── Provider Requirement
    └── Resources
```

### Problem 7 — Module Upgrade

To upgrade already-installed modules:

```bash
terraform init -upgrade
```

Then inspect:

```bash
terraform plan
```

Never blindly apply module upgrades in production.

## 22. End-to-End Module Lab

This lab combines the concepts covered in this section.

### 22.1 Final Structure

```text
03-modules/
├── 01-modules.md
│
└── project-ec2-module/
    ├── README.md
    ├── versions.tf
    ├── main.tf
    ├── variables.tf
    ├── terraform.tfvars.example
    ├── .terraform.lock.hcl
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

### 22.2 Prepare the Lab

Change into the project directory:

```bash
cd 03-modules/project-ec2-module
```

Create the local variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Then configure:

```hcl
aws_region    = "us-east-1"
ami_id        = "<ami-id>"
instance_type = "t3.micro"
instance_name = "terraform-module-demo"
environment   = "dev"
```

Format the configuration:

```bash
terraform fmt -recursive
```

### 22.3 Root `versions.tf`

```hcl
terraform {
  required_version = ">= 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.60"
    }
  }
}
```

### 22.4 Root `main.tf`

```hcl
provider "aws" {
  region = var.aws_region
}

module "ec2" {
  source = "./modules/ec2"

  ami_id        = var.ami_id
  instance_type = var.instance_type
  instance_name = var.instance_name
  environment   = var.environment
}
```

### 22.5 Root `variables.tf`

```hcl
variable "aws_region" {
  description = "AWS region where the EC2 instance will be created."
  type        = string
}

variable "ami_id" {
  description = "AMI ID used to launch the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}
```

### 22.6 Root `outputs.tf`

```hcl
output "instance_id" {
  description = "EC2 instance ID."
  value       = module.ec2.instance_id
}

output "public_ip" {
  description = "EC2 public IP address."
  value       = module.ec2.public_ip
}

output "public_dns" {
  description = "EC2 public DNS address."
  value       = module.ec2.public_dns
}
```

### 22.7 Child Module `versions.tf`

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
```

### 22.8 Child Module `variables.tf`

```hcl
variable "ami_id" {
  description = "AMI ID used to launch the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "instance_name" {
  description = "Name tag for the EC2 instance."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}
```

### 22.9 Child Module `main.tf`

```hcl
resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name        = var.instance_name
    Environment = var.environment
  }
}
```

### 22.10 Child Module `outputs.tf`

```hcl
output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance."
  value       = aws_instance.this.public_ip
}

output "public_dns" {
  description = "Public DNS name of the EC2 instance."
  value       = aws_instance.this.public_dns
}
```

## 23. Execution Workflow

From:

```text
03-modules/project-ec2-module/
```

run:

### Step 1 — Initialize

```bash
terraform init
```

### Step 2 — Format

```bash
terraform fmt -recursive
```

### Step 3 — Validate

```bash
terraform validate
```

### Step 4 — Review Plan

```bash
terraform plan
```

### Step 5 — Apply

```bash
terraform apply
```

Confirm:

```text
yes
```

### Step 6 — Inspect Outputs

```bash
terraform output
```

### Step 7 — Inspect State

```bash
terraform state list
```

We should see the module-managed resource.

## 24. Cleanup

Always clean up infrastructure after completing the lab if the resources are no longer required.

From:

```text
project-ec2-module/
```

run:

```bash
terraform destroy
```

Review the proposed destruction and confirm:

```text
yes
```

Terraform will destroy the EC2 instance managed by the module.

### 24.1 Verify Cleanup

Run:

```bash
terraform state list
```

The EC2 resource should no longer appear.

We can also verify the instance through the AWS Management Console or AWS CLI.

### Important

Do **not** simply delete:

```text
terraform.tfstate
```

to remove infrastructure.

Deleting Terraform state does not delete the actual AWS resources.

The correct process is:

```text
terraform destroy
       |
       v
AWS Resources Deleted
       |
       v
Terraform State Updated
```

## 25. Key Takeaways

After completing this section, we should be able to:

* Understand the purpose of Terraform modules.
* Distinguish between root and child modules.
* Create a local Terraform module.
* Define module input variables.
* Pass values from a root module to a child module.
* Define module outputs.
* Consume child-module outputs from the root module.
* Understand local, Git/GitHub, and Terraform Registry modules.
* Understand module versioning.
* Understand provider requirements versus provider configuration.
* Initialize and validate a module-based Terraform project.
* Inspect module-managed resources.
* Execute and validate infrastructure deployment.
* Safely destroy infrastructure after completing a lab.
* Apply module design best practices.
* Understand basic module security considerations.
* Troubleshoot common module issues.
* Understand how the same module pattern can be extended to larger infrastructure projects.

## 26. Interview Questions and Answers

### Q1. What is a Terraform module?

**Answer:**

A Terraform module is a collection of Terraform configuration files that are managed together and can be reused by another Terraform configuration.

### Q2. What is the difference between a root module and a child module?

**Answer:**

The root module is the Terraform configuration from which we execute Terraform commands.

A child module is a module called by another module.

```text
Root Module
     |
     v
Child Module
```

### Q3. Why do we use Terraform modules?

**Answer:**

Modules help us:

* Reuse Terraform configuration
* Reduce code duplication
* Standardize infrastructure
* Improve maintainability
* Organize larger Terraform projects
* Scale infrastructure configurations

### Q4. What is a local module?

**Answer:**

A local module is a module stored within the same repository or local filesystem.

Example:

```hcl
module "ec2" {
  source = "./modules/ec2"
}
```

### Q5. What does the `source` argument do?

**Answer:**

`source` tells Terraform where the module configuration should be obtained from.

Example:

```hcl
source = "./modules/ec2"
```

### Q6. What are the common module sources?

**Answer:**

Common module sources include:

* Local modules
* Git/GitHub modules
* Terraform Registry modules
* Private module registries

### Q7. How do modules receive values?

**Answer:**

Modules receive values through input variables.

Example:

```hcl
module "ec2" {
  source = "./modules/ec2"

  instance_type = "t3.micro"
}
```

The child module defines:

```hcl
variable "instance_type" {
  type = string
}
```

### Q8. How do modules return values?

**Answer:**

Modules return values through outputs.

Child module:

```hcl
output "instance_id" {
  value = aws_instance.this.id
}
```

Root module:

```hcl
output "instance_id" {
  value = module.ec2.instance_id
}
```

### Q9. Can we specify `version` for a local module?

**Answer:**

No.

The `version` argument applies to modules installed from a registry. Local modules do not support registry-style module version constraints.

### Q10. How do we specify a Git module version?

**Answer:**

A Git tag can be referenced:

```hcl
source = "git::https://github.com/example-org/terraform-aws-ec2.git?ref=v1.0.0"
```

A commit SHA can also be referenced.

### Q11. What happens when we change the module source?

**Answer:**

We should run:

```bash
terraform init
```

so Terraform can install or update the module source.

### Q12. What is the difference between provider version and module version?

**Answer:**

A provider is a plugin that allows Terraform to communicate with an infrastructure platform.

A module is reusable Terraform configuration.

```text
AWS Provider
    |
    v
Terraform
    |
    v
EC2 Module
    |
    v
AWS EC2
```

Provider versions are tracked in `.terraform.lock.hcl`.

Remote module versions are controlled through the module source and version constraints.

### Q13. Should modules hard-code AWS credentials?

**Answer:**

No.

Modern implementations should use secure authentication mechanisms such as:

* IAM roles
* AWS CLI profiles
* OIDC
* Web identity
* Short-lived credentials
* CI/CD federation

### Q14. Should production modules always use the latest version?

**Answer:**

No.

Production infrastructure should use deliberate version constraints and controlled upgrades.

### Q15. What is `terraform init -upgrade`?

**Answer:**

It tells Terraform to reconsider and upgrade already-installed dependencies, including modules, within their configured constraints.

### Q16. Can a child module call another child module?

**Answer:**

Yes.

Terraform supports nested modules.

```text
Root Module
    |
    +---- Network Module
    |         |
    |         +---- Security Module
    |
    +---- Compute Module
```

### Q17. Why are outputs important in modules?

**Answer:**

Outputs provide a controlled interface through which the calling module can consume values generated by the child module.

### Q18. Why should we pin module versions?

**Answer:**

To prevent unexpected module changes from silently affecting infrastructure.

For example:

```hcl
version = "1.2.0"
```

provides much more predictable behavior than relying on an unconstrained latest release.

### Q19. What is the difference between a Terraform module and a resource?

**Answer:**

A resource represents an individual infrastructure object:

```hcl
resource "aws_instance" "this" {
  ...
}
```

A module is a reusable collection of Terraform configuration that may contain multiple resources.

```text
EC2 Module
├── EC2
├── Security Group
├── IAM
└── CloudWatch
```

### Q20. What is the difference between provider requirements and provider configuration?

**Answer:**

Provider requirements declare which provider a module requires.

Example:

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
```

Provider configuration specifies how Terraform should connect to the provider.

Example:

```hcl
provider "aws" {
  region = var.aws_region
}
```

The root module normally provides the provider configuration, while reusable modules declare their provider requirements.

### Final Mental Model

```text
                         Terraform
                            |
                        Root Module
                            |
             +--------------+--------------+
             |              |              |
      Network Module  Compute Module  Database Module
                            |
                       EC2 Module
                            |
                      aws_instance
                            |
                         AWS EC2
```

The key idea is:

> A Terraform module packages infrastructure configuration into a reusable building block with inputs and outputs.
