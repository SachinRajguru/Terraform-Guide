
## Terraform `.tfvars` Files

**File:** 📄 `06-tfvars.md`

## Table of Contents

1. [Introduction](#1-introduction)
2. [`terraform.tfvars`](#2-terraformtfvars)
3. [Environment-Specific Files](#3-environment-specific-files)
4. [Example](#4-example)
5. [Sensitive Values](#5-sensitive-values)
6. [Variable Precedence](#6-variable-precedence)
7. [`.terraform.lock.hcl`](#7-terraformlockhcl)
8. [`.gitignore`](#8-gitignore)
9. [Recommended Environment Pattern](#9-recommended-environment-pattern)

## 1. Introduction

Terraform variable definition files allow configuration values to be separated from Terraform configuration code.

> A `.tfvars` file supplies values for Terraform input variables.

For example:

```text
Terraform code
     │
     ├── Resource logic
     └── Variable definitions
  +
Variable values
     │
     └── terraform.tfvars
```

Instead of:

```hcl
resource "aws_instance" "web" {
  instance_type = "t3.micro"
}
```

we can use:

```hcl
resource "aws_instance" "web" {
  instance_type = var.instance_type
}
```

and supply:

```hcl
instance_type = "t3.micro"
```

through a variable definition file.

## 2. `terraform.tfvars`

Terraform automatically loads:

```text
terraform.tfvars
```

and:

```text
terraform.tfvars.json
```

as well as files matching:

```text
*.auto.tfvars
*.auto.tfvars.json
```

according to Terraform's variable-loading rules. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/values/variables))

This makes them convenient for automatically loaded variable values.

Example:

```hcl
aws_region   = "us-east-1"
instance_type = "t3.micro"
ami_id        = "ami-xxxxxxxxxxxxxxxxx"
```

## 3. Environment-Specific Files

A project can use:

```text
dev.tfvars
staging.tfvars
prod.tfvars
```

Example:

```text
dev.tfvars
```

```hcl
instance_type = "t3.micro"
```

and:

```text
prod.tfvars
```

```hcl
instance_type = "t3.medium"
```

and explicitly select one. 

Because `dev.tfvars` is not automatically loaded merely because it has `.tfvars`, we explicitly specify it:

```bash
terraform plan -var-file="dev.tfvars"
```

or:

```bash
terraform apply -var-file="dev.tfvars"
```

HashiCorp documents `-var-file` as one supported method of assigning root-module variables. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/values/variables))

### Command-Line Variables

We can also pass values directly:

```powershell
terraform plan -var="instance_type=t3.micro"
```

This is useful for temporary overrides.

## 4. Example

### `variables.tf`

```hcl
variable "environment" {
  type        = string
  description = "Deployment environment."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type."
}
```

### `dev.tfvars`

```hcl
environment   = "dev"
instance_type = "t3.micro"
```

### `prod.tfvars`

```hcl
environment   = "prod"
instance_type = "t3.large"
```

The Terraform code remains unchanged.

## 5. Sensitive Values

`.tfvars` files can contain sensitive values, but that does **not** make them automatically secure.

For example:

```hcl
database_password = "SuperSecret123"
```

> should not normally be committed to Git.

Instead:

```text
*.tfvars
```

can be ignored where appropriate, while a safe example file such as:

```text
terraform.tfvars.example
```

can be committed.

Terraform's documentation specifically recommends ensuring sensitive variable definition files are ignored by version control. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/values/variables))

> **Important:** Marking a variable as sensitive = true does not by itself prevent the value from being stored in Terraform state. Sensitive values should therefore be handled using an appropriate secrets-management and state-security strategy.

## 6. Variable Precedence

Terraform supports several variable sources.

The important precedence order includes:

```text
-var / -var-file
      ↓
*.auto.tfvars / *.auto.tfvars.json
      ↓
terraform.tfvars.json
      ↓
terraform.tfvars
      ↓
TF_VAR_* environment variables
      ↓
variable default
```

When multiple values are supplied for the same variable, the higher-precedence value overrides the lower-precedence value.

Within automatically loaded `.auto.tfvars` files, Terraform processes files in lexical order, with later values taking precedence when the same variable is assigned more than once.

The command line and HCP Terraform variable mechanisms have higher precedence than lower-level defaults. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/values/variables))

## 7. `.terraform.lock.hcl`

The Terraform dependency lock file:

```text
.terraform.lock.hcl
```

should normally be committed to version control.

It records the selected provider versions and provider checksums, helping ensure consistent provider installation across environments.

Therefore, we should **not** add `.terraform.lock.hcl` to `.gitignore`.

## 8. `.gitignore`

Example:

```gitignore
.terraform/

*.tfstate
*.tfstate.*

crash.log
crash.*.log

terraform.tfvars
*.auto.tfvars
```

We should normally commit:

```text
.terraform.lock.hcl
```

and therefore it should **not** be included in `.gitignore`.

## 9. Recommended Environment Pattern

For a learning project:

```text
project/

├── versions.tf
├── providers.tf
├── variables.tf
├── main.tf
├── outputs.tf
├── terraform.tfvars.example
├── dev.tfvars.example
└── .gitignore
```

For larger production environments, we should consider a proper environment and module architecture rather than creating an uncontrolled collection of `.tfvars` files.
