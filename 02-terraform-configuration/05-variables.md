
## Terraform Variables

> **File:** `05-variables.md`

## Table of Contents

1. [Introduction](#1-introduction)
2. [Why Do We Need Variables?](#2-why-do-we-need-variables)
3. [Variable Block](#3-variable-block)
4. [Variable Types](#4-variable-types)
5. [Variable Defaults](#5-variable-defaults)
6. [Required Variables](#6-required-variables)
7. [Variable Descriptions](#7-variable-descriptions)
8. [Variable Validation](#8-variable-validation)
9. [Using Variables in Resources](#9-using-variables-in-resources)
10. [Variable Precedence](#10-variable-precedence)
11. [Sensitive Variables](#11-sensitive-variables)
12. [Practical Example](#12-practical-example)
13. [Validating the Configuration](#13-validating-the-configuration)
14. [Common Mistakes and Troubleshooting](#14-common-mistakes-and-troubleshooting)
15. [Best Practices](#15-best-practices)
16. [Interview Questions](#16-interview-questions)
17. [Summary](#17-summary)

## 1. Introduction

Terraform variables allow us to make infrastructure configurations **reusable, configurable, and environment-independent**.

Without variables, we may hardcode values directly into Terraform resources:

```hcl
resource "aws_instance" "example" {
  ami           = "ami-xxxxxxxxxxxxxxxxx"
  instance_type = "t3.micro"
}
```

This works, but the configuration becomes difficult to reuse.

For example, we may want:

```text
Development
├── instance_type = t3.micro
└── region        = us-east-1

Staging
├── instance_type = t3.small
└── region        = us-east-1

Production
├── instance_type = t3.large
└── region        = us-east-1
```

Instead of creating separate Terraform configurations for each environment, we can define variables:

```hcl
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
```

and reference them:

```hcl
resource "aws_instance" "example" {
  instance_type = var.instance_type
}
```

This allows the same Terraform configuration to accept different input values.

### Learning Objectives

By the end of this section, we will understand:

* What Terraform variables are.
* Why variables are useful.
* How to declare variables.
* Terraform variable types.
* Default values.
* Required variables.
* Variable descriptions.
* Variable validation.
* How variables are referenced.
* Variable precedence at a high level.
* Sensitive variables.
* Best practices for reusable Terraform configurations.

## 2. Why Do We Need Variables?

Variables separate **configuration logic** from **input values**.

Consider a hardcoded configuration:

```hcl
resource "aws_instance" "example" {
  instance_type = "t3.micro"

  tags = {
    Environment = "dev"
  }
}
```

If we want to deploy the same configuration to production, we would need to modify the source code.

With variables:

```hcl
resource "aws_instance" "example" {
  instance_type = var.instance_type

  tags = {
    Environment = var.environment
  }
}
```

The Terraform configuration becomes reusable.

```text
               Terraform Configuration
                         │
                         ▼
                     Variables
                         │
              ┌──────────┼──────────┐
              │          │          │
              ▼          ▼          ▼
             Dev      Staging      Prod
              │          │          │
              ▼          ▼          ▼
          Different Input Values
```

### Key Benefits

Variables provide:

* Reusability.
* Flexibility.
* Environment-specific configuration.
* Reduced hardcoding.
* Better maintainability.
* Easier automation.
* Cleaner module interfaces.
* Better separation between code and configuration.

## 3. Variable Block

Terraform variables are declared using a `variable` block.

Basic syntax:

```hcl
variable "variable_name" {
  type        = string
  description = "Description of the variable."
  default     = "value"
}
```

For example:

```hcl
variable "environment" {
  type        = string
  description = "Deployment environment."
  default     = "dev"
}
```

Terraform then exposes the variable through:

```text
var.environment
```

### 3.1 Variable Name

The variable name identifies the input.

Example:

```hcl
variable "instance_type" {
  ...
}
```

The variable is referenced as:

```hcl
var.instance_type
```

Similarly:

```hcl
variable "region" {
  ...
}
```

is referenced as:

```hcl
var.region
```

### 3.2 Variable Reference Syntax

Terraform variables are referenced using:

```text
var.<variable_name>
```

Example:

```hcl
resource "aws_instance" "example" {
  instance_type = var.instance_type
}
```

Here:

```text
var
 │
 └── instance_type
```

means:

> Read the value assigned to the `instance_type` input variable.

## 4. Variable Types

Terraform supports several important types.

The most commonly used types are:

* `string`
* `number`
* `bool`
* `list`
* `set`
* `map`
* `object`
* `tuple`

Terraform also supports the special type:

```text
any
```

which allows a value of any type.

For professional configurations, explicit types are generally preferable because they make the expected input clear.

### 4.1 String

A string represents text.

```hcl
variable "environment" {
  type    = string
  default = "dev"
}
```

Usage:

```hcl
tags = {
  Environment = var.environment
}
```

Example value:

```text
dev
```

### 4.2 Number

A number represents numeric values.

```hcl
variable "instance_count" {
  type    = number
  default = 2
}
```

Usage:

```hcl
count = var.instance_count
```

### 4.3 Boolean

A boolean represents:

```text
true
false
```

Example:

```hcl
variable "enable_monitoring" {
  type    = bool
  default = true
}
```

Usage:

```hcl
enable_monitoring = var.enable_monitoring
```

### 4.4 List

A list is an ordered collection of values of the same type.

Example:

```hcl
variable "availability_zones" {
  type = list(string)

  default = [
    "us-east-1a",
    "us-east-1b"
  ]
}
```

Values are ordered:

```text
Index 0 → us-east-1a
Index 1 → us-east-1b
```

We can reference an element using an index:

```hcl
var.availability_zones[0]
```

### 4.5 Set

A set is an unordered collection of unique values.

Example:

```hcl
variable "enabled_services" {
  type = set(string)

  default = [
    "ec2",
    "s3",
    "iam"
  ]
}
```

Sets are useful when uniqueness matters and ordering does not.

### 4.6 Map

A map is a collection of key-value pairs where all values use the same type.

Example:

```hcl
variable "instance_types" {
  type = map(string)

  default = {
    dev        = "t3.micro"
    staging    = "t3.small"
    production = "t3.large"
  }
}
```

We can access a value using:

```hcl
var.instance_types["dev"]
```

Result:

```text
t3.micro
```

### 4.7 Object

An object allows us to define multiple named attributes with different types.

Example:

```hcl
variable "server_config" {
  type = object({
    name          = string
    instance_type = string
    monitoring    = bool
  })

  default = {
    name          = "web-server"
    instance_type = "t3.micro"
    monitoring    = true
  }
}
```

We can access individual attributes:

```hcl
var.server_config.name
```

```hcl
var.server_config.instance_type
```

```hcl
var.server_config.monitoring
```

Objects are useful for grouping related configuration values.

### 4.8 Tuple

A tuple is an ordered collection where each position can have a different type.

Example:

```hcl
variable "server_definition" {
  type = tuple([
    string,
    number,
    bool
  ])

  default = [
    "web-server",
    2,
    true
  ]
}
```

The first element is a string, the second is a number, and the third is a boolean.

Tuples are less common than lists and objects in everyday infrastructure configurations, but they are part of Terraform's type system.

### 4.9 Any

Terraform also supports:

```hcl
variable "configuration" {
  type = any
}
```

This allows the value to have any type.

However, `any` should not be used simply to avoid defining a proper type.

For reusable infrastructure, explicit types usually provide better validation, readability, and maintainability.

### 4.10 Type Comparison

| Type            | Example                          |         Ordered? | Typical Use                |
| --------------- | -------------------------------- | ---------------: | -------------------------- |
| `string`        | `"dev"`                          |              N/A | Text values                |
| `number`        | `3`                              |              N/A | Numeric values             |
| `bool`          | `true`                           |              N/A | Feature flags              |
| `list(string)`  | `["a", "b"]`                     |              Yes | Ordered values             |
| `set(string)`   | `["a", "b"]`                     |               No | Unique values              |
| `map(string)`   | `{dev = "t3.micro"}`             |        Key-based | Key/value configuration    |
| `object({...})` | `{name = "...", enabled = true}` | Named attributes | Structured configuration   |
| `tuple([...])`  | `["web", 2, true]`               |              Yes | Fixed-position mixed types |
| `any`           | Any valid value                  |          Depends | Flexible module interfaces |

## 5. Variable Defaults

A variable can define a default value.

Example:

```hcl
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
```

If no value is supplied, Terraform uses:

```text
t3.micro
```

This is useful for sensible defaults.

### 5.1 When a Default Exists

```hcl
variable "environment" {
  type    = string
  default = "dev"
}
```

If we run:

```bash
terraform plan
```

without providing another value, Terraform uses:

```text
environment = dev
```

### 5.2 Overriding a Default

A default value can be overridden by providing another value through an appropriate variable input mechanism.

For example:

```bash
terraform plan -var="environment=staging"
```

Terraform then uses:

```text
environment = staging
```

instead of:

```text
environment = dev
```

### 5.3 When Should We Use Defaults?

Good candidates for defaults include:

* Non-sensitive development settings.
* Common instance types.
* Optional feature flags.
* Common naming prefixes.
* Safe development-region defaults.

We should avoid defaults that could accidentally cause expensive or destructive production behavior.

## 6. Required Variables

A variable becomes required when it does not define a `default`.

Example:

```hcl
variable "ami_id" {
  type        = string
  description = "AMI ID used to create the EC2 instance."
}
```

There is no:

```hcl
default = ...
```

Therefore Terraform expects a value.

If no value is supplied, Terraform prompts for it during interactive execution.

For example:

```text
var.ami_id
  Enter a value:
```

In automated environments, missing required variables generally result in an error rather than an interactive prompt.

### 6.1 Why Use Required Variables?

Required variables are useful when:

* The value changes between environments.
* A safe default does not exist.
* The value is region-specific.
* The value must be explicitly provided.
* The configuration depends on external infrastructure.

For example, AMI IDs are commonly region-specific, so forcing the caller to provide the correct value can be safer than hardcoding one globally.

## 7. Variable Descriptions

A description explains what a variable represents.

Example:

```hcl
variable "instance_type" {
  description = "EC2 instance type used for the application server."
  type        = string
  default     = "t3.micro"
}
```

Descriptions improve:

* Readability.
* Documentation.
* Module usability.
* Maintenance.
* Understanding during reviews.

For professional Terraform configurations, variables should generally have meaningful descriptions.

## 8. Variable Validation

Terraform allows us to define validation rules for variables.

This lets us reject invalid input before Terraform attempts to create infrastructure.

Example:

```hcl
variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

Now the accepted values are:

```text
dev
staging
prod
```

A value such as:

```text
testing
```

will fail validation.

### 8.1 Why Validation Matters

Without validation:

```text
User Input
    │
    ▼
Terraform
    │
    ▼
AWS
    │
    ▼
Potential Failure
```

With validation:

```text
User Input
    │
    ▼
Terraform Validation
    │
    ├── Valid ───────► Plan
    │
    └── Invalid ─────► Error
```

Validation moves errors closer to the input boundary.

### 8.2 Numeric Validation

Example:

```hcl
variable "instance_count" {
  description = "Number of instances to create."
  type        = number
  default     = 1

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}
```

This prevents invalid values such as:

```text
0
-1
20
```

### 8.3 String Length Validation

Example:

```hcl
variable "project_name" {
  description = "Project name."
  type        = string

  validation {
    condition     = length(var.project_name) >= 3
    error_message = "Project name must contain at least 3 characters."
  }
}
```

### 8.4 Regular Expression Validation

Terraform can also use functions such as `regex()` for validation.

Example:

```hcl
variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = can(regex("^(dev|staging|prod)$", var.environment))
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

Here `can()` is useful because it converts a potentially failing expression into a boolean result.

For simple membership checks, however, this is often easier to read:

```hcl
condition = contains(["dev", "staging", "prod"], var.environment)
```

The validation method should be chosen based on the requirement.

## 9. Using Variables in Resources

Once a variable is declared, we can reference it using:

```text
var.<variable_name>
```

Example:

```hcl
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
```

Then:

```hcl
resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Environment = var.environment
  }
}
```

The data flow becomes:

```text
Variable Input
      │
      ▼
var.instance_type
      │
      ▼
aws_instance
      │
      ▼
AWS EC2
```

Variables can be used in:

* Resource arguments.
* Data source arguments.
* Module inputs.
* Local values.
* Conditional expressions.
* Function arguments.
* Output expressions.

## 10. Variable Precedence

Terraform supports multiple ways to provide variable values.

Common sources include:

1. Variable defaults.
2. Environment variables using `TF_VAR_<name>`.
3. `terraform.tfvars`.
4. `terraform.tfvars.json`.
5. Automatically loaded `*.auto.tfvars` and `*.auto.tfvars.json` files.
6. Explicit `-var` and `-var-file` command-line arguments.

When multiple sources provide the same variable, Terraform uses a defined precedence order.

A simplified practical model is:

```text
Lowest precedence
        │
        ▼
Variable default
        │
        ▼
Environment variables
        │
        ▼
Automatically loaded variable files
        │
        ▼
Explicit -var / -var-file
        │
        ▼
Highest precedence
```

The exact behavior of multiple variable files also depends on their loading order, so explicit inputs should be used deliberately.

A detailed discussion of `.tfvars` files and variable loading is covered in:

```text
06-tfvars.md
```

## 11. Sensitive Variables

Some variable values should not be displayed in normal Terraform CLI output.

Terraform provides:

```hcl
sensitive = true
```

Example:

```hcl
variable "database_password" {
  description = "Database administrator password."
  type        = string
  sensitive   = true
}
```

Terraform will redact the value in relevant CLI output.

Example:

```text
database_password = (sensitive value)
```

### Important Security Note

Marking a variable as sensitive does **not** encrypt the value or remove it from Terraform state.

If a sensitive value is used by a resource, it may still be stored in the Terraform state.

Therefore:

```text
sensitive = true
```

should not be treated as a complete secrets-management solution.

For production systems, sensitive credentials should be handled using appropriate secret-management and authentication mechanisms.

## 12. Practical Example

Let's create a reusable EC2 configuration using variables.

### 12.1 Project Structure

```text
variables-demo/
├── versions.tf
├── providers.tf
├── variables.tf
├── terraform.tfvars.example
└── main.tf
```

### 12.2 Terraform and Provider Requirements

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

### 12.3 Provider Configuration

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
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
  default     = "terraform-variables-demo"
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
    Name        = "${var.project_name}-instance"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

The configuration is now reusable.

The infrastructure logic remains the same while values can change through variables.

### 12.6 Create an Example Variable File

Create:

```text
terraform.tfvars.example
```

```hcl
aws_region    = "us-east-1"
ami_id        = "ami-xxxxxxxxxxxxxxxxx"
instance_type = "t3.micro"
environment   = "dev"
project_name  = "terraform-variables-demo"
```

The AMI ID must be replaced with an AMI that is valid in the selected AWS region.

For real deployments, create a local:

```text
terraform.tfvars
```

with the actual values.

If that file contains environment-specific or sensitive values, it should normally be excluded from version control.

### 12.7 Initialize Terraform

Run:

```bash
terraform init
```

### 12.8 Format the Configuration

Run:

```bash
terraform fmt
```

### 12.9 Validate the Configuration

Run:

```bash
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

### 12.10 Review the Plan

Run:

```bash
terraform plan
```

Terraform evaluates:

```text
terraform.tfvars
       │
       ▼
Variables
       │
       ▼
Terraform Configuration
       │
       ▼
Execution Plan
```

Review the proposed EC2 configuration before applying it.

### 12.11 Apply the Configuration

Run:

```bash
terraform apply
```

Review and confirm the proposed changes.

### 12.12 Override a Variable From the CLI

We can override the default instance type:

```bash
terraform plan -var="instance_type=t3.small"
```

Terraform uses:

```text
instance_type = t3.small
```

for that execution.

### 12.13 Clean Up

After completing the exercise:

```bash
terraform destroy
```

Review the proposed deletion and confirm it.

## 13. Validating the Configuration

A professional workflow can use:

```bash
terraform fmt
terraform validate
terraform plan
```

before applying infrastructure.

### Recommended Validation Flow

```text
                    Terraform Configuration
                              │
                              ▼
                       terraform fmt
                              │
                              ▼
                      terraform validate
                              │
                              ▼
                       terraform plan
                              │
                              ▼
                       Review Changes
                              │
                              ▼
                       terraform apply
```

For variable validation specifically, we should verify:

```text
[ ] Variable names are meaningful
[ ] Variable types are explicit
[ ] Required variables are intentional
[ ] Defaults are safe
[ ] Descriptions are provided
[ ] Validation rules are appropriate
[ ] Sensitive values are marked sensitive
[ ] Sensitive values are not committed to Git
[ ] Region-specific values are correct
```

## 14. Common Mistakes and Troubleshooting

### 14.1 Referencing an Undeclared Variable

Incorrect:

```hcl
instance_type = var.ec2_type
```

when no variable named `ec2_type` exists.

Terraform will report an undeclared variable error.

Correct:

```hcl
variable "ec2_type" {
  type = string
}
```

or reference the variable that was actually declared.

### 14.2 Using the Wrong Variable Type

Suppose we declare:

```hcl
variable "instance_count" {
  type = number
}
```

but provide:

```text
instance_count = "three"
```

The value does not satisfy the declared type.

We should provide:

```hcl
instance_count = 3
```

### 14.3 Forgetting That Variables Without Defaults Are Required

Example:

```hcl
variable "ami_id" {
  type = string
}
```

If we do not provide `ami_id`, Terraform cannot construct the intended resource configuration.

Provide it through an appropriate variable input mechanism.

### 14.4 Incorrect Boolean Values

For a boolean variable:

```hcl
variable "enable_monitoring" {
  type    = bool
  default = true
}
```

Use:

```hcl
enable_monitoring = false
```

rather than:

```hcl
enable_monitoring = "false"
```

The latter is a string, not a boolean value.

### 14.5 Hardcoding Values Instead of Using Variables

Instead of:

```hcl
resource "aws_instance" "example" {
  instance_type = "t3.micro"
}
```

we can use:

```hcl
resource "aws_instance" "example" {
  instance_type = var.instance_type
}
```

This makes the configuration more reusable.

However, not every constant needs to become a variable.

We should create variables for values that are expected to vary or form part of a reusable interface.

### 14.6 Treating Sensitive Variables as Secret Storage

This:

```hcl
sensitive = true
```

redacts values in relevant CLI output.

It does not mean:

```text
Value is encrypted everywhere
```

or:

```text
Value is absent from Terraform state
```

We still need appropriate secret-management practices.

### 14.7 Using `any` Everywhere

This:

```hcl
type = any
```

provides flexibility but reduces type-level validation.

Prefer:

```hcl
type = string
```

```hcl
type = list(string)
```

or:

```hcl
type = object({
  name    = string
  enabled = bool
})
```

when the expected structure is known.

## 15. Best Practices

### 15.1 Use Explicit Variable Types

Prefer:

```hcl
variable "environment" {
  type = string
}
```

over leaving the type unspecified when the expected type is known.

### 15.2 Provide Useful Descriptions

Prefer:

```hcl
description = "AWS region where the application infrastructure will be deployed."
```

over:

```hcl
description = "Region."
```

Descriptions should explain the variable's purpose.

### 15.3 Use Validation for Important Constraints

Example:

```hcl
validation {
  condition     = contains(["dev", "staging", "prod"], var.environment)
  error_message = "Environment must be dev, staging, or prod."
}
```

This prevents invalid values from reaching the planning or provisioning stage.

### 15.4 Keep Defaults Safe

A default should be predictable and safe.

For example:

```hcl
default = "t3.micro"
```

may be reasonable for a learning environment.

Production-specific settings should generally be provided explicitly through the environment's configuration.

### 15.5 Do Not Turn Every Value Into a Variable

Not every string or number needs to be configurable.

For example:

```hcl
tags = {
  ManagedBy = "Terraform"
}
```

does not necessarily need a variable.

Over-parameterization can make configurations harder to understand.

The goal is:

> Parameterize meaningful configuration differences, not every literal value.

### 15.6 Separate Code From Environment Values

A reusable Terraform configuration should generally keep infrastructure logic in `.tf` files and environment-specific inputs in appropriate variable files or automation configuration.

Example:

```text
Terraform Code
    │
    ├── versions.tf
    ├── providers.tf
    ├── variables.tf
    └── main.tf
             │
             ▼
      Environment Inputs
             │
       ┌─────┴─────┐
       ▼           ▼
      Dev         Prod
```

### 15.7 Do Not Commit Sensitive Variable Files

If a variable file contains:

* Passwords.
* Tokens.
* API keys.
* Private credentials.
* Other secrets.

it should not be committed to Git.

A common repository pattern is:

```text
terraform.tfvars.example
```

for safe examples, while the actual:

```text
terraform.tfvars
```

remains local or is managed through an approved secure mechanism.

### 15.8 Use Naming Consistently

Use descriptive names such as:

```text
aws_region
instance_type
environment
project_name
```

Avoid vague names such as:

```text
x
value
data
input1
```

Clear naming is particularly important when variables become module interfaces.

### 15.9 Treat Variables as Module Interfaces

A reusable Terraform module can expose variables as its input interface.

Conceptually:

```text
Caller
  │
  │ Input Variables
  ▼
Terraform Module
  │
  │ Resources
  ▼
Infrastructure
```

This becomes especially important when we start building reusable Terraform modules.

## 16. Interview Questions

### Q1. What are Terraform variables?

**Answer:**

Terraform variables are input values that allow us to make Terraform configurations reusable and configurable without hardcoding environment-specific values directly into resources.

### Q2. How do we declare a Terraform variable?

**Answer:**

We use a `variable` block.

Example:

```hcl
variable "instance_type" {
  type        = string
  description = "EC2 instance type."
  default     = "t3.micro"
}
```

### Q3. How do we reference a variable?

**Answer:**

We use:

```text
var.<variable_name>
```

Example:

```hcl
instance_type = var.instance_type
```

### Q4. What happens if a variable has no default value?

**Answer:**

The variable is required.

Terraform expects us to provide a value through an appropriate variable input mechanism.

### Q5. What is variable validation?

**Answer:**

Variable validation allows us to define rules that input values must satisfy.

Example:

```hcl
validation {
  condition     = contains(["dev", "staging", "prod"], var.environment)
  error_message = "Environment must be dev, staging, or prod."
}
```

Invalid values are rejected before Terraform proceeds with the operation.

### Q6. What are common Terraform variable types?

**Answer:**

Common types include:

```text
string
number
bool
list
set
map
object
tuple
```

Terraform also supports `any`.

### Q7. What is the difference between a list and a set?

**Answer:**

A list is ordered and can contain duplicate values.

A set is unordered and contains unique values.

Example:

```hcl
list(string)
```

is appropriate when order matters.

```hcl
set(string)
```

is useful when uniqueness matters and ordering does not.

### Q8. What is a sensitive variable?

**Answer:**

A variable marked with:

```hcl
sensitive = true
```

is treated as sensitive and its value is redacted in relevant Terraform CLI output.

However, sensitive values can still exist in Terraform state, so `sensitive = true` is not a replacement for proper secret management.

### Q9. Should every Terraform value be a variable?

**Answer:**

No.

Variables should be used for values that are expected to vary or form part of a reusable configuration interface.

Turning every constant into a variable can unnecessarily complicate the configuration.

### Q10. Why are variables useful in multi-environment deployments?

**Answer:**

Variables allow the same Terraform configuration to be reused with different inputs.

For example:

```text
Development
instance_type = t3.micro

Staging
instance_type = t3.small

Production
instance_type = t3.large
```

The infrastructure logic remains the same while environment-specific values change.

### Q11. What is the difference between a variable and a local value?

**Answer:**

A variable is an input to a Terraform module.

A local value is an internal calculated or reusable value within the module.

Conceptually:

```text
Variable
   │
   │ External Input
   ▼
Terraform Module
   │
   ├── Local Values
   │
   └── Resources
```

Variables allow callers to provide values, while locals help organize expressions inside the configuration.

## 17. Summary

Terraform variables allow us to separate infrastructure logic from configurable input values.

A typical variable is:

```hcl
variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}
```

We then reference it using:

```hcl
var.instance_type
```

The overall flow is:

```text
Variable Definition
       │
       ▼
Variable Value
       │
       ▼
Terraform Configuration
       │
       ▼
Execution Plan
       │
       ▼
Infrastructure
```

### What We Learned

* Variables make Terraform configurations reusable.
* Variables are declared using `variable` blocks.
* Variables are referenced using `var.<name>`.
* Variables can have explicit types.
* Variables without defaults are required.
* Defaults provide fallback values.
* Descriptions improve maintainability.
* Validation prevents invalid inputs.
* Sensitive variables can redact values from CLI output.
* Sensitive values may still be stored in Terraform state.
* Lists are ordered collections.
* Sets contain unique unordered values.
* Maps contain key-value pairs.
* Objects provide structured named attributes.
* `any` should be used deliberately.
* Not every hardcoded value needs to become a variable.
* Variables are particularly useful for reusable modules and multi-environment deployments.

### Key Takeaway

> Terraform variables provide a controlled input interface that allows the same infrastructure configuration to be reused with different values across environments and deployments.

### Next Section

Next, we will learn about **Terraform `.tfvars` files** and how variable values can be organized and supplied separately from the Terraform configuration.
