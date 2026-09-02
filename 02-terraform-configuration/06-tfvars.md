
## Terraform Variable Definition Files (`.tfvars`)

> **File:** `06-tfvars.md`

## Table of Contents

1. [Introduction](#1-introduction)
2. [What Is a `.tfvars` File?](#2-what-is-a-tfvars-file)
3. [Why Use `.tfvars` Files?](#3-why-use-tfvars-files)
4. [Creating a `.tfvars` File](#4-creating-a-tfvars-file)
5. [Using `terraform.tfvars`](#5-using-terraformtfvars)
6. [Using `.auto.tfvars` Files](#6-using-auto-tfvars-files)
7. [Using `.tfvars.json` Files](#7-using-tfvarsjson-files)
8. [Explicit Variable Files with `-var-file`](#8-explicit-variable-files-with--var-file)
9. [Variable Precedence](#9-variable-precedence)
10. [Environment-Specific Configuration](#10-environment-specific-configuration)
11. [Sensitive Values and Security](#11-sensitive-values-and-security)
12. [Practical Example](#12-practical-example)
13. [Validating and Testing Variable Values](#13-validating-and-testing-variable-values)
14. [Common Mistakes and Troubleshooting](#14-common-mistakes-and-troubleshooting)
15. [Best Practices](#15-best-practices)
16. [Interview Questions](#16-interview-questions)
17. [Summary](#17-summary)

## 1. Introduction

In the previous section, we learned how to define Terraform variables.

For example:

```hcl
variable "environment" {
  type    = string
  default = "dev"
}
```

The variable declaration defines the **input interface**, but we still need a way to provide values to that interface.

Terraform provides several ways to supply variable values.

One of the most commonly used methods is a **variable definition file**, commonly called a `.tfvars` file.

For example:

```text
terraform.tfvars
```

can contain:

```hcl
environment   = "dev"
instance_type = "t3.micro"
aws_region    = "us-east-1"
```

The Terraform configuration remains unchanged while the input values can vary.

This creates a useful separation:

```text
Terraform Configuration
          │
          │ Defines infrastructure logic
          ▼
      Variables
          │
          │ Receives input values
          ▼
      .tfvars
          │
          │ Environment-specific values
          ▼
    Infrastructure
```

### Learning Objectives

By the end of this section, we will understand:

* What `.tfvars` files are.
* Why variable definition files are useful.
* How `terraform.tfvars` works.
* How `.auto.tfvars` files work.
* How `.tfvars.json` files work.
* How to explicitly load a variable file.
* Terraform variable precedence.
* How to organize environment-specific values.
* How to handle sensitive values safely.
* Common `.tfvars` mistakes.
* Best practices for GitHub and CI/CD environments.

## 2. What Is a `.tfvars` File?

A `.tfvars` file is a **Terraform variable definition file** used to assign values to input variables.

Suppose we define:

```hcl
variable "instance_type" {
  type = string
}
```

We can provide the value in a `.tfvars` file:

```hcl
instance_type = "t3.micro"
```

The relationship is:

```text
variables.tf
     │
     │ Declares
     ▼
instance_type
     ▲
     │ Receives value
     │
terraform.tfvars
```

### Example

`variables.tf`:

```hcl
variable "environment" {
  type = string
}
```

`terraform.tfvars`:

```hcl
environment = "dev"
```

Terraform combines these during configuration evaluation.

The variable declaration defines what the input is.

The `.tfvars` file provides the value.

## 3. Why Use `.tfvars` Files?

Without variable definition files, values may need to be supplied directly through command-line arguments:

```bash
terraform plan -var="environment=dev"
```

This can become difficult to manage when many variables are involved.

Instead, we can create:

```text
terraform.tfvars
```

with:

```hcl
environment   = "dev"
instance_type = "t3.micro"
aws_region    = "us-east-1"
```

Then Terraform can load the values according to its variable-loading rules.

### Benefits

`.tfvars` files provide:

* Cleaner command execution.
* Separation of code and configuration.
* Easier environment management.
* Better readability.
* Easier local development.
* Easier configuration of multiple variables.
* Better organization for repeatable deployments.

## 4. Creating a `.tfvars` File

Suppose we have these variables:

```hcl
variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "instance_type" {
  type = string
}
```

We can create:

```text
terraform.tfvars
```

with:

```hcl
project_name  = "terraform-demo"
environment   = "dev"
instance_type = "t3.micro"
```

Terraform associates the assignments with variables having the same names.

```text
project_name
      │
      └── "terraform-demo"

environment
      │
      └── "dev"

instance_type
      │
      └── "t3.micro"
```

### Important

A `.tfvars` file contains **values**, not variable declarations.

Do not write:

```hcl
variable "environment" {
  type = string
  default = "dev"
}
```

inside a `.tfvars` file.

Instead, write:

```hcl
environment = "dev"
```

The declaration belongs in a `.tf` file such as:

```text
variables.tf
```

## 5. Using `terraform.tfvars`

`terraform.tfvars` is a special conventional filename.

Terraform automatically loads it when evaluating variable values.

Example project:

```text
variables-demo/
├── main.tf
├── variables.tf
├── providers.tf
└── terraform.tfvars
```

### `variables.tf`

```hcl
variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}
```

### `terraform.tfvars`

```hcl
environment   = "staging"
instance_type = "t3.small"
```

Terraform uses the values supplied by the variable file instead of the defaults.

The resulting values are:

```text
environment   = staging
instance_type = t3.small
```

### 5.1 Why Is `terraform.tfvars` Useful?

It is convenient for local development and simple projects.

For example:

```text
Terraform Code
│
├── main.tf
├── variables.tf
├── providers.tf
│
└── terraform.tfvars
       │
       ├── region
       ├── instance type
       └── environment
```

The infrastructure code can remain unchanged while the input values change.

### 5.2 Should `terraform.tfvars` Be Committed?

It depends on its contents.

If it contains only safe, non-sensitive configuration, committing it can be acceptable.

However, in many projects `terraform.tfvars` contains environment-specific values or sensitive information.

A safer repository pattern is:

```text
terraform.tfvars.example
```

for a shareable template, while:

```text
terraform.tfvars
```

is kept local and ignored when appropriate.

For example:

```gitignore
*.tfvars
!*.tfvars.example
```

This is a common pattern, but the exact repository policy should match the project's requirements.

## 6. Using `.auto.tfvars` Files

Terraform also automatically loads variable files whose names end with:

```text
.auto.tfvars
```

or:

```text
.auto.tfvars.json
```

For example:

```text
dev.auto.tfvars
```

could contain:

```hcl
environment   = "dev"
instance_type = "t3.micro"
```

Terraform automatically considers matching `.auto.tfvars` files without requiring:

```bash
-var-file
```

### 6.1 Why Use `.auto.tfvars`?

They can be useful when we want variable files to be automatically loaded while using descriptive filenames.

For example:

```text
terraform/
├── main.tf
├── variables.tf
├── dev.auto.tfvars
└── common.auto.tfvars
```

However, automatic loading should be used carefully when multiple files define the same variables.

### 6.2 Naming Convention

Examples:

```text
dev.auto.tfvars
staging.auto.tfvars
prod.auto.tfvars
```

can be intuitive names.

However, if we need to explicitly choose one environment at execution time, using `-var-file` is often clearer:

```bash
terraform plan -var-file="dev.tfvars"
```

This makes the selected environment explicit.

## 7. Using `.tfvars.json` Files

Terraform also supports JSON-formatted variable definition files.

For example:

```text
terraform.tfvars.json
```

can contain:

```json
{
  "environment": "dev",
  "instance_type": "t3.micro",
  "aws_region": "us-east-1"
}
```

This provides the same concept as an HCL-based `.tfvars` file, but uses JSON syntax.

### HCL `.tfvars`

```hcl
environment   = "dev"
instance_type = "t3.micro"
```

### JSON `.tfvars.json`

```json
{
  "environment": "dev",
  "instance_type": "t3.micro"
}
```

HCL is generally easier for humans to read and maintain, while JSON can be useful when variable files are generated or managed by other tools.

## 8. Explicit Variable Files with `-var-file`

We can explicitly specify a variable file using:

```bash
terraform plan -var-file="dev.tfvars"
```

For example:

```text
project/
├── main.tf
├── variables.tf
├── dev.tfvars
├── staging.tfvars
└── prod.tfvars
```

### Development

```bash
terraform plan -var-file="dev.tfvars"
```

### Staging

```bash
terraform plan -var-file="staging.tfvars"
```

### Production

```bash
terraform plan -var-file="prod.tfvars"
```

This provides an explicit environment-selection mechanism.

### 8.1 Example Environment Files

`dev.tfvars`:

```hcl
environment   = "dev"
instance_type = "t3.micro"
```

`staging.tfvars`:

```hcl
environment   = "staging"
instance_type = "t3.small"
```

`prod.tfvars`:

```hcl
environment   = "prod"
instance_type = "t3.large"
```

The Terraform code remains the same:

```text
Terraform Code
      │
      ├── dev.tfvars
      │
      ├── staging.tfvars
      │
      └── prod.tfvars
```

### 8.2 Plan With an Environment File

Development:

```bash
terraform plan -var-file="dev.tfvars"
```

Production:

```bash
terraform plan -var-file="prod.tfvars"
```

This is especially useful in CI/CD pipelines because the selected environment can be explicit.

## 9. Variable Precedence

Terraform can receive variable values from multiple sources.

Common sources include:

1. Variable defaults.
2. Environment variables using `TF_VAR_<name>`.
3. Automatically loaded variable files.
4. Explicit variable files.
5. Command-line variable arguments.

A useful high-level model is:

```text
Variable Default
      │
      ▼
TF_VAR_* Environment Variables
      │
      ▼
Automatically Loaded Variable Files
      │
      ▼
Explicit -var-file Arguments
      │
      ▼
-var Arguments
```

Higher-precedence values override lower-precedence values when the same variable is assigned more than once.

### Example

Variable declaration:

```hcl
variable "environment" {
  type    = string
  default = "dev"
}
```

`terraform.tfvars`:

```hcl
environment = "staging"
```

Command:

```bash
terraform plan -var="environment=prod"
```

The command-line value takes precedence for that invocation:

```text
environment = prod
```

### 9.1 Why Precedence Matters

Suppose we have:

```text
Default
environment = dev

terraform.tfvars
environment = staging

CLI
environment = prod
```

Terraform needs a deterministic way to decide which value to use.

Understanding precedence helps us troubleshoot unexpected values and design predictable CI/CD workflows.

## 10. Environment-Specific Configuration

One of the most common uses of `.tfvars` files is managing environment-specific configuration.

Consider:

```text
project/
├── main.tf
├── variables.tf
├── providers.tf
├── dev.tfvars
├── staging.tfvars
└── prod.tfvars
```

The Terraform code is shared:

```text
                   Terraform Code
                         │
            ┌────────────┼────────────┐
            │            │            │
            ▼            ▼            ▼
       dev.tfvars  staging.tfvars  prod.tfvars
            │            │            │
            ▼            ▼            ▼
           Dev        Staging     Production
```

### Example

`dev.tfvars`:

```hcl
environment   = "dev"
instance_type = "t3.micro"
```

`staging.tfvars`:

```hcl
environment   = "staging"
instance_type = "t3.small"
```

`prod.tfvars`:

```hcl
environment   = "prod"
instance_type = "t3.large"
```

The resource configuration can remain unchanged:

```hcl
resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Environment = var.environment
  }
}
```

This is an important Terraform design pattern:

> Keep infrastructure logic reusable and provide environment-specific values separately.

## 11. Sensitive Values and Security

`.tfvars` files can contain sensitive values.

For example:

```hcl
database_password = "SuperSecretPassword"
```

This is dangerous if committed to Git.

### Never Commit Secrets

We should never commit:

* Passwords.
* API keys.
* Access keys.
* Secret keys.
* Tokens.
* Private credentials.
* Other sensitive authentication material.

A common pattern is:

```text
terraform.tfvars.example
```

containing safe placeholders:

```hcl
database_password = "REPLACE_WITH_SECURE_VALUE"
```

while the real value is supplied through an approved secure mechanism.

### 11.1 `.gitignore`

A project may use:

```gitignore
*.tfvars
!*.tfvars.example

.terraform/
terraform.tfstate
terraform.tfstate.*
```

This prevents typical local variable files and Terraform state files from being committed.

The exact `.gitignore` policy should be reviewed based on the project.

### 11.2 `sensitive = true`

The variable declaration can also mark a value as sensitive:

```hcl
variable "database_password" {
  description = "Database administrator password."
  type        = string
  sensitive   = true
}
```

This helps redact the value in relevant Terraform CLI output.

However:

> A sensitive variable is not automatically a secret-management solution.

The value can still be stored in Terraform state if it is used by a managed resource.

For production environments, we should use appropriate secret-management and identity mechanisms.

## 12. Practical Example

Let's build a small environment-based configuration.

### 12.1 Project Structure

```text
tfvars-demo/
├── versions.tf
├── providers.tf
├── variables.tf
├── main.tf
├── dev.tfvars
├── staging.tfvars
└── terraform.tfvars.example
```

### 12.2 Define Terraform and Provider Requirements

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

### 12.3 Configure the Provider

Create:

```text
providers.tf
```

```hcl
provider "aws" {
  region = var.aws_region
}
```

### 12.4 Define Variables

Create:

```text
variables.tf
```

```hcl
variable "aws_region" {
  description = "AWS region where the resource will be created."
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID available in the selected AWS region."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

### 12.5 Define the Resource

Create:

```text
main.tf
```

```hcl
resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name        = "tfvars-demo-instance"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

### 12.6 Create Development Variables

Create:

```text
dev.tfvars
```

```hcl
aws_region    = "us-east-1"
ami_id        = "ami-xxxxxxxxxxxxxxxxx"
instance_type = "t3.micro"
environment   = "dev"
```

Replace the AMI placeholder with a valid AMI available in the selected region.

### 12.7 Create Staging Variables

Create:

```text
staging.tfvars
```

```hcl
aws_region    = "us-east-1"
ami_id        = "ami-yyyyyyyyyyyyyyyyy"
instance_type = "t3.small"
environment   = "staging"
```

Again, the AMI ID must be valid in the selected region.

### 12.8 Create the Example File

Create:

```text
terraform.tfvars.example
```

```hcl
aws_region    = "us-east-1"
ami_id        = "ami-REPLACE_ME"
instance_type = "t3.micro"
environment   = "dev"
```

This file is safe to commit because it contains example values rather than environment-specific secrets.

### 12.9 Initialize Terraform

Run:

```bash
terraform init
```

### 12.10 Format the Configuration

Run:

```bash
terraform fmt
```

### 12.11 Validate the Configuration

Run:

```bash
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

### 12.12 Create a Development Plan

Run:

```bash
terraform plan -var-file="dev.tfvars"
```

Terraform loads:

```text
dev.tfvars
     │
     ▼
Variable Values
     │
     ▼
Terraform Configuration
     │
     ▼
Execution Plan
```

Review the plan carefully.

### 12.13 Create a Staging Plan

Run:

```bash
terraform plan -var-file="staging.tfvars"
```

The same Terraform code now receives different values.

### 12.14 Apply Development Configuration

Run:

```bash
terraform apply -var-file="dev.tfvars"
```

Review the proposed changes and confirm the operation.

### 12.15 Clean Up

When the lab is complete:

```bash
terraform destroy -var-file="dev.tfvars"
```

Review and confirm the deletion.

If staging infrastructure was also created:

```bash
terraform destroy -var-file="staging.tfvars"
```

## 13. Validating and Testing Variable Values

A professional workflow should validate both the Terraform configuration and the supplied variable values.

### Recommended Flow

```text
              Terraform Code
                    │
                    ▼
             Variable Definitions
                    │
                    ▼
              Environment File
                    │
                    ▼
              terraform fmt
                    │
                    ▼
            terraform validate
                    │
                    ▼
         terraform plan -var-file
                    │
                    ▼
              Review Changes
                    │
                    ▼
              terraform apply
```

### Commands

Format:

```bash
terraform fmt
```

Validate:

```bash
terraform validate
```

Plan:

```bash
terraform plan -var-file="dev.tfvars"
```

Apply:

```bash
terraform apply -var-file="dev.tfvars"
```

Destroy:

```bash
terraform destroy -var-file="dev.tfvars"
```

### 13.1 Validate the Actual Values

A successful `terraform validate` does not necessarily mean that all environment-specific values are operationally correct.

For example:

```hcl
ami_id = "ami-invalid"
```

may satisfy:

```hcl
type = string
```

but still fail when Terraform attempts to use it with AWS.

Therefore, we should always review:

```bash
terraform plan
```

and confirm that supplied values are appropriate for the selected environment and region.

## 14. Common Mistakes and Troubleshooting

### 14.1 Variable File Is Not Automatically Loaded

Suppose we create:

```text
dev.tfvars
```

and run:

```bash
terraform plan
```

Terraform does not automatically treat every arbitrary `.tfvars` filename as an automatically loaded variable file.

For an explicitly named file such as:

```text
dev.tfvars
```

use:

```bash
terraform plan -var-file="dev.tfvars"
```

By contrast, conventional automatically loaded names include:

```text
terraform.tfvars
```

and files ending in:

```text
.auto.tfvars
```

### 14.2 Incorrect Variable Name

Variable declaration:

```hcl
variable "instance_type" {
  type = string
}
```

Variable file:

```hcl
instance = "t3.micro"
```

These names do not match.

Correct:

```hcl
instance_type = "t3.micro"
```

### 14.3 Incorrect Data Type

Variable:

```hcl
variable "instance_count" {
  type = number
}
```

Incorrect:

```hcl
instance_count = "3"
```

Correct:

```hcl
instance_count = 3
```

### 14.4 Invalid Environment Value

Suppose the variable contains:

```hcl
validation {
  condition     = contains(["dev", "staging", "prod"], var.environment)
  error_message = "Environment must be dev, staging, or prod."
}
```

Then:

```hcl
environment = "test"
```

will fail validation.

Use one of:

```text
dev
staging
prod
```

### 14.5 Wrong Region and AMI Combination

Example:

```hcl
aws_region = "us-west-2"
ami_id     = "ami-xxxxxxxxxxxxxxxxx"
```

If the AMI does not exist in `us-west-2`, resource creation can fail.

We must ensure region-specific values match the selected region.

### 14.6 Accidentally Loading Multiple Variable Files

If multiple automatically loaded files assign the same variable, the final value depends on Terraform's variable-loading rules and file ordering.

For example:

```text
dev.auto.tfvars
prod.auto.tfvars
```

both define:

```hcl
environment = ...
```

This is confusing and potentially dangerous.

Do not place mutually exclusive environment configurations together as automatically loaded files.

Instead, use explicit environment files:

```bash
terraform plan -var-file="dev.tfvars"
```

or:

```bash
terraform plan -var-file="prod.tfvars"
```

### 14.7 Committing Sensitive `.tfvars` Files

A file such as:

```text
production.tfvars
```

may contain credentials or other sensitive values.

Before committing variable files, review their contents.

If they contain secrets:

```text
Do not commit them.
```

Rotate any credentials that have already been exposed.

### 14.8 Confusing `.tfvars` With `.tf`

A `.tf` file defines Terraform configuration.

Example:

```hcl
variable "environment" {
  type = string
}
```

A `.tfvars` file provides values:

```hcl
environment = "dev"
```

Think of them as:

```text
.tf
│
└── Defines

.tfvars
│
└── Supplies values
```

## 15. Best Practices

### 15.1 Keep Variable Definitions in `.tf` Files

For example:

```text
variables.tf
```

should contain:

```hcl
variable "environment" {
  type = string
}
```

while variable values belong in:

```text
*.tfvars
```

or another appropriate input mechanism.

### 15.2 Use `terraform.tfvars` Carefully

`terraform.tfvars` is convenient for local development.

For repositories shared by multiple environments, explicit environment files can be clearer:

```text
dev.tfvars
staging.tfvars
prod.tfvars
```

and selected explicitly:

```bash
terraform plan -var-file="dev.tfvars"
```

### 15.3 Prefer Explicit Environment Selection in Automation

For CI/CD, an explicit command such as:

```bash
terraform plan -var-file="prod.tfvars"
```

makes the selected environment visible.

In larger systems, environment values may instead come from CI/CD variables, secure secret stores, workspaces, HCP Terraform, or another approved configuration mechanism.

### 15.4 Use `.tfvars.example`

A professional repository can provide:

```text
terraform.tfvars.example
```

as a template.

Example:

```hcl
aws_region    = "us-east-1"
ami_id        = "ami-REPLACE_ME"
instance_type = "t3.micro"
environment   = "dev"
```

This helps another engineer understand the required inputs without exposing real values.

### 15.5 Do Not Store Secrets in Git

Keep secrets outside source control.

A `.tfvars` file should not become a convenient place to permanently store credentials.

For production environments, use approved authentication and secret-management mechanisms.

### 15.6 Keep Environment Files Consistent

If we use:

```text
dev.tfvars
staging.tfvars
prod.tfvars
```

they should generally provide the same expected variable interface.

For example:

```text
dev.tfvars
├── aws_region
├── ami_id
├── instance_type
└── environment

staging.tfvars
├── aws_region
├── ami_id
├── instance_type
└── environment

prod.tfvars
├── aws_region
├── ami_id
├── instance_type
└── environment
```

This makes environment switching predictable.

### 15.7 Avoid Duplicate Automatically Loaded Environment Files

Do not keep:

```text
dev.auto.tfvars
prod.auto.tfvars
```

in the same working directory if they represent mutually exclusive environments.

Use explicit files instead:

```text
dev.tfvars
prod.tfvars
```

and select the desired file explicitly.

### 15.8 Review `.gitignore`

A common starting point is:

```gitignore
.terraform/

*.tfstate
*.tfstate.*
*.tfvars
!*.tfvars.example
```

The exact rules should be reviewed for the repository's needs.

The provider lock file should generally remain tracked:

```text
.terraform.lock.hcl
```

### 15.9 Treat `.tfvars` as Input, Not Business Logic

Avoid putting complex Terraform logic into variable files.

A `.tfvars` file should primarily provide values:

```hcl
environment   = "prod"
instance_type = "t3.large"
```

The infrastructure logic should remain in Terraform configuration:

```text
main.tf
variables.tf
locals.tf
modules/
```

This keeps responsibilities clear.

## 16. Interview Questions

### Q1. What is a `.tfvars` file?

**Answer:**

A `.tfvars` file is a Terraform variable definition file used to assign values to input variables.

Example:

```hcl
environment   = "dev"
instance_type = "t3.micro"
```

### Q2. What is the difference between `variables.tf` and `terraform.tfvars`?

**Answer:**

`variables.tf` declares variables.

Example:

```hcl
variable "environment" {
  type = string
}
```

`terraform.tfvars` provides values:

```hcl
environment = "dev"
```

In simple terms:

```text
variables.tf
└── Defines the input

terraform.tfvars
└── Supplies the input value
```

### Q3. Is every `.tfvars` file automatically loaded by Terraform?

**Answer:**

No.

Terraform automatically loads certain conventional filenames, including:

```text
terraform.tfvars
terraform.tfvars.json
*.auto.tfvars
*.auto.tfvars.json
```

An arbitrary file such as:

```text
dev.tfvars
```

should be explicitly provided using:

```bash
terraform plan -var-file="dev.tfvars"
```

### Q4. What is `-var-file`?

**Answer:**

`-var-file` explicitly tells Terraform which variable definition file to use.

Example:

```bash
terraform plan -var-file="prod.tfvars"
```

This is useful for explicit environment selection.

### Q5. What is the difference between `.tfvars` and `.tfvars.json`?

**Answer:**

Both provide Terraform variable values.

`.tfvars` uses Terraform's HCL syntax:

```hcl
environment = "dev"
```

`.tfvars.json` uses JSON:

```json
{
  "environment": "dev"
}
```

### Q6. What is an `.auto.tfvars` file?

**Answer:**

An `.auto.tfvars` file is automatically loaded by Terraform because its filename follows Terraform's automatic variable-file naming convention.

Example:

```text
dev.auto.tfvars
```

### Q7. Why are `.tfvars` files commonly used for multiple environments?

**Answer:**

They allow us to keep the same Terraform infrastructure code while providing different input values.

For example:

```text
dev.tfvars
    │
    └── t3.micro

prod.tfvars
    │
    └── t3.large
```

The Terraform resource configuration remains reusable.

### Q8. Should `.tfvars` files be committed to Git?

**Answer:**

It depends on their contents.

If a file contains only safe, non-sensitive configuration, committing it may be acceptable.

However, many projects keep environment-specific `.tfvars` files out of Git and commit only:

```text
terraform.tfvars.example
```

Sensitive values should not be committed.

### Q9. Does `sensitive = true` prevent a value from being stored in Terraform state?

**Answer:**

No.

It primarily controls how Terraform treats the value in relevant CLI output.

A sensitive value can still be stored in Terraform state when required by a managed resource.

### Q10. Why would we use `dev.tfvars` instead of `dev.auto.tfvars`?

**Answer:**

`dev.tfvars` can be explicitly selected:

```bash
terraform plan -var-file="dev.tfvars"
```

This makes environment selection clear and avoids accidentally loading multiple mutually exclusive environment files.

### Q11. What happens if the same variable is defined in multiple places?

**Answer:**

Terraform uses its variable precedence rules to determine which value takes effect.

Higher-precedence inputs override lower-precedence inputs.

This is why we should avoid unnecessary duplicate definitions and design variable inputs deliberately.

## 17. Summary

`.tfvars` files provide a clean way to supply values to Terraform input variables.

The basic relationship is:

```text
variables.tf
     │
     │ Variable declaration
     ▼
Variable
     ▲
     │ Variable value
     │
terraform.tfvars
```

For multiple environments:

```text
                   Terraform Code
                         │
            ┌────────────┼────────────┐
            │            │            │
            ▼            ▼            ▼
       dev.tfvars  staging.tfvars  prod.tfvars
            │            │            │
            ▼            ▼            ▼
           Dev        Staging     Production
```

### Important Commands

Automatically loaded conventional file:

```bash
terraform plan
```

Explicit variable file:

```bash
terraform plan -var-file="dev.tfvars"
```

Apply:

```bash
terraform apply -var-file="dev.tfvars"
```

Destroy:

```bash
terraform destroy -var-file="dev.tfvars"
```

### What We Learned

* `.tfvars` files provide values for Terraform input variables.
* Variable declarations belong in `.tf` files.
* `terraform.tfvars` is automatically loaded.
* `*.auto.tfvars` files are automatically loaded.
* Arbitrary `.tfvars` files can be selected using `-var-file`.
* `.tfvars.json` provides the same concept using JSON syntax.
* Environment-specific files can keep infrastructure code reusable.
* Variable precedence determines which value wins when inputs overlap.
* Sensitive values should not be committed to Git.
* `sensitive = true` does not remove values from Terraform state.
* `terraform.tfvars.example` is useful as a safe repository template.
* Mutually exclusive environments should not be placed in simultaneously auto-loaded variable files.
* CI/CD pipelines should make environment selection explicit and secure.

### Key Takeaway

> `.tfvars` files separate variable values from Terraform infrastructure code, making it easier to reuse the same configuration across different environments while keeping environment-specific inputs organized.

### Next Section

Next, we will learn about **Terraform Conditional Expressions** and how to make resource configuration behave differently based on variable values and other conditions.
