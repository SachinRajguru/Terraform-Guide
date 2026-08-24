
## Terraform Variables

**File:** 📄 `05-variables.md`

## Table of Contents

1. [Introduction](#1-introduction)
2. [Parameterization](#2-parameterization)
3. [Input Variables](#3-input-variables)
4. [Variable Components](#4-variable-components)
5. [Output Values](#5-output-values)
6. [Input vs Output](#6-input-vs-output)
7. [Variable Validation](#7-variable-validation)
8. [Sensitive Variables](#8-sensitive-variables)
9. [Summary](#9-summary)

## 1. Introduction

Variables make Terraform configurations reusable.

> Hard-coded configuration makes Terraform projects difficult to reuse.

Without variables:

```hcl
resource "aws_instance" "web" {
  ami           = "hard-coded-value"
  instance_type = "t3.micro"
}
```

If another environment needs:

```text
t3.small
```

the Terraform source must be modified.

Variables solve this problem.

With variables:
```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
}
```

Terraform input variables allow module consumers to provide values without modifying the module source code. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/values/variables))

## 2. Parameterization

Parameterization means moving configurable values out of hard-coded infrastructure logic.

Analogy:

```text
Terraform code = machine
Variables      = controls
```

The same machine can operate differently depending on the control values.

## 3. Input Variables

Input variables allow values to be supplied to a Terraform module.

Example:

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
```

The resource can then reference it:

```hcl
resource "aws_instance" "web" {
  instance_type = var.instance_type
}
```

Use:

```hcl
instance_type = var.instance_type
```

## 4. Variable Components

General syntax:

```hcl
variable "NAME" {
  description = "Description"
  type        = TYPE
  default     = VALUE
}
```

Example:

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
```

### `variable`

Declares the input variable.

### Name

```text
instance_type
```

### `description`

Documents the variable.

### `type`

Defines the expected type.

Examples:

```text
string
number
bool
list(string)
set(string)
map(string)
object(...)
```

### `default`

Defines a fallback value.

If a variable has no default, Terraform requires the value to be supplied. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/values/variables))

### Required Variables

A variable without a default is required unless supplied by another valid input mechanism.

Example:

```hcl
variable "ami_id" {
  description = "AMI ID for the EC2 instance."
  type        = string
}
```

If Terraform does not receive a value, it asks for one interactively or reports that a required variable is missing, depending on execution context.

## 5. Output Values

Output values expose information from a Terraform configuration.

Example:

```hcl
output "public_ip" {
  description = "Public IP of the EC2 instance."
  value       = aws_instance.web.public_ip
}
```

After:

```bash
terraform apply
```

Terraform can display:

```text
public_ip = "..."
```

Outputs are particularly useful for exposing information from child modules to parent modules. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/values/outputs))

## 6. Input vs Output

| Type           | Direction        | Purpose                   |
| -------------- | ---------------- | ------------------------- |
| Input variable | Into Terraform   | Customize configuration   |
| Output value   | Out of Terraform | Expose useful information |

Conceptually:

```text
Input Variables
      ↓
Terraform Configuration
      ↓
Infrastructure
      ↓
Output Values
```

## 7. Variable Validation

Modern Terraform configurations can validate input.

```hcl
variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

This prevents invalid configuration from reaching the deployment stage.

## 8. Sensitive Variables

Sensitive values can be marked:

```hcl
variable "database_password" {
  type      = string
  sensitive = true
}
```

However, `sensitive = true` does **not automatically mean the value is absent from state**. Terraform documentation explicitly notes that sensitive variable values can still be stored in state. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/values/variables))

Therefore, state security remains important.

## 9. Summary

```text
Input Variables
      ↓
Parameterize
      ↓
Reusable Terraform
      ↓
Infrastructure
      ↓
Output Values
```
