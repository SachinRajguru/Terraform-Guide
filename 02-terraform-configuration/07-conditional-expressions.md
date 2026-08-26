## Terraform Conditional Expressions

**File:** 📄 `07-conditional-expressions.md`

## Terraform Conditional Expressions

## Table of Contents

1. [Overview](#1-overview)
2. [Programming Analogy](#2-programming-analogy)
3. [Basic Example](#3-basic-example)
4. [Conditional Resource Creation](#4-conditional-resource-creation)
5. [Production Versus Development](#5-production-versus-development)
6. [SSH Example](#6-ssh-example)
7. [S3 Example](#7-s3-example)
8. [Logical Operators](#8-logical-operators)
9. [Conditional Type Rules](#9-conditional-type-rules)
10. [Validation](#10-validation)
11. [Practical Lab](#11-practical-lab)
12. [Cleanup](#12-cleanup)
13. [Common Mistakes](#13-common-mistakes)
14. [Enterprise Interpretation](#14-enterprise-interpretation)
15. [Interview Questions](#15-interview-questions)

## 1. Overview

Terraform is declarative, but its expression language supports decision-making.

The core conditional expression syntax is:

```text
condition ? true_value : false_value
```

HashiCorp defines this as selecting one of two values based on a Boolean condition. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/expressions/conditionals))

A conditional expression evaluates the condition and returns either the `true_value` or the `false_value`.

## 2. Programming Analogy

Traditional programming:

```text
if condition:

    value A

else:

    value B
```

Terraform:

```text
condition ? value_a : value_b
```

Terraform conditional expressions are conceptually similar to an `if/else` decision, but Terraform configuration uses expressions rather than general-purpose imperative statements.

## 3. Basic Example

```hcl
variable "environment" {
  type    = string
  default = "dev"
}

locals {
  instance_type = var.environment == "prod"
    ? "t3.medium"
    : "t3.micro"
}
```

Then:

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = local.instance_type
}
```

If:

```text
environment = "prod"
```

then:

```text
instance_type = "t3.medium"
```

Otherwise:

```text
instance_type = "t3.micro"
```

## 4. Conditional Resource Creation

```hcl
variable "create_instance" {
  type    = bool
  default = true
}

resource "aws_instance" "example" {
  count         = var.create_instance ? 1 : 0
  ami           = var.ami_id
  instance_type = var.instance_type
}
```

If:

```text
create_instance = true
```

then:

```text
count = 1
```

If:

```text
create_instance = false
```

then:

```text
count = 0
```

This is a common Terraform pattern for conditionally creating a resource.

> **Important:** `count = 0` means that Terraform creates zero instances of that resource. The resource block remains in the configuration, but no resource instance is created when the count evaluates to zero.

## 5. Production Versus Development

```hcl
variable "environment" {
  type    = string
  default = "dev"
}

variable "production_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "development_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}
```

Use:

```hcl
cidr_blocks = var.environment == "production"
  ? [var.production_subnet_cidr]
  : [var.development_subnet_cidr]
```

This allows the configuration to select different values based on the environment.

## 6. SSH Example

```hcl
variable "enable_ssh" {
  type    = bool
  default = false
}

resource "aws_security_group" "example" {
  name        = "terraform-conditional-sg"
  description = "Security group demonstrating conditional configuration."

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.enable_ssh
      ? ["10.0.0.0/16"]
      : []
  }
}
```

Avoid:

```text
0.0.0.0/0
```

for SSH in production unless there is a deliberate security architecture requiring it.

### Security Warning

Although this demonstrates conditional expressions, exposing SSH to:

```text
0.0.0.0/0
```

is generally unsafe for production.

Prefer:

```text
VPN

Bastion

SSM

Private connectivity

Approved corporate CIDR
```

> **Historical note:** Older Terraform/AWS learning material commonly demonstrated SSH using `0.0.0.0/0`. We retain the concept because it may appear in older examples, but it should not be copied mechanically into modern production infrastructure.

## 7. S3 Example

Conceptually:

```hcl
public_access = var.environment == "dev"
  ? true
  : false
```

This illustrates a common requirement:

```text
Development

    │

    └── relaxed configuration for testing

Production

    │

    └── hardened configuration
```

The original material uses public S3 access as a teaching example.

For real S3 implementations, use the current AWS provider resources and modern S3 security controls rather than copying old provider examples blindly.

For real production systems, public access should be treated as an explicit security exception, not a default.

> **Historical note:** Older AWS/Terraform examples sometimes demonstrated S3 public access directly through resource arguments that are no longer the preferred approach. Modern AWS S3 security should use the current AWS provider resources and controls, including appropriate Block Public Access and bucket policy configuration.

## 8. Logical Operators

Terraform supports:

```text
&&

||

!
```

Example:

```hcl
condition = var.environment == "prod" && var.enable_monitoring
```

Logical operators can be combined with conditional expressions to build more expressive configuration logic.

For example:

```hcl
locals {
  instance_type = var.environment == "prod" && var.enable_monitoring
    ? "t3.medium"
    : "t3.micro"
}
```

HashiCorp documents logical operators and their use within Terraform expressions.

## 9. Conditional Type Rules

The two result values should normally have compatible types.

For example:

```hcl
var.enabled ? "yes" : "no"
```

is straightforward.

HashiCorp explains that Terraform determines the resulting type of a conditional expression from both result branches.

For example:

```hcl
var.enabled ? "yes" : 0
```

should not be used simply because the values represent different concepts. Prefer branches with compatible and intentional types.

## 10. Validation

Terraform also supports variable validation.

Example:

```hcl
variable "environment" {
  type        = string
  description = "Deployment environment"

  validation {
    condition = contains(
      ["dev", "stage", "prod"],
      var.environment
    )

    error_message = "Environment must be dev, stage, or prod."
  }
}
```

This is preferable to allowing arbitrary values.

Terraform supports input variable validation, preconditions, postconditions, and check blocks depending on the Terraform version.

> **Beginner note:** Variable validation checks an input variable when Terraform evaluates the variable. Preconditions and postconditions can validate assumptions about resources and other expressions, while `check` blocks provide broader validation checks that can produce warnings rather than blocking execution in the same way as validation or assertions.

## 11. Practical Lab

Create:

```text
conditional-lab/

├── versions.tf
├── providers.tf
├── variables.tf
└── main.tf
```

Implement:

```text
create_instance = true
```

Then:

```text
terraform init
```

```text
terraform fmt
```

```text
terraform validate
```

Run:

```text
terraform plan
```

Change:

```text
create_instance = false
```

Run:

```text
terraform plan
```

Observe the resource count changing.

We can also test the environment condition:

```text
terraform plan -var="environment=dev"
```

Then:

```text
terraform plan -var="environment=prod"
```

Compare the plans.

## 12. Cleanup

If the instance was created:

```text
terraform destroy
```

If the configuration requires variables:

```text
terraform destroy -var="environment=dev"
```

> **Important:** `terraform destroy` must use the same required variable values needed to successfully load the configuration. If variables have suitable defaults or are supplied through automatically loaded variable files or another supported mechanism, an explicit `-var` argument may not be necessary.

## 13. Common Mistakes

### Incorrect

```text
if var.environment == "prod"
```

Terraform does not use traditional statement-style `if` blocks here.

### Correct

```hcl
var.environment == "prod"
  ? "production-value"
  : "non-production-value"
```

### Avoid excessively complex conditions

Prefer:

```hcl
local.selected_instance_type
```

over deeply nested conditional expressions.

For example, instead of creating a difficult-to-read expression containing multiple nested conditions, we can move the expression into a `local` value and give it a meaningful name.

## 14. Enterprise Interpretation

Conditional expressions allow a common Terraform configuration to adapt its behavior according to environment or configuration values.

```text
environment
      |
      +-- production
      |      |
      |      +-- hardened configuration
      |      +-- restricted CIDR
      |      +-- larger instance
      |
      +-- development
             |
             +-- development configuration
             +-- development CIDR
             +-- smaller instance
```

This allows us to keep Terraform configuration reusable while changing selected values according to the deployment environment.

## 15. Interview Questions

**Q1. What is Terraform's conditional expression syntax?**

```text
condition ? true_value : false_value
```

**Q2. Can conditional expressions control resource creation?**

Yes, commonly through:

```hcl
count = condition ? 1 : 0
```

They can also be used with other Terraform constructs to conditionally select values.

**Q3. Why use conditionals?**

To make infrastructure behavior adapt to environments or configuration values.

**Q4. Is Terraform's conditional expression the same as a traditional `if` statement?**

Conceptually similar, but Terraform configuration uses expressions rather than general-purpose imperative statements.

**Q5. What happens when `count` evaluates to `0`?**

Terraform creates zero resource instances for that resource block.

**Q6. Why should conditional result values have compatible types?**

Terraform must determine a resulting type for the conditional expression. Compatible and intentional types make the expression predictable and easier to maintain.

**Q7. What is the difference between variable validation and a conditional expression?**

A conditional expression selects between values based on a condition, while variable validation verifies whether an input variable satisfies a defined rule.

**Q8. Can conditional expressions be combined with functions?**

Yes. Terraform functions such as `lower()`, `trimspace()`, and `contains()` can be combined with conditional expressions to create reusable and dynamic configuration logic.
