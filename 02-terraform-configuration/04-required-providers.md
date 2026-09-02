
## Terraform Required Providers

> **File:** `04-required-providers.md`

## Table of Contents

1. [Introduction](#1-introduction)
2. [What Is a Provider Dependency?](#2-what-is-a-provider-dependency)
3. [The `required_providers` Block](#3-the-required_providers-block)
4. [Provider Source Address](#4-provider-source-address)
5. [Provider Version Constraints](#5-provider-version-constraints)
6. [Terraform Version vs Provider Version](#6-terraform-version-vs-provider-version)
7. [Provider Requirement vs Provider Configuration](#7-provider-requirement-vs-provider-configuration)
8. [Practical Example](#8-practical-example)
9. [The `.terraform.lock.hcl` File](#9-the-terraformlockhcl-file)
10. [Validating Provider Requirements](#10-validating-provider-requirements)
11. [Common Mistakes and Troubleshooting](#11-common-mistakes-and-troubleshooting)
12. [Best Practices](#12-best-practices)
13. [Interview Questions](#13-interview-questions)
14. [Summary](#14-summary)

## 1. Introduction

Terraform uses **providers** to communicate with external platforms and services.

Examples include:

* AWS
* Azure
* Google Cloud
* Kubernetes
* GitHub
* Cloudflare
* Databases
* SaaS platforms

Before Terraform can use a provider, we should declare the provider as a dependency in the Terraform configuration.

This is done using the:

```hcl
terraform {
  required_providers {
    ...
  }
}
```

block.

The `required_providers` block tells Terraform:

> **Which provider we depend on, where that provider comes from, and which versions are acceptable.**

For example:

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

This does not configure the AWS provider's region or credentials.

It only declares the AWS provider dependency.

The actual provider configuration is defined separately:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

Understanding this distinction is important because provider **requirements** and provider **configuration** solve different problems.

## 2. What Is a Provider Dependency?

A provider dependency is a declaration that our Terraform configuration requires a particular provider plugin.

For example:

```hcl
required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 6.0"
  }
}
```

This tells Terraform:

```text
Terraform Configuration
        │
        ▼
Required Provider
        │
        ├── Local name: aws
        ├── Source: hashicorp/aws
        └── Version: ~> 6.0
                │
                ▼
          AWS Provider Plugin
```

Terraform can then download and initialize the appropriate provider during:

```bash
terraform init
```

### Why Is This Necessary?

Without a provider, Terraform does not know how to communicate with the target platform.

For example:

```text
Terraform
   │
   ├── AWS Provider ───────► AWS APIs
   │
   ├── Azure Provider ─────► Azure APIs
   │
   └── GitHub Provider ────► GitHub APIs
```

The provider acts as the integration layer between Terraform and the external platform.

## 3. The `required_providers` Block

The recommended modern syntax is:

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

Let's break it down.

### 3.1 `terraform` Block

The outer block is:

```hcl
terraform {
}
```

It contains Terraform-level configuration.

Examples include:

* Terraform CLI version requirements.
* Provider requirements.
* Backend configuration.
* Other Terraform settings.

### 3.2 `required_providers`

Inside the `terraform` block:

```hcl
required_providers {
}
```

declares the provider dependencies required by the module.

Example:

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

### 3.3 Local Provider Name

In:

```hcl
aws = {
  source  = "hashicorp/aws"
  version = "~> 6.0"
}
```

`aws` is the **local name** used by the Terraform configuration.

We reference the provider using:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

and resources use:

```hcl
resource "aws_instance" "example" {
  ...
}
```

The local name is not necessarily the provider's full source address.

## 4. Provider Source Address

The `source` argument identifies where Terraform obtains the provider.

Example:

```hcl
source = "hashicorp/aws"
```

A provider source address follows the general structure:

```text
hostname/namespace/type
```

For example:

```text
registry.terraform.io/hashicorp/aws
```

can be represented in configuration using the shorter form:

```text
hashicorp/aws
```

Terraform interprets this as a provider from the public Terraform Registry.

### Example

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
```

The important components are:

```text
hashicorp/aws
│        │
│        └── Provider type
│
└────────── Namespace
```

The source address allows Terraform to distinguish providers that may have similar local names.

### 4.1 Why Is `source` Important?

Consider:

```hcl
aws = {
  source = "hashicorp/aws"
}
```

Terraform knows that the required provider is the AWS provider published under the HashiCorp namespace.

Without an explicit source, modern Terraform configurations can become ambiguous, especially when working with providers outside the standard namespace.

Therefore, professional Terraform configurations should explicitly declare provider sources.

## 5. Provider Version Constraints

The `version` argument specifies which provider versions Terraform is allowed to select.

Example:

```hcl
version = "~> 6.0"
```

This means Terraform can select compatible versions in the `6.x` series, while excluding `7.x`.

For example:

```text
6.0.x
6.1.x
6.10.x
6.99.x
```

can satisfy:

```text
~> 6.0
```

while:

```text
7.0.0
```

does not.

### 5.1 Common Version Constraint Operators

Terraform supports several version constraint styles.

#### Exact Version

```hcl
version = "= 6.0.0"
```

Only version `6.0.0` is accepted.

This provides strict control but can make upgrades more difficult.

#### Greater Than or Equal

```hcl
version = ">= 6.0"
```

Allows version `6.0` or newer, subject to other constraints.

This provides flexibility but may permit major-version upgrades that introduce breaking changes.

#### Less Than

```hcl
version = "< 7.0"
```

Allows versions below `7.0`.

#### Compatible Version

```hcl
version = "~> 6.0"
```

Allows compatible `6.x` versions but prevents Terraform from selecting `7.x`.

This is a common practical approach for provider dependencies.

### 5.2 Combining Constraints

Multiple constraints can be combined.

For example:

```hcl
version = ">= 6.0, < 7.0"
```

means:

```text
6.0 and newer
        │
        ▼
      < 7.0
```

This allows the 6.x series while preventing a 7.x major-version upgrade.

## 6. Terraform Version vs Provider Version

These are two different version constraints.

### Terraform Version

Example:

```hcl
terraform {
  required_version = "~> 1.15.0"
}
```

This controls the **Terraform CLI version**.

### Provider Version

Example:

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

This controls the **AWS provider version**.

### Comparison

```text
terraform {
│
├── required_version
│       │
│       └── Terraform CLI version
│
└── required_providers
        │
        └── Provider version
}
```

For example:

```hcl
terraform {
  required_version = "~> 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
```

This means:

```text
Terraform CLI
└── 1.15.x

AWS Provider
└── 6.x
```

These constraints are independent.

## 7. Provider Requirement vs Provider Configuration

This distinction is one of the most important concepts in Terraform.

### Provider Requirement

The provider requirement tells Terraform:

> Which provider plugin do we need?

Example:

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

### Provider Configuration

The provider configuration tells Terraform:

> **How should we configure and use that provider?**

Example:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

### Side-by-Side Comparison

| Configuration        | Purpose                                      |
| -------------------- | -------------------------------------------- |
| `required_providers` | Declares provider dependency                 |
| `source`             | Identifies provider source                   |
| `version`            | Defines acceptable provider versions         |
| `provider` block     | Configures provider behavior                 |
| `region`             | Configures AWS region                        |
| `alias`              | Creates an additional provider configuration |

A useful mental model is:

```text
required_providers
        │
        │ "Which provider do we need?"
        ▼
Provider Plugin
        │
        │
provider block
        │
        │ "How do we configure it?"
        ▼
Provider Configuration
        │
        ▼
Resources
```

## 8. Practical Example

Let's create a simple AWS configuration that demonstrates Terraform and provider version requirements.

### 8.1 Project Structure

```text
required-providers-demo/
├── versions.tf
├── providers.tf
└── main.tf
```

### 8.2 Define Requirements

Create:

```text
versions.tf
```

```hcl
terraform {
  required_version = "~> 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
```

This declares:

```text
Terraform CLI
└── 1.15.x

AWS Provider
└── 6.x
```

### 8.3 Configure the Provider

Create:

```text
providers.tf
```

```hcl
provider "aws" {
  region = "us-east-1"
}
```

The provider requirement and provider configuration are intentionally separated.

### 8.4 Define a Resource

Create:

```text
main.tf
```

```hcl
resource "aws_s3_bucket" "example" {
  bucket_prefix = "terraform-required-providers-"

  tags = {
    Name      = "terraform-required-providers-demo"
    ManagedBy = "Terraform"
  }
}
```

The configuration now follows this flow:

```text
versions.tf
    │
    ├── Terraform version
    └── AWS provider requirement
             │
             ▼
providers.tf
    │
    └── AWS region
             │
             ▼
main.tf
    │
    └── AWS S3 bucket
```

### 8.5 Initialize Terraform

Run:

```bash
terraform init
```

During initialization, Terraform:

1. Reads the configuration.
2. Identifies required providers.
3. Determines acceptable provider versions.
4. Downloads the selected provider.
5. Creates or updates `.terraform.lock.hcl`.

### 8.6 Verify the Configuration

Run:

```bash
terraform fmt
```

Then:

```bash
terraform validate
```

Then:

```bash
terraform plan
```

If the configuration is correct, Terraform should produce a plan showing the S3 bucket that would be created.

### 8.7 Apply the Configuration

Run:

```bash
terraform apply
```

Review the plan and confirm the operation.

### 8.8 Clean Up

After completing the exercise:

```bash
terraform destroy
```

Review the proposed deletion and confirm the operation.

## 9. The `.terraform.lock.hcl` File

When Terraform initializes providers, it creates or updates:

```text
.terraform.lock.hcl
```

This file records the selected provider versions and checksums.

Example project structure after initialization:

```text
required-providers-demo/
├── .terraform/
├── .terraform.lock.hcl
├── versions.tf
├── providers.tf
└── main.tf
```

### Why Is the Lock File Important?

The version constraint says:

> "These provider versions are acceptable."

The lock file records:

> "This is the provider version and package information currently selected for this configuration."

This helps different environments use consistent provider selections.

### 9.1 Should We Commit `.terraform.lock.hcl`?

For a normal Terraform configuration, yes.

It should generally be committed to version control.

Example:

```text
Git Repository
│
├── versions.tf
├── providers.tf
├── main.tf
└── .terraform.lock.hcl
```

The lock file is not a secret and is intended to be shared with other users and automation systems.

### 9.2 Should We Commit `.terraform/`?

No.

The `.terraform/` directory contains Terraform's working directory data, including downloaded provider packages and other local information.

It should normally be excluded using `.gitignore`.

Example:

```gitignore
.terraform/
```

## 10. Validating Provider Requirements

A professional workflow should verify provider requirements before applying infrastructure.

### 10.1 Initialize

```bash
terraform init
```

### 10.2 Inspect Providers

Run:

```bash
terraform providers
```

This command helps us inspect the providers required by the configuration.

### 10.3 Format

```bash
terraform fmt
```

### 10.4 Validate

```bash
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

### 10.5 Review the Plan

```bash
terraform plan
```

The plan helps us confirm that Terraform can resolve and use the declared provider configuration successfully.

## 11. Common Mistakes and Troubleshooting

### 11.1 Using an Invalid Provider Source

Incorrect:

```hcl
required_providers {
  aws = {
    source = "aws"
  }
}
```

A professional configuration should use the provider's source address:

```hcl
required_providers {
  aws = {
    source = "hashicorp/aws"
  }
}
```

### 11.2 Confusing `required_providers` With `provider`

Incorrect assumption:

```hcl
required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 6.0"
  }
}
```

means AWS is configured for a specific region.

It does not.

We still need:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

The first block declares the dependency.

The second configures the provider.

### 11.3 Confusing Terraform Version With Provider Version

This:

```hcl
required_version = "~> 1.15.0"
```

controls Terraform.

This:

```hcl
version = "~> 6.0"
```

inside `required_providers` controls the AWS provider.

They are different version constraints.

### 11.4 Using an Overly Broad Provider Constraint

For example:

```hcl
version = ">= 1.0"
```

may allow versions that introduce breaking changes later.

For production projects, we should define a deliberate compatibility range.

For example:

```hcl
version = "~> 6.0"
```

or:

```hcl
version = ">= 6.0, < 7.0"
```

The appropriate constraint depends on the project's upgrade strategy.

### 11.5 Deleting `.terraform.lock.hcl` Unnecessarily

Deleting the lock file can cause Terraform to select a different acceptable provider version during a future initialization.

If the goal is simply to initialize the project on another machine, we normally keep the lock file.

If provider upgrades are intentional, use Terraform's provider upgrade workflow rather than deleting the file as a routine step.

### 11.6 Committing `.terraform/`

Avoid committing:

```text
.terraform/
```

The directory is generated locally and should normally be ignored.

## 12. Best Practices

### 12.1 Declare Provider Sources Explicitly

Prefer:

```hcl
required_providers {
  aws = {
    source = "hashicorp/aws"
  }
}
```

This makes provider dependencies clear and unambiguous.

### 12.2 Use Deliberate Version Constraints

Avoid blindly using the newest version or an unnecessarily broad constraint.

For example:

```hcl
version = "~> 6.0"
```

provides a controlled compatibility boundary.

### 12.3 Commit `.terraform.lock.hcl`

The lock file should generally be committed to Git.

This helps maintain consistent provider selections across:

* Developer machines.
* CI/CD pipelines.
* Automation environments.
* Team members.

### 12.4 Keep Generated Files Out of Git

Normally ignore:

```text
.terraform/
terraform.tfstate
terraform.tfstate.*
```

and potentially sensitive variable files such as:

```text
*.tfvars
```

while explicitly allowing an example file:

```text
!*.tfvars.example
```

A professional repository should also avoid committing credentials or other secrets.

### 12.5 Separate Requirements From Configuration

A clean structure is:

```text
versions.tf
    │
    └── Terraform and provider requirements

providers.tf
    │
    └── Provider configurations

variables.tf
    │
    └── Input variables

main.tf
    │
    └── Resources
```

The exact file names are organizational choices; Terraform evaluates all applicable `.tf` files in the root module together.

### 12.6 Review Provider Changes

Before upgrading a provider version:

1. Review the provider changelog and upgrade guidance.
2. Update the version constraint if required.
3. Run Terraform initialization with the intended upgrade.
4. Review the resulting lock-file changes.
5. Run formatting and validation.
6. Review `terraform plan`.
7. Test in an appropriate environment before production rollout.

### 12.7 Avoid Hardcoding Credentials

Provider requirements should never contain credentials.

Avoid:

```hcl
provider "aws" {
  access_key = "..."
  secret_key = "..."
}
```

Instead, use appropriate AWS authentication mechanisms such as:

* AWS CLI configuration.
* Environment variables.
* IAM roles.
* Workload identity mechanisms.
* CI/CD identity integration.
* Other organization-approved authentication methods.

Authentication should be handled separately from provider dependency declarations.

## 13. Interview Questions

### Q1. What is `required_providers` in Terraform?

**Answer:**

`required_providers` declares the provider dependencies required by a Terraform module.

It specifies information such as:

* Local provider name.
* Provider source.
* Acceptable provider versions.

Example:

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

### Q2. What is the difference between `required_providers` and the `provider` block?

**Answer:**

`required_providers` declares **which provider plugin Terraform needs**.

The `provider` block configures **how Terraform should use that provider**.

Example:

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

declares the dependency.

While:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

configures the AWS provider.

### Q3. What is the purpose of the `source` argument?

**Answer:**

The `source` argument identifies the provider's source address.

For example:

```hcl
source = "hashicorp/aws"
```

identifies the AWS provider from the HashiCorp namespace.

### Q4. What does `~> 6.0` mean?

**Answer:**

It is a compatible version constraint that allows provider versions in the `6.x` series while excluding `7.x`.

For example:

```hcl
version = "~> 6.0"
```

allows compatible 6.x releases but not a 7.x major release.

### Q5. What is the difference between `required_version` and provider `version`?

**Answer:**

`required_version` controls the Terraform CLI version.

For example:

```hcl
required_version = "~> 1.15.0"
```

The provider `version` controls the acceptable version of a provider plugin:

```hcl
version = "~> 6.0"
```

Therefore:

```text
required_version
        │
        └── Terraform CLI

required_providers.version
        │
        └── Provider plugin
```

### Q6. What is `.terraform.lock.hcl`?

**Answer:**

`.terraform.lock.hcl` records the selected provider versions and checksums for a Terraform configuration.

It helps Terraform consistently select verified provider packages across environments.

The file should generally be committed to version control.

### Q7. Should `.terraform.lock.hcl` be committed to Git?

**Answer:**

Yes.

For normal Terraform projects, it should generally be committed so that the team and CI/CD systems share the same provider selections and checksums.

### Q8. Should the `.terraform` directory be committed?

**Answer:**

No.

The `.terraform` directory is a local Terraform working directory and should normally be included in `.gitignore`.

### Q9. Does `required_providers` configure the AWS region?

**Answer:**

No.

For example:

```hcl
required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 6.0"
  }
}
```

only declares the AWS provider dependency.

The region is configured separately:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

### Q10. Why should we use provider version constraints?

**Answer:**

Version constraints provide control over provider compatibility.

They help prevent Terraform from unexpectedly selecting an incompatible major version and make provider upgrades more deliberate and predictable.

## 14. Summary

The `required_providers` block is the standard way to declare provider dependencies in Terraform.

A typical configuration is:

```hcl
terraform {
  required_version = "~> 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
```

The key concepts are:

```text
terraform
│
├── required_version
│      └── Terraform CLI version
│
└── required_providers
       │
       └── aws
           ├── source
           │    └── hashicorp/aws
           │
           └── version
                └── ~> 6.0
```

The provider is then configured separately:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

And resources consume that provider:

```hcl
resource "aws_s3_bucket" "example" {
  bucket_prefix = "terraform-demo-"
}
```

### What We Learned

* Providers enable Terraform to interact with external platforms.
* `required_providers` declares provider dependencies.
* `source` identifies the provider.
* `version` defines acceptable provider versions.
* `required_version` controls the Terraform CLI version.
* Provider requirements and provider configuration are different concepts.
* `.terraform.lock.hcl` records selected provider versions and checksums.
* `.terraform.lock.hcl` should generally be committed.
* `.terraform/` should normally be ignored.
* Provider versions should be constrained deliberately.
* Credentials should never be hardcoded into Terraform configuration.

### Key Takeaway

> `required_providers` tells Terraform which provider dependency we need and which versions are acceptable; the `provider` block tells Terraform how that provider should be configured and used.

### Next Section

Next, we will cover **Terraform Variables** and learn how to make Terraform configurations reusable, flexible, and easier to manage across different environments.
