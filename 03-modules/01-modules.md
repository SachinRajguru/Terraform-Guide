
## Terraform Modules

**File:** `01-modules.md`

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

As Terraform configurations grow, keeping every resource in one large configuration quickly becomes difficult to maintain.

For example, an organization may create:

* EC2 instances
* VPCs
* Subnets
* Security Groups
* Load Balancers
* RDS databases
* IAM resources
* EKS clusters

If every resource is implemented directly inside one large Terraform configuration, the configuration can become difficult to understand, test, reuse, and maintain.

> Terraform modules solve this problem by allowing related Terraform resources and configuration to be packaged into **reusable building blocks**.

HashiCorp defines modules as reusable configurations that allow collections of resources to be managed together. Terraform supports modules from local directories, registries, VCS repositories, and other supported sources. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/modules/configuration))

## 2. Prerequisites and Required Knowledge

Before starting modules, we should recall the important concepts covered in the previous section.

We worked with:

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

The general Terraform workflow was:

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

> The problem is that as the configuration grows, this model can become increasingly difficult to manage.

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

The module can then be called from another Terraform configuration.

```hcl
module "ec2" {
  source = "./modules/ec2"

  instance_type = "t3.micro"
}
```

Instead of repeatedly writing the EC2 resource configuration, we can reuse the module.

### 3.2 Module Analogy

Consider a company that manufactures computers.

Instead of designing every computer from scratch, the company creates reusable components:

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

> The implementation is centralized while the configuration can vary.

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

> Only the inputs change.

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

A root module can call multiple child modules, and a child module can itself call other modules. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/modules))

## 6. Types of Terraform Modules

Terraform modules can be consumed from several sources.

### 6.1 Local Modules

A module can exist inside the same repository.

```hcl
module "ec2" {
  source = "./modules/ec2"
}
```

This is particularly useful while developing our own modules.

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

Terraform supports selecting Git revisions such as branches, tags, and commit SHA references. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/modules/configuration))

> For production environments, immutable references such as release tags or commit SHAs are preferable to continuously tracking a branch.

### 6.3 Terraform Registry Modules

Terraform also supports modules published to the Terraform Registry.

Example:

```hcl
module "example" {
  source  = "namespace/module/provider"
  version = "1.0.0"
}
```

> The Terraform Registry provides reusable modules from HashiCorp, partners, and the community.

Organizations can also use private module registries through HCP Terraform/Terraform Enterprise. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/modules))

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

### 7.2 Reduced Code Duplication

Instead of copying:

```hcl
resource "aws_instance" "example" {
  ...
}
```

multiple times, we maintain the implementation once.

### 7.3 Standardization

An organization can create a standard EC2 module that enforces:

* Required tags
* Approved instance types
* Security standards
* Monitoring configuration
* Naming conventions
* Encryption requirements

Teams then consume the approved module instead of implementing everything independently.

### 7.4 Maintainability

Changes can be implemented centrally.

For example:

```text
Before

Application A ──> copied EC2 configuration
Application B ──> copied EC2 configuration
Application C ──> copied EC2 configuration
```

versus:

```text
                EC2 Module
               /    |     \
              /     |      \
          App A   App B   App C
```

### 7.5 Scalability

Modules make it easier to build infrastructure consistently across:

* Multiple applications
* Multiple teams
* Multiple environments
* Multiple AWS accounts
* Multiple regions

## 8. Development Environment and Lab Prerequisites

Before performing the practical exercises, we should have the following.

### Required Tools

| Tool                  | Purpose                               |
| --------------------- | ------------------------------------- |
| Terraform             | Infrastructure as Code                |
| AWS CLI               | AWS authentication and CLI operations |
| AWS Account           | Infrastructure deployment             |
| Git                   | Version control                       |
| GitHub                | Repository/module hosting             |
| VS Code or equivalent | Configuration development             |

### Terraform Version

The examples should be executed with a currently supported Terraform release.

Always verify the installed version:

```bash
terraform version
```

Terraform's `version` command displays the Terraform CLI version and installed provider plugins. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/cli/commands/version))

The exact **Terraform CLI version** used in a lab should always be recorded in the repository or environment documentation.

> The `required_version` constraint defines which Terraform CLI versions are compatible with a configuration. Exact Terraform CLI reproducibility should be controlled through the project's documented tool/version requirements rather than relying only on a minimum-version constraint.

### AWS Provider

The lab uses AWS provider `~> 6.60` as the documented example version. Provider versions should be reviewed and updated deliberately as part of dependency maintenance. ([Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/latest))

For reproducible training, we should nevertheless explicitly constrain the provider version rather than silently consuming whatever version happens to be latest.

Example:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.60"
    }
  }
}
```

> **Important:** Provider versions evolve independently from Terraform CLI versions. The exact provider version used by a project should be selected deliberately and recorded in `.terraform.lock.hcl`.

### AWS Authentication

Recommended authentication approaches include:

* AWS CLI profiles
* Environment variables
* IAM roles
* Instance profiles
* Web identity/OIDC
* CI/CD identity federation
* Short-lived credentials

#### Avoid

Hard-coding credentials directly into Terraform files:

```hcl
provider "aws" {
  access_key = "AKIA..."
  secret_key = "..."
}
```

This is a legacy approach and is **not recommended** for modern implementations.

## 9. Lab 1 — Build a Regular Terraform Project

Before converting anything into a module, we first create a normal Terraform project.

This gives us a clear understanding of the problem that modules solve.

### 9.1 Project Structure

Create:

```text
project-ec2-instance/
├── versions.tf
├── main.tf
├── variables.tf
├── terraform.tfvars.example
└── outputs.tf
```

### 9.2 `versions.tf`

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

#### Explanation

`required_version` controls the Terraform CLI version constraint.

`required_providers` declares the provider dependency.

The provider source:

```text
hashicorp/aws
```

identifies the official AWS provider.

### 9.3 `main.tf`

```hcl
provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name        = var.instance_name
    Environment = var.environment
  }
}
```

### 9.4 `variables.tf`

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

### 9.5 `terraform.tfvars.example`

Example:

```hcl
aws_region    = "us-east-1"
ami_id        = "<ami-id>"
instance_type = "t3.micro"
instance_name = "terraform-module-demo"
environment   = "dev"
```

Replace `<ami-id>` with an AMI appropriate for the selected AWS region.

## 10. Executing and Validating the Initial Project

From the project directory:

```bash
terraform init
```

This initializes the working directory and downloads required providers.

### Format

```bash
terraform fmt
```

### Validate

```bash
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

### Plan

```bash
terraform plan
```

The plan allows us to review the infrastructure changes before applying them.

### Apply

```bash
terraform apply
```

Review the plan and confirm:

```text
yes
```

Terraform then creates the EC2 instance.

## 11. Terraform Output Values

Outputs allow Terraform to expose useful values from a configuration.

Create:

### `outputs.tf`

```hcl
output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.this.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance."
  value       = aws_instance.this.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance."
  value       = aws_instance.this.public_dns
}
```

After applying:

```bash
terraform output
```

Example:

```text
instance_id = "i-0123456789abcdef0"
instance_public_ip = "3.x.x.x"
instance_public_dns = "ec2-3-x-x-x.us-east-1.compute.amazonaws.com"
```

Outputs become particularly important when working with modules because they provide the interface through which a parent module consumes values from a child module.

## 12. Recommended Project Structure

For a simple Terraform project:

```text
project-ec2-instance/
├── versions.tf
├── main.tf
├── variables.tf
├── terraform.tfvars.example
├── outputs.tf
├── .terraform.lock.hcl
│
├── .gitignore
└── README.md
```

A larger module-based project can be organized as:

```text
project/
├── versions.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
├── .terraform.lock.hcl
├── README.md
│
└── modules/
    └── ec2/
        ├── versions.tf
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── README.md
```

## 13. Lab 2 — Convert the Project into a Terraform Module

Now we convert the EC2 implementation into a reusable module.

This is the key practical exercise.

### 13.1 Before Conversion

Initially:

```text
project/
├── versions.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── terraform.tfvars.example
```

> The EC2 resource is directly inside the root module.

### 13.2 After Conversion

We create:

```text
project/
├── versions.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
│
└── modules/
    └── ec2/
        ├── versions.tf
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

The architecture becomes:

```text
                    Root Module
                        |
                        | module "ec2"
                        v
                    EC2 Module
                 /       |       \
                /        |        \
          variables   resource   outputs
```

## 14. Calling a Local Module

### 14.1 Child Module — `modules/ec2/versions.tf`

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
```

### 14.2 Child Module — `modules/ec2/main.tf`

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

### 14.3 Child Module — `modules/ec2/variables.tf`

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

### 14.4 Child Module — `modules/ec2/outputs.tf`

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

### 14.5 Provider Requirements vs Provider Configuration

A reusable child module should declare which providers it requires.

For example:

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
```

This is the provider requirement.

The actual provider configuration is normally defined by the root module:

```hcl
provider "aws" {
  region = var.aws_region
}
```

The distinction is important:

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

Provider requirements tell Terraform which provider a module depends on.

Provider configurations define how Terraform should connect to the target platform.

## 15. Module Inputs and Outputs

A module can be understood as a function.

```text
                  Module
             +--------------+
             |              |
Inputs ----->|  EC2 Module  |-----> Outputs
             |              |
             +--------------+
```

For example:

```text
Inputs
-----
ami_id
instance_type
instance_name
environment

        |
        v
     EC2 Module
        |
        v

Outputs
-------
instance_id
public_ip
public_dns
```

### 15.1 Root Module

The root module calls the child module.

```hcl
module "ec2" {
  source = "./modules/ec2"

  ami_id        = var.ami_id
  instance_type = var.instance_type
  instance_name = var.instance_name
  environment   = var.environment
}
```

The `source` argument tells Terraform where to obtain the module configuration. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/block/module))

### 15.2 Consuming Module Outputs

Root `outputs.tf`:

```hcl
output "instance_id" {
  description = "EC2 instance ID."
  value       = module.ec2.instance_id
}

output "public_ip" {
  description = "EC2 public IP."
  value       = module.ec2.public_ip
}

output "public_dns" {
  description = "EC2 public DNS."
  value       = module.ec2.public_dns
}
```

Notice the syntax:

```text
module.<module-name>.<output-name>
```

For example:

```hcl
module.ec2.instance_id
```

## 16. Remote Git/GitHub Modules

Once a module is developed locally, it can be distributed through Git.

Example:

```hcl
module "ec2" {
  source = "git::https://github.com/example-org/terraform-aws-ec2.git?ref=v1.0.0"

  ami_id        = var.ami_id
  instance_type = var.instance_type
  instance_name = var.instance_name
  environment   = var.environment
}
```

Terraform downloads the module when we run:

```bash
terraform init
```

If the module source changes, we must initialize again:

```bash
terraform init
```

> For already installed modules, `-upgrade` can be used when we intentionally want Terraform to update the selected module version within the allowed constraints. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/modules/configuration))

> The `-upgrade` option tells Terraform to reconsider dependency selections and install newer versions that satisfy the configured constraints, including provider and module dependencies.

### Git Branch Reference

A branch can be referenced:

```hcl
module "ec2" {
  source = "git::https://github.com/example-org/terraform-aws-ec2.git?ref=main"
}
```

However, using a mutable branch such as `main` for production infrastructure introduces reproducibility risk.

Prefer:

```text
v1.0.0
```

or an immutable commit SHA.

## 17. Terraform Registry Modules

The Terraform Registry provides Terraform's native module discovery and distribution mechanism for published modules. Organizations can also use private registries or Git-based module distribution depending on their requirements.

Example:

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.0"

  # module inputs...
}
```

> The exact module version should be selected from the module's documentation rather than blindly using the latest release.

The Registry allows consumers to specify module versions and therefore provides a predictable dependency model. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/modules/develop/publish))

### Private Modules

Organizations may also maintain private modules.

Conceptually:

```text
                    Organization
                         |
                  Private Registry
                         |
          +--------------+--------------+
          |              |              |
       Network         EC2            EKS
       Module          Module         Module
```

This allows platform teams to provide standardized infrastructure building blocks to application teams.

## 18. Module Versioning

Versioning is important for production infrastructure.

Consider:

```text
EC2 Module
v1.0.0
v1.1.0
v2.0.0
```

A production environment should not unexpectedly switch to a breaking version.

### Registry Module Version

```hcl
module "ec2" {
  source  = "example-org/ec2/aws"
  version = "1.2.0"
}
```

A version constraint can also be used:

```hcl
module "ec2" {
  source  = "example-org/ec2/aws"
  version = "~> 1.2"
}
```

Terraform's version constraints support operators such as:

```text
=
!=
>
>=
<
<=
~>
```

Terraform recommends explicitly constraining module versions when infrastructure depends on third-party modules. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/expressions/version-constraints))

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

### Important Distinction: Modules vs Providers

Terraform's `.terraform.lock.hcl` records the selected **provider versions and checksums**. It does not serve as a lock file for remote module versions.

Remote modules are selected according to their **module source and version constraints**. When deterministic module selection is required, an exact module version can be specified. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/files/dependency-lock))

Therefore:

```text
Provider
   |
   +---- .terraform.lock.hcl

Module
   |
   +---- version constraint in module block
```

> This distinction is important when managing Terraform dependencies.

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

> Avoid creating one enormous module containing unrelated infrastructure unless there is a deliberate architectural reason.

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

> Avoid exposing every internal implementation detail.

### 19.4 Document the Module

A reusable module should contain:

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

Provider requirements identify the provider source and compatible provider versions. Each module should declare its own provider requirements. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/modules/develop/providers))

> A reusable module generally should avoid unnecessarily constraining the caller to one exact provider version unless there is a specific compatibility requirement.

### 19.6 Root Modules and Child Modules Have Different Versioning Goals

A reusable module can generally specify a minimum compatible Terraform/provider version.

A root module can impose the versions appropriate for the overall deployment.

HashiCorp's current guidance recommends this distinction: reusable modules should generally constrain minimum versions, while root configurations can use tighter constraints for controlled deployments. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/expressions/version-constraints))

### 19.7 Standard Module Structure

A conventional module can look like:

```text
terraform-aws-ec2/
│
├── versions.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── README.md
│
├── examples/
│   └── complete/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── .gitignore
```

For a simple learning module, `examples/` may not be necessary initially.

## 20. Security Considerations

> Modules do not automatically make infrastructure secure.

A poorly designed module can actually spread insecure configuration across multiple environments.

### 20.1 Never Hard-Code Secrets

Avoid:

```hcl
password = "MyPassword123"
```

Use:

* AWS Secrets Manager
* SSM Parameter Store
* CI/CD secret management
* IAM roles
* OIDC
* Environment-specific secret injection

### 20.2 Avoid Credentials in Variables

Do not create:

```hcl
variable "aws_secret_key" {}
```

and pass credentials through Terraform configuration.

> Terraform itself can process sensitive values, but credentials should preferably be provided through the appropriate AWS authentication mechanism.

### 20.3 Sensitive Outputs

If an output contains sensitive information:

```hcl
output "database_password" {
  value     = var.database_password
  sensitive = true
}
```

However, `sensitive = true` primarily controls display behavior; it should not be treated as a substitute for secure secret management.

### 20.4 Review Third-Party Modules

Before using a public module:

1. Review the source repository.
2. Review resources created by the module.
3. Check provider requirements.
4. Check release history.
5. Check open issues.
6. Check security practices.
7. Pin an appropriate version.
8. Test the module in a non-production environment.

## 21. Troubleshooting

### Problem 1 — Module Not Found

Error:

```text
Module not installed
```

Run:

```bash
terraform init
```

### Problem 2 — Changed Module Source

If:

```hcl
source = "./modules/ec2"
```

is changed, run:

```bash
terraform init
```

Terraform must reinitialize the module installation. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/modules/configuration))

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

and the caller must provide the value:

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

```hcl
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

Provider configurations are shared across modules, while provider requirements are declared by each module. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/modules/develop/providers))

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

This lab combines the concepts covered so far.

### 22.1 Final Structure

```text
03-modules/
├── README.md
├── 01-modules.md
│
├── project-ec2-module/
│   ├── README.md
│   ├── versions.tf
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars.example
│   ├── .terraform.lock.hcl
│   ├── outputs.tf
│   │
│   └── modules/
│       └── ec2/
│           ├── README.md
│           ├── versions.tf
│           ├── main.tf
│           ├── variables.tf
│           └── outputs.tf
│
└── .gitignore
```

#### 22.1.1 Prepare the Lab

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

Then format the configuration:

```bash
terraform fmt -recursive
```

### 22.2 Root `versions.tf`

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

### 22.3 Root `main.tf`

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

### 22.4 Root `variables.tf`

```hcl
variable "aws_region" {
  description = "AWS region for deployment."
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "instance_name" {
  description = "EC2 Name tag."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}
```

### 22.5 Root `terraform.tfvars.example`

```hcl
aws_region    = "us-east-1"
ami_id        = "<ami-id>"
instance_type = "t3.micro"
instance_name = "terraform-module-demo"
environment   = "dev"
```

### 22.6 Child Module `versions.tf`

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
```

The child module declares the AWS provider requirement but does not need to configure the AWS region itself. The root module normally provides the provider configuration.

### 22.7 Child Module `main.tf`

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

### 22.8 Child Module `variables.tf`

```hcl
variable "ami_id" {
  description = "AMI ID used by the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "instance_name" {
  description = "EC2 instance name."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}
```

### 22.9 Child Module `outputs.tf`

```hcl
output "instance_id" {
  description = "EC2 instance ID."
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "EC2 public IP address."
  value       = aws_instance.this.public_ip
}

output "public_dns" {
  description = "EC2 public DNS."
  value       = aws_instance.this.public_dns
}
```

### 22.10 Root `outputs.tf`

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
  description = "EC2 public DNS."
  value       = module.ec2.public_dns
}
```

The complete execution sequence for this project is covered in the next section.

## 23. Execution Workflow

From the root module:

### Step 1 — Format

```bash
terraform fmt -recursive
```

### Step 2 — Initialize

```bash
terraform init
```

Terraform initializes the working directory and installs the required provider and child module.

### Step 3 — Validate

```bash
terraform validate
```

### Step 4 — Inspect Modules

With Terraform v1.10+, we can use the `terraform modules` command to inspect the module tree and module dependencies:

```bash
terraform modules
```

This command provides a view of declared modules, including their keys, sources, versions, and module hierarchy. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/cli/commands/modules))

> **Note:** Command availability and behavior should be verified against the Terraform CLI version used in the lab.

### Step 5 — Plan

```bash
terraform plan
```

Review the proposed infrastructure changes carefully.

### Step 6 — Apply

```bash
terraform apply
```

Confirm the operation when prompted:

```bash
yes
```

### Step 7 — Inspect Outputs

```bash
terraform output
```

The outputs should display the EC2 instance ID, public IP, and public DNS.

### Step 8 — Inspect State

```bash
terraform state list
```

We should see a resource address similar to:

```text
module.ec2.aws_instance.this
```

This demonstrates that the EC2 resource is now managed through the module.

## 24. Cleanup

After completing the lab, infrastructure must be removed to prevent unnecessary AWS charges.

From the root module:

```bash
terraform destroy
```

Review the proposed destruction.

Confirm:

```text
yes
```

Verify:

```bash
terraform state list
```

The managed resources should no longer be present.

If the project is only a temporary practice environment, the following local Terraform artifacts can be removed after the infrastructure has been destroyed:

```text
.terraform/
terraform.tfstate
terraform.tfstate.backup
```

The local `terraform.tfvars` file should also remain uncommitted if it contains environment-specific or sensitive values.

However:

> Do not delete state files as a substitute for `terraform destroy`.

Terraform state contains the information Terraform uses to manage infrastructure.

For a real production project, state management and retention must follow the organization's backend and recovery policies.

> **Important:** `.terraform.lock.hcl` should normally be committed to version control. It records provider selections and checksums and helps ensure consistent provider installation across environments. It should not normally be treated as a disposable cleanup artifact.

## 25. Key Takeaways

The most important concepts from this section are:

1. A module is a reusable Terraform configuration.
2. The directory where Terraform is executed is normally the root module.
3. A module called by another module is a child module.
4. Modules reduce duplication.
5. Modules improve standardization.
6. Modules can expose inputs through variables.
7. Modules can expose outputs through `output` blocks.
8. Modules can be stored locally.
9. Modules can be stored in Git/GitHub.
10. Modules can be published to the Terraform Registry.
11. Private registries can be used for organizational modules.
12. Registry modules support version constraints.
13. Git modules can use tags or commit references.
14. `terraform init` installs modules.
15. `terraform init -upgrade` can upgrade installed modules within allowed constraints.
16. Module versions should be deliberately controlled.
17. `.terraform.lock.hcl` locks provider selections, not remote module selections.
18. Reusable modules should declare provider requirements.
19. Secrets should never be hard-coded.
20. Modules should have a clear responsibility and documented interface.

## 26. Interview Questions and Answers

### Q1. What is a Terraform module?

**Answer:**
A Terraform module is a collection of Terraform configuration files that are managed together and can be reused by another Terraform configuration.

### Q2. What is the root module?

**Answer:**
The root module is the Terraform configuration from which Terraform commands such as `terraform plan` and `terraform apply` are executed.

### Q3. What is a child module?

**Answer:**
A child module is a module called by another module.

Example:

```hcl
module "ec2" {
  source = "./modules/ec2"
}
```

Here, `modules/ec2` is the child module.

### Q4. Why do we use Terraform modules?

**Answer:**

Modules provide:

* Reusability
* Standardization
* Maintainability
* Reduced duplication
* Scalability
* Better separation of responsibilities

### Q5. What are the common sources of Terraform modules?

**Answer:**

Terraform supports module sources including:

* Local filesystem
* Terraform Registry
* Git repositories
* GitHub
* Other supported remote package sources
* Private registries

([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/modules/configuration))

### Q6. How do we call a local module?

**Answer:**

```hcl
module "ec2" {
  source = "./modules/ec2"
}
```

### Q7. How do we pass values to a module?

**Answer:**

```hcl
module "ec2" {
  source = "./modules/ec2"

  instance_type = "t3.micro"
}
```

The child module receives the value through:

```hcl
variable "instance_type" {
  type = string
}
```

### Q8. How do we access module outputs?

**Answer:**

```hcl
module.ec2.instance_id
```

The syntax is:

```text
module.<module-name>.<output-name>
```

### Q9. What is the purpose of the `source` argument?

**Answer:**
`source` tells Terraform where the module configuration should be obtained from.

Example:

```hcl
source = "./modules/ec2"
```

or:

```hcl
source = "terraform-aws-modules/vpc/aws"
```

### Q10. Can we specify `version` for a local module?

**Answer:**
No. The `version` argument applies to modules installed from a registry. Local modules do not support registry-style module version constraints. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/block/module))

### Q11. How do we specify a Git module version?

**Answer:**

A Git tag can be referenced:

```hcl
source = "git::https://github.com/example-org/terraform-aws-ec2.git?ref=v1.0.0"
```

A commit SHA can also be referenced.

### Q12. What happens when we change the module source?

**Answer:**
We must run:

```bash
terraform init
```

so Terraform can install/update the module source. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/modules/configuration))

### Q13. What is the difference between provider version and module version?

**Answer:**

A provider is a plugin that allows Terraform to communicate with an infrastructure platform.

A module is reusable Terraform configuration.

For example:

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

Provider versions are tracked in `.terraform.lock.hcl`; remote module versions are controlled by module source/version constraints. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/files/dependency-lock))

### Q14. Should modules hard-code AWS credentials?

**Answer:**
No.

Modern implementations should use secure authentication mechanisms such as:

* IAM roles
* AWS CLI profiles
* OIDC
* Web identity
* Short-lived credentials
* CI/CD federation

### Q15. Should production modules always use the latest version?

**Answer:**
No.

Production infrastructure should use deliberate version constraints and controlled upgrades.

### Q16. What is `terraform init -upgrade`?

**Answer:**
It tells Terraform to reconsider and upgrade already-installed dependencies, including modules, within their configured constraints.

### Q17. Can a child module call another child module?

**Answer:**
Yes.

Terraform supports nested modules:

```text
Root Module
    |
    +---- Network Module
    |         |
    |         +---- Security Module
    |
    +---- Compute Module
```

### Q18. Why are outputs important in modules?

**Answer:**
Outputs provide a controlled interface through which the calling module can consume values generated by the child module.

### Q19. Why should we pin module versions?

**Answer:**
To prevent unexpected module changes from silently affecting infrastructure.

For example:

```hcl
version = "1.2.0"
```

provides much more predictable behavior than relying on an unconstrained latest release.

### Q20. What is the difference between a Terraform module and a resource?

**Answer:**

A resource represents an individual infrastructure object:

```hcl
resource "aws_instance" "this" {
  ...
}
```

A module is a reusable collection of Terraform configuration that may contain multiple resources:

```text
EC2 Module
├── EC2
├── Security Group
├── IAM
└── CloudWatch
```
