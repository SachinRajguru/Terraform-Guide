
## Terraform Conditional Expressions

> **File:** `07-conditional-expressions.md`

## Table of Contents

1. [Introduction](#1-introduction)
2. [What Is a Conditional Expression?](#2-what-is-a-conditional-expression)
3. [Conditional Expression Syntax](#3-conditional-expression-syntax)
4. [Basic Conditional Expression](#4-basic-conditional-expression)
5. [Conditional Expressions with Variables](#5-conditional-expressions-with-variables)
6. [Conditional Expressions in Resources](#6-conditional-expressions-in-resources)
7. [Environment-Based Configuration](#7-environment-based-configuration)
8. [Conditional Resource Arguments](#8-conditional-resource-arguments)
9. [Nested Conditional Expressions](#9-nested-conditional-expressions)
10. [Conditional Expressions with Other Terraform Features](#10-conditional-expressions-with-other-terraform-features)
11. [Type Consistency](#11-type-consistency)
12. [Practical Example](#12-practical-example)
13. [Validation and Testing](#13-validation-and-testing)
14. [Common Mistakes and Troubleshooting](#14-common-mistakes-and-troubleshooting)
15. [Best Practices](#15-best-practices)
16. [Interview Questions](#16-interview-questions)
17. [Summary](#17-summary)

## 1. Introduction

Terraform configurations often need to behave differently depending on the environment or input values.

For example:

* Development may use a small EC2 instance.
* Production may use a larger instance.
* Development may enable detailed logging.
* Production may enable additional monitoring.
* A backup configuration may be enabled only for production.
* A resource argument may use one value when a feature is enabled and another value when it is disabled.

Terraform provides **conditional expressions** for these situations.

A conditional expression allows Terraform to choose between two values based on whether a condition evaluates to `true` or `false`.

The basic idea is:

```text
                Condition
                    │
             ┌──────┴──────┐
             │             │
           true          false
             │             │
             ▼             ▼
         True Value   False Value
```

For example:

```hcl
var.environment == "prod" ? "t3.large" : "t3.micro"
```

This means:

```text
If environment == "prod"
        │
        ├── Yes → t3.large
        │
        └── No  → t3.micro
```

### Learning Objectives

By the end of this section, we will understand:

* What conditional expressions are.
* Terraform conditional expression syntax.
* How to use conditions with variables.
* How to use conditions inside resources.
* How to implement environment-based configuration.
* How conditional expressions interact with Terraform types.
* How to combine conditions with other Terraform features.
* How to avoid common conditional-expression mistakes.
* When to use conditionals and when to use a different Terraform design.
* How conditional expressions appear in real-world infrastructure code.

## 2. What Is a Conditional Expression?

A conditional expression evaluates a condition and returns one of two possible values.

Terraform uses the following syntax:

```hcl
condition ? true_value : false_value
```

The three parts are:

```text
condition
    │
    ▼
condition ? true_value : false_value
             │              │
             │              └── Returned when condition is false
             │
             └───────────────── Returned when condition is true
```

For example:

```hcl
var.environment == "prod" ? "large" : "small"
```

If:

```hcl
var.environment = "prod"
```

the result is:

```text
large
```

If:

```hcl
var.environment = "dev"
```

the result is:

```text
small
```

## 3. Conditional Expression Syntax

The general syntax is:

```hcl
condition ? true_value : false_value
```

### Example

```hcl
var.environment == "prod" ? "production" : "non-production"
```

Terraform evaluates:

```hcl
var.environment == "prod"
```

If the result is `true`:

```text
production
```

If the result is `false`:

```text
non-production
```

### 3.1 Comparison Operators

Conditional expressions commonly use comparison operators.

### Equal

```hcl
var.environment == "prod"
```

### Not Equal

```hcl
var.environment != "prod"
```

### Greater Than

```hcl
var.instance_count > 2
```

### Less Than

```hcl
var.instance_count < 3
```

### Greater Than or Equal

```hcl
var.instance_count >= 2
```

### Less Than or Equal

```hcl
var.instance_count <= 2
```

### 3.2 Logical Operators

Conditions can also use logical operators.

### AND

```hcl
var.environment == "prod" && var.monitoring_enabled
```

Both conditions must be true.

### OR

```hcl
var.environment == "prod" || var.environment == "staging"
```

At least one condition must be true.

### NOT

```hcl
!var.monitoring_enabled
```

This reverses a Boolean value.

## 4. Basic Conditional Expression

Let's start with a simple example.

```hcl
variable "environment" {
  type    = string
  default = "dev"
}
```

We can create a local value:

```hcl
locals {
  instance_size = var.environment == "prod" ? "large" : "small"
}
```

Terraform evaluates:

```text
environment == prod
        │
        ├── true  → large
        │
        └── false → small
```

Therefore:

```text
environment = dev
instance_size = small
```

For:

```text
environment = prod
```

we get:

```text
instance_size = large
```

## 5. Conditional Expressions with Variables

Conditional expressions become particularly useful when combined with input variables.

Consider:

```hcl
variable "environment" {
  description = "Deployment environment."
  type        = string
}
```

We can define:

```hcl
locals {
  instance_type = var.environment == "prod" ? "t3.large" : "t3.micro"
}
```

Now the infrastructure automatically changes based on the environment.

### Development

```text
environment = dev
        │
        ▼
condition = false
        │
        ▼
t3.micro
```

### Production

```text
environment = prod
        │
        ▼
condition = true
        │
        ▼
t3.large
```

This allows us to reuse the same Terraform configuration.

## 6. Conditional Expressions in Resources

Conditional expressions can be used directly inside resource arguments.

For example:

```hcl
resource "aws_instance" "example" {
  ami = var.ami_id

  instance_type = var.environment == "prod" ? "t3.large" : "t3.micro"

  tags = {
    Name        = "terraform-instance"
    Environment = var.environment
  }
}
```

Terraform evaluates:

```hcl
var.environment == "prod" ? "t3.large" : "t3.micro"
```

before creating the resource.

### Development

```text
environment = dev
instance_type = t3.micro
```

### Production

```text
environment = prod
instance_type = t3.large
```

The resource block itself does not need to be duplicated.

## 7. Environment-Based Configuration

One of the most common real-world uses of conditional expressions is environment-based configuration.

For example:

```hcl
variable "environment" {
  type = string
}
```

We can define:

```hcl
locals {
  instance_type = var.environment == "prod" ? "t3.large" : "t3.micro"

  enable_monitoring = var.environment == "prod"

  backup_enabled = var.environment == "prod"
}
```

This gives us:

```text
                    Environment
                         │
              ┌──────────┴──────────┐
              │                     │
             dev                  prod
              │                     │
              ▼                     ▼
          t3.micro               t3.large
          monitoring=false       monitoring=true
          backup=false           backup=true
```

The same Terraform code can therefore support multiple environments.

### 7.1 Why This Is Better Than Duplicating Configuration

Without conditional logic, we might create separate infrastructure definitions:

```text
dev/
├── main.tf
└── variables.tf

prod/
├── main.tf
└── variables.tf
```

This can result in duplicated code.

Instead, we can often maintain:

```text
terraform/
├── main.tf
├── variables.tf
├── locals.tf
└── dev.tfvars
└── prod.tfvars
```

and let the values determine the required behavior.

This is one of the fundamental benefits of Infrastructure as Code:

> We define reusable infrastructure logic and vary its behavior through controlled inputs.

## 8. Conditional Resource Arguments

Conditional expressions can be used for many resource arguments.

For example:

```hcl
resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = var.environment == "prod" ? "t3.large" : "t3.micro"

  monitoring = var.environment == "prod"

  tags = {
    Name        = "terraform-instance"
    Environment = var.environment
  }
}
```

Here:

```hcl
monitoring = var.environment == "prod"
```

is itself a Boolean expression.

It evaluates to:

```text
dev  → false
prod → true
```

### 8.1 Conditional Tag Values

Conditionals can also be used in tags.

```hcl
tags = {
  Name        = "terraform-instance"
  Environment = var.environment
  Tier        = var.environment == "prod" ? "critical" : "standard"
}
```

For development:

```text
Tier = standard
```

For production:

```text
Tier = critical
```

### 8.2 Conditional Numeric Values

Conditional expressions do not have to return strings.

For example:

```hcl
locals {
  volume_size = var.environment == "prod" ? 100 : 20
}
```

Result:

```text
dev  → 20
prod → 100
```

The returned values are numbers.

### 8.3 Conditional Boolean Values

We can also return Boolean values:

```hcl
locals {
  enable_monitoring = var.environment == "prod" ? true : false
}
```

However, this can usually be simplified to:

```hcl
locals {
  enable_monitoring = var.environment == "prod"
}
```

The second version is cleaner because the condition itself already produces a Boolean result.

## 9. Nested Conditional Expressions

Terraform allows conditional expressions to be nested.

For example:

```hcl
locals {
  instance_type = var.environment == "prod" ? "t3.large" : (
    var.environment == "staging" ? "t3.small" : "t3.micro"
  )
}
```

The logic is:

```text
environment
     │
     ├── prod
     │     └── t3.large
     │
     ├── staging
     │     └── t3.small
     │
     └── anything else
           └── t3.micro
```

This works, but excessive nesting can reduce readability.

### 9.1 When Nested Conditionals Become Difficult to Read

Consider:

```hcl
locals {
  instance_type = var.environment == "prod" ? "t3.large" : (
    var.environment == "staging" ? "t3.medium" : (
      var.environment == "qa" ? "t3.small" : "t3.micro"
    )
  )
}
```

The configuration becomes harder to maintain.

For multiple environment mappings, a map is often clearer:

```hcl
locals {
  instance_types = {
    dev     = "t3.micro"
    qa      = "t3.small"
    staging = "t3.medium"
    prod    = "t3.large"
  }

  instance_type = local.instance_types[var.environment]
}
```

This is usually easier to understand and extend.

### Rule of Thumb

Use:

```hcl
condition ? value_if_true : value_if_false
```

for simple decisions.

For many possible values, consider:

* Maps.
* `lookup`.
* `try`.
* `for` expressions.
* Separate locals.
* Modules.

## 10. Conditional Expressions with Other Terraform Features

Conditional expressions become even more powerful when combined with other Terraform language features.

### 10.1 Conditional Expressions with Locals

A local value is a convenient place to centralize conditional logic.

```hcl
locals {
  instance_type = var.environment == "prod" ? "t3.large" : "t3.micro"
}
```

Resources can then reference:

```hcl
resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = local.instance_type
}
```

This separates:

```text
Decision Logic
     │
     ▼
  locals.tf
     │
     ▼
Resource Configuration
```

### 10.2 Conditional Expressions with Variables

We can combine variables directly:

```hcl
variable "environment" {
  type = string
}

variable "high_availability" {
  type    = bool
  default = false
}
```

Then:

```hcl
locals {
  instance_count = var.environment == "prod" && var.high_availability ? 3 : 1
}
```

The logic is:

```text
prod + HA enabled
      │
      └── 3 instances

Everything else
      │
      └── 1 instance
```

### 10.3 Conditional Expressions with Functions

Terraform functions can also be used inside conditions.

For example:

```hcl
locals {
  environment_name = lower(var.environment)

  instance_type = local.environment_name == "prod"
    ? "t3.large"
    : "t3.micro"
}
```

The function:

```hcl
lower(var.environment)
```

normalizes the input before the comparison.

### 10.4 Conditional Expressions with `count`

Conditional expressions can determine whether a resource should exist.

For example:

```hcl
resource "aws_cloudwatch_log_group" "example" {
  count = var.environment == "prod" ? 1 : 0

  name = "/terraform/${var.environment}"
}
```

The result is:

```text
prod
 │
 └── count = 1
       │
       └── Resource created

dev
 │
 └── count = 0
       │
       └── Resource not created
```

This is a common Terraform pattern.

However, for larger conditional resource collections, `for_each` is often easier to manage.

## 11. Type Consistency

One important Terraform rule is that the two result expressions should be type-compatible.

Consider:

```hcl
var.environment == "prod" ? "large" : "small"
```

Both branches return strings:

```text
"large" → string
"small" → string
```

This is straightforward.

Similarly:

```hcl
var.environment == "prod" ? 100 : 20
```

returns numbers from both branches.

### 11.1 Avoid Unnecessarily Different Types

For example:

```hcl
var.environment == "prod" ? "100" : 20
```

The first branch is a string:

```text
"100"
```

while the second is a number:

```text
20
```

Although Terraform can perform some automatic type conversions in certain contexts, relying on implicit conversions can make configurations harder to understand.

Prefer consistent types:

```hcl
var.environment == "prod" ? 100 : 20
```

or:

```hcl
var.environment == "prod" ? "100" : "20"
```

depending on what the receiving argument requires.

## 12. Practical Example

Let's create a practical AWS example using environment-based conditional configuration.

### 12.1 Project Structure

```text
conditional-expression-demo/
├── versions.tf
├── providers.tf
├── variables.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── dev.tfvars
└── prod.tfvars
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

### 12.3 Configure the AWS Provider

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
  description = "AWS region where resources will be deployed."
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID available in the selected AWS region."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either dev or prod."
  }
}
```

### 12.5 Define Conditional Logic

Create:

```text
locals.tf
```

```hcl
locals {
  instance_type = var.environment == "prod" ? "t3.large" : "t3.micro"

  monitoring_enabled = var.environment == "prod"

  instance_name = var.environment == "prod"
    ? "terraform-prod-instance"
    : "terraform-dev-instance"
}
```

The important logic is:

```hcl
var.environment == "prod" ? "t3.large" : "t3.micro"
```

### 12.6 Create the EC2 Instance

Create:

```text
main.tf
```

```hcl
resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = local.instance_type
  monitoring    = local.monitoring_enabled

  tags = {
    Name        = local.instance_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

### 12.7 Create Outputs

Create:

```text
outputs.tf
```

```hcl
output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.example.id
}

output "instance_type" {
  description = "EC2 instance type selected by the conditional expression."
  value       = aws_instance.example.instance_type
}

output "environment" {
  description = "Deployment environment."
  value       = var.environment
}
```

### 12.8 Development Variables

Create:

```text
dev.tfvars
```

```hcl
aws_region = "us-east-1"
ami_id     = "ami-xxxxxxxxxxxxxxxxx"
environment = "dev"
```

Replace the AMI placeholder with a valid AMI available in the selected region.

The expected conditional result is:

```text
environment = dev

instance_type      = t3.micro
monitoring_enabled = false
instance_name      = terraform-dev-instance
```

### 12.9 Production Variables

Create:

```text
prod.tfvars
```

```hcl
aws_region = "us-east-1"
ami_id     = "ami-yyyyyyyyyyyyyyyyy"
environment = "prod"
```

The expected conditional result is:

```text
environment = prod

instance_type      = t3.large
monitoring_enabled = true
instance_name      = terraform-prod-instance
```

The AMI must be valid for the selected AWS region.

### 12.10 Initialize Terraform

Run:

```bash
terraform init
```

### 12.11 Format the Configuration

Run:

```bash
terraform fmt
```

### 12.12 Validate the Configuration

Run:

```bash
terraform validate
```

Expected:

```text
Success! The configuration is valid.
```

### 12.13 Create a Development Plan

Run:

```bash
terraform plan -var-file="dev.tfvars"
```

Review the plan.

We should see:

```text
instance_type = "t3.micro"
monitoring    = false
```

### 12.14 Create a Production Plan

Run:

```bash
terraform plan -var-file="prod.tfvars"
```

We should see:

```text
instance_type = "t3.large"
monitoring    = true
```

The same Terraform configuration produces different infrastructure characteristics based on the input variable.

### 12.15 Apply the Development Configuration

Run:

```bash
terraform apply -var-file="dev.tfvars"
```

Review the plan and confirm the operation.

### 12.16 Destroy the Development Configuration

After completing the lab:

```bash
terraform destroy -var-file="dev.tfvars"
```

Review and confirm the deletion.

## 13. Validation and Testing

Conditional expressions should be tested through `terraform plan`.

A useful workflow is:

```text
Change Variable
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
Review Conditional Result
      │
      ▼
Apply Only After Verification
```

### 13.1 Test Development

```bash
terraform plan -var-file="dev.tfvars"
```

Verify:

```text
instance_type = t3.micro
monitoring    = false
```

### 13.2 Test Production

```bash
terraform plan -var-file="prod.tfvars"
```

Verify:

```text
instance_type = t3.large
monitoring    = true
```

This confirms that the conditional expression is responding to the environment variable as intended.

### 13.3 Test Invalid Values

Try an invalid environment:

```hcl
environment = "test"
```

The validation rule should reject it.

Expected behavior:

```text
test
 │
 ▼
Variable validation
 │
 ▼
Configuration rejected
```

This demonstrates an important Terraform principle:

> Conditional logic controls behavior, while variable validation controls acceptable input.

Both can and should be used together.

## 14. Common Mistakes and Troubleshooting

### 14.1 Incorrect Conditional Syntax

Incorrect:

```hcl
var.environment == "prod" "t3.large" "t3.micro"
```

Correct:

```hcl
var.environment == "prod" ? "t3.large" : "t3.micro"
```

The required syntax is:

```hcl
condition ? true_value : false_value
```

### 14.2 Forgetting the False Branch

Incorrect:

```hcl
var.environment == "prod" ? "t3.large"
```

A Terraform conditional expression requires both outcomes.

Correct:

```hcl
var.environment == "prod" ? "t3.large" : "t3.micro"
```

### 14.3 Comparing the Wrong Value

Suppose:

```hcl
environment = "production"
```

but the condition checks:

```hcl
var.environment == "prod"
```

The condition evaluates to false.

If the accepted value is:

```text
production
```

then the condition should match it:

```hcl
var.environment == "production"
```

Better still, standardize environment names across the project.

### 14.4 Inconsistent Types

Avoid:

```hcl
var.environment == "prod" ? "100" : 20
```

Prefer consistent types:

```hcl
var.environment == "prod" ? 100 : 20
```

when a numeric value is required.

### 14.5 Too Many Nested Conditionals

This:

```hcl
var.environment == "prod" ? "t3.large" : (
  var.environment == "staging" ? "t3.medium" : (
    var.environment == "qa" ? "t3.small" : "t3.micro"
  )
)
```

works, but can become difficult to maintain.

A map is often clearer:

```hcl
locals {
  instance_types = {
    dev     = "t3.micro"
    qa      = "t3.small"
    staging = "t3.medium"
    prod    = "t3.large"
  }

  instance_type = local.instance_types[var.environment]
}
```

### 14.6 Conditional Logic Does Not Automatically Create Multiple Resources

This:

```hcl
instance_type = var.environment == "prod" ? "t3.large" : "t3.micro"
```

changes an argument value.

It does not create two EC2 instances.

If we need conditional resource creation, we can use:

```hcl
count
```

or:

```hcl
for_each
```

For example:

```hcl
count = var.environment == "prod" ? 1 : 0
```

### 14.7 Assuming Conditional Expressions Hide Resources

Conditional expressions determine the selected value.

They should not be confused with security controls or access controls.

For example:

```hcl
instance_type = var.environment == "prod" ? "t3.large" : "t3.micro"
```

does not protect production infrastructure.

It only selects the instance type.

## 15. Best Practices

### 15.1 Keep Conditions Simple

Prefer:

```hcl
var.environment == "prod" ? "t3.large" : "t3.micro"
```

over unnecessarily complicated expressions.

### 15.2 Use Locals for Reusable Conditional Logic

Instead of repeating:

```hcl
var.environment == "prod"
```

throughout multiple resources, centralize the logic:

```hcl
locals {
  is_production = var.environment == "prod"
}
```

Then:

```hcl
monitoring = local.is_production
```

and:

```hcl
backup_enabled = local.is_production
```

This improves readability.

### 15.3 Combine Validation with Conditional Logic

Use validation to restrict input values:

```hcl
validation {
  condition     = contains(["dev", "staging", "prod"], var.environment)
  error_message = "Environment must be dev, staging, or prod."
}
```

Then use conditional logic to determine behavior.

```text
Input Validation
      │
      ▼
Valid Environment
      │
      ▼
Conditional Logic
      │
      ▼
Infrastructure Configuration
```

### 15.4 Prefer Maps for Many Possible Values

For two possibilities:

```hcl
var.environment == "prod" ? "t3.large" : "t3.micro"
```

is excellent.

For many environments:

```hcl
locals {
  instance_types = {
    dev     = "t3.micro"
    staging = "t3.small"
    prod    = "t3.large"
  }
}
```

is generally easier to maintain.

### 15.5 Avoid Duplicating Infrastructure Code

Do not create separate resource definitions simply because environments require different values.

Prefer:

```text
One Resource Definition
        │
        ▼
Conditional / Variable-Based Configuration
        │
        ├── Dev
        ├── Staging
        └── Prod
```

when the infrastructure architecture is fundamentally the same.

### 15.6 Use Explicit Environment Inputs

For environment-based deployments:

```bash
terraform plan -var-file="dev.tfvars"
```

and:

```bash
terraform plan -var-file="prod.tfvars"
```

make the selected environment obvious.

### 15.7 Review the Plan

Conditional expressions can change infrastructure behavior.

Always review:

```bash
terraform plan
```

before applying production changes.

### 15.8 Do Not Overuse Conditional Expressions

Conditional expressions are useful, but they should not become a substitute for good architecture.

If a Terraform configuration becomes filled with complicated conditions, consider:

* Modules.
* Maps.
* Objects.
* `for_each`.
* Separate modules for genuinely different architectures.
* Environment-specific composition.

The goal is maintainable infrastructure, not maximum use of Terraform language features.

## 16. Interview Questions

### Q1. What is a Terraform conditional expression?

**Answer:**

A conditional expression evaluates a condition and returns one of two values.

Syntax:

```hcl
condition ? true_value : false_value
```

Example:

```hcl
var.environment == "prod" ? "t3.large" : "t3.micro"
```

### Q2. What does `?` mean in Terraform?

**Answer:**

The `?` begins a conditional expression.

Example:

```hcl
condition ? true_value : false_value
```

It separates the condition from the value returned when the condition is true.

### Q3. What does `:` mean in a Terraform conditional expression?

**Answer:**

The `:` separates the true result from the false result.

Example:

```hcl
condition ? value_if_true : value_if_false
```

### Q4. Can conditional expressions return Boolean values?

**Answer:**

Yes.

For example:

```hcl
var.environment == "prod" ? true : false
```

However, if the condition itself already produces a Boolean, this can usually be simplified to:

```hcl
var.environment == "prod"
```

### Q5. Can conditional expressions return numbers?

**Answer:**

Yes.

Example:

```hcl
var.environment == "prod" ? 100 : 20
```

This returns:

```text
prod → 100
other → 20
```

### Q6. Can conditional expressions be used inside resources?

**Answer:**

Yes.

For example:

```hcl
resource "aws_instance" "example" {
  instance_type = var.environment == "prod" ? "t3.large" : "t3.micro"
}
```

### Q7. Can conditional expressions create resources?

**Answer:**

A conditional expression itself does not create resources.

It can, however, be used with `count` or other meta-arguments to conditionally create resources.

Example:

```hcl
count = var.environment == "prod" ? 1 : 0
```

### Q8. What happens when the condition is false?

**Answer:**

Terraform returns the value after the `:`.

Example:

```hcl
var.environment == "prod" ? "large" : "small"
```

If the condition is false:

```text
small
```

is returned.

### Q9. Can conditional expressions be nested?

**Answer:**

Yes.

Example:

```hcl
var.environment == "prod"
  ? "t3.large"
  : var.environment == "staging"
    ? "t3.medium"
    : "t3.micro"
```

However, excessive nesting can reduce readability. For many choices, maps are often a better solution.

### Q10. Why should we be careful about types in conditional expressions?

**Answer:**

The true and false results should be type-compatible.

Prefer:

```hcl
condition ? 100 : 20
```

over:

```hcl
condition ? "100" : 20
```

when the receiving argument expects a number.

### Q11. When should we use a map instead of a conditional expression?

**Answer:**

A simple two-way decision is a good fit for a conditional expression:

```hcl
var.environment == "prod" ? "t3.large" : "t3.micro"
```

When we have many possible mappings, a map is generally easier to maintain:

```hcl
locals {
  instance_types = {
    dev     = "t3.micro"
    staging = "t3.small"
    prod    = "t3.large"
  }
}
```

### Q12. What is a real-world use case for conditional expressions?

**Answer:**

Environment-specific infrastructure configuration is a common use case.

For example:

```hcl
instance_type = var.environment == "prod" ? "t3.large" : "t3.micro"
```

Development receives a smaller instance while production receives a larger instance without duplicating the resource configuration.

## 17. Summary

Terraform conditional expressions allow us to select values dynamically based on conditions.

The fundamental syntax is:

```hcl
condition ? true_value : false_value
```

For example:

```hcl
var.environment == "prod" ? "t3.large" : "t3.micro"
```

This allows the same Terraform configuration to behave differently depending on input values.

### Core Concepts

```text
Condition
    │
    ├── true  → True Value
    │
    └── false → False Value
```

### Common Uses

Conditional expressions can be used for:

* Instance types.
* Resource arguments.
* Boolean settings.
* Tag values.
* Numeric values.
* Environment-specific configuration.
* Conditional resource creation through `count`.
* Local values.
* Combinations of variables and functions.

### Simple Example

```hcl
locals {
  instance_type = var.environment == "prod" ? "t3.large" : "t3.micro"
}
```

### Complex Mapping

When there are many possible values, prefer a map:

```hcl
locals {
  instance_types = {
    dev     = "t3.micro"
    staging = "t3.small"
    prod    = "t3.large"
  }

  instance_type = local.instance_types[var.environment]
}
```

### Key Takeaway

> Conditional expressions allow Terraform configurations to make controlled decisions without duplicating infrastructure code.

The most important pattern to remember is:

```hcl
condition ? value_if_true : value_if_false
```

Use conditional expressions for simple decisions, use maps for larger value mappings, and use `count` or `for_each` when the requirement is to control resource creation rather than simply select an argument value.

### Next Section

Next, we will learn about **Terraform Built-in Functions** and how functions such as `lookup`, `merge`, `length`, `contains`, `join`, `split`, `format`, and other functions help us transform and work with Terraform data.
