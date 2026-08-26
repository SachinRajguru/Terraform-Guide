
## Terraform Built-in Functions

**File:** 📄 `08-builtin-functions.md`

## Terraform Built-in Functions

## Table of Contents

1. [Overview](#1-overview)
2. [`concat()`](#2-concat)
3. [`element()`](#3-element)
4. [`length()`](#4-length)
5. [`map()` — Legacy Example](#5-map--legacy-example)
6. [`lookup()`](#6-lookup)
7. [`join()`](#7-join)
8. [`format()`](#8-format)
9. [String Functions](#9-string-functions)
10. [`contains()`](#10-contains)
11. [`try()`](#11-try)
12. [`can()`](#12-can)
13. [Additional Important Functions](#13-additional-important-functions)
14. [Functions and Conditional Expressions Together](#14-functions-and-conditional-expressions-together)
15. [Functions + Variables](#15-functions--variables)
16. [Practical Example](#16-practical-example)
17. [Functions + Conditionals](#17-functions--conditionals)
18. [Interactive Function Testing](#18-interactive-function-testing)
19. [Practical Lab](#19-practical-lab)
20. [Cleanup](#20-cleanup)
21. [Interview Questions](#21-interview-questions)

## 1. Overview

Terraform provides built-in functions for transforming and manipulating values.

General syntax:

```text
function_name(argument1, argument2)
```

Examples include:

```text
length()

concat()

join()

lookup()

element()

format()

contains()

lower()

upper()

trimspace()

toset()

tomap()

try()

can()
```

Terraform's current documentation provides the complete built-in function reference.

HashiCorp documents Terraform functions as expression functions that accept arguments and return values. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/expressions/function-calls?utm_source=chatgpt.com))

## 2. `concat()`

Combines lists.

```hcl
variable "list1" {
  type    = list(string)
  default = ["a", "b"]
}

variable "list2" {
  type    = list(string)
  default = ["c", "d"]
}

output "combined_list" {
  value = concat(var.list1, var.list2)
}
```

Result:

```text
["a", "b", "c", "d"]
```

## 3. `element()`

Returns an element from a collection.

```hcl
variable "fruits" {
  type    = list(string)
  default = ["apple", "banana", "cherry"]
}

output "selected_element" {
  value = element(var.fruits, 1)
}
```

Result:

```text
banana
```

Indexes are zero-based:

```text
0 -> apple

1 -> banana

2 -> cherry
```

### Professional recommendation

For straightforward indexing, modern Terraform code will often be clearer using:

```hcl
var.fruits[1]
```

rather than:

```hcl
element(var.fruits, 1)
```

The `element` function remains useful for its specific semantics, but direct indexing is often more readable.

## 4. `length()`

Returns the length of a collection or string.

```hcl
variable "fruits" {
  type    = list(string)
  default = ["apple", "banana", "cherry"]
}

output "fruit_count" {
  value = length(var.fruits)
}
```

Result:

```text
3
```

`length()` is especially useful in conditional logic and validation.

Example:

```hcl
condition = length(var.subnet_ids) > 0
```

## 5. `map()` — Legacy Example

Older Terraform material sometimes demonstrates:

```text
map(...)
```

for constructing maps.

### Historical status

The `map()` function was used in older Terraform versions for constructing maps. The old function-style syntax is no longer valid in modern Terraform and was removed with the language changes introduced in Terraform 0.12.

Modern Terraform uses map/object literals instead:

```hcl
locals {
  user = {
    name = "Alice"
    age  = 30
  }
}
```

or:

```hcl
variable "tags" {
  type = map(string)

  default = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

We can also use `tomap()` when an explicit conversion to a map is required:

```hcl
locals {
  user = tomap({
    name = "Alice"
    age  = "30"
  })
}
```

For two lists of keys and values, `zipmap()` can be used:

```hcl
locals {
  keys   = ["name", "age"]
  values = ["Alice", "30"]

  user = zipmap(local.keys, local.values)
}
```

**Status**

**Legacy approach:** `map(...)`

**Recommended modern approach:** map/object literals.

**Other modern functions:** `tomap()` and `zipmap()` where appropriate.

Do not copy older examples mechanically into modern Terraform projects.

> **Historical note:** We retain `map()` here because older Terraform learning material and older projects may contain it. Understanding this history helps us recognize and migrate legacy Terraform code.

## 6. `lookup()`

Retrieves a value from a map.

```hcl
variable "settings" {
  type = map(string)

  default = {
    environment = "dev"
    owner       = "platform-team"
  }
}

output "environment" {
  value = lookup(var.settings, "environment")
}
```

A default can also be provided:

```hcl
lookup(var.settings, "region", "us-east-1")
```

A modern alternative in many cases is direct indexing:

```hcl
var.settings["environment"]
```

If a fallback is required:

```hcl
lookup(var.settings, "environment", "Unknown")
```

## 7. `join()`

Converts a list of strings into one string.

```hcl
variable "names" {
  type    = list(string)
  default = ["terraform", "aws", "project"]
}

output "project_name" {
  value = join("-", var.names)
}
```

Result:

```text
terraform-aws-project
```

This is useful for:

* resource names
* tags
* identifiers
* strings generated from lists

HashiCorp documents `join` as a function that concatenates list elements using a separator.

## 8. `format()`

```hcl
output "summary" {
  value = format(
    "Environment %s uses region %s",
    var.environment,
    var.region
  )
}
```

Terraform's `format` function follows formatting-specification semantics similar to `printf`-style formatting.

## 9. String Functions

### `lower()`

```hcl
lower("PRODUCTION")
```

Result:

```text
production
```

### `upper()`

```hcl
upper("production")
```

Result:

```text
PRODUCTION
```

### `trimspace()`

```hcl
trimspace("  terraform  ")
```

Result:

```text
terraform
```

## 10. `contains()`

```hcl
contains(
  ["dev", "staging", "prod"],
  var.environment
)
```

This is useful for validation:

```hcl
validation {
  condition = contains(
    ["dev", "staging", "prod"],
    var.environment
  )

  error_message = "Environment must be dev, staging, or prod."
}
```

## 11. `try()`

Useful when an expression may not exist.

Example:

```hcl
output "secondary_ip" {
  value = try(aws_instance.secondary[0].public_ip, null)
}
```

This can be useful with conditionally-created resources.

## 12. `can()`

`can()` tests whether an expression can be evaluated successfully.

Example:

```hcl
condition = can(var.instance_type)
```

Terraform documents `can()` as useful for turning expression validity into a Boolean condition.

## 13. Additional Important Functions

A professional Terraform engineer should also become familiar with:

```text
contains

distinct

flatten

keys

values

merge

range

reverse

split

lower

upper

trim

replace

format

regex

can

try

toset

tolist

tomap

tostring

tonumber
```

Terraform's current function reference contains a much larger collection of functions.

The complete and current list should always be checked in the official Terraform function reference because Terraform's expression language continues to evolve.

## 14. Functions and Conditional Expressions Together

Example:

```hcl
locals {
  normalized_environment = lower(trimspace(var.environment))

  instance_type = contains(
    ["prod", "production"],
    local.normalized_environment
  ) ? "t3.medium" : "t3.micro"
}
```

This combines:

```text
trimspace()

      ↓

lower()

      ↓

contains()

      ↓

conditional expression

      ↓

selected value
```

This is where Terraform's expression language becomes particularly powerful.

## 15. Functions + Variables

```hcl
variable "names" {
  type = list(string)

  default = [
    "web",
    "api",
    "database"
  ]
}

output "server_count" {
  value = length(var.names)
}
```

Result:

```text
3
```

## 16. Practical Example

Suppose:

```hcl
variable "environment" {
  type = string
}

variable "application" {
  type = string
}
```

We can construct a standardized resource name:

```hcl
locals {
  resource_name = join(
    "-",
    [
      var.application,
      var.environment
    ]
  )
}
```

For:

```text
application = "payments"

environment = "prod"
```

we get:

```text
payments-prod
```

## 17. Functions + Conditionals

Functions become especially powerful when combined with conditionals.

Example:

```hcl
locals {
  environment_name = lower(var.environment)

  subnet_count = var.environment == "prod"
    ? 3
    : 1
}
```

Now infrastructure behavior can be driven from reusable inputs.

## 18. Interactive Function Testing

Terraform provides:

```text
terraform console
```

Example:

```text
> length(["a", "b", "c"])
3
```

Another:

```text
> lower("TERRAFORM")
"terraform"
```

Another:

```text
> join("-", ["terraform", "aws", "lab"])
"terraform-aws-lab"
```

`terraform console` is particularly useful for testing expressions before placing them into a resource.

Exit:

```text
exit
```

## 19. Practical Lab

Create:

```text
functions-lab/

├── versions.tf

├── variables.tf

├── locals.tf

└── outputs.tf
```

### `variables.tf`

```hcl
variable "environment" {
  type    = string
  default = " DEV "
}

variable "names" {
  type = list(string)

  default = [
    "terraform",
    "aws",
    "advanced"
  ]
}
```

### `locals.tf`

```hcl
locals {
  normalized_environment = lower(trimspace(var.environment))

  project_name = join("-", var.names)

  environment_count = length(var.names)
}
```

### `outputs.tf`

```hcl
output "normalized_environment" {
  value = local.normalized_environment
}

output "project_name" {
  value = local.project_name
}

output "element_count" {
  value = local.environment_count
}
```

### Run

```text
terraform init
```

```text
terraform fmt
```

```text
terraform validate
```

```text
terraform plan
```

Or test individual expressions:

```text
terraform console
```

## 20. Cleanup

This function lab creates no cloud resources.

Remove only temporary Terraform initialization artifacts if desired:

```text
.terraform/
```

On Windows PowerShell:

```powershell
Remove-Item -Recurse -Force .terraform
```

On Linux/macOS/WSL:

```bash
rm -rf .terraform
```

Do not remove:

```text
.terraform.lock.hcl
```

if the directory is intended to remain a repository.

Do **not** remove `.terraform.lock.hcl` unless intentionally resetting dependency selections.

## 21. Interview Questions

**What are Terraform built-in functions?**

Functions provided by the Terraform language for transforming and manipulating values.

**Name five Terraform functions.**

```text
length

concat

join

lookup

format
```

**How can we test Terraform expressions interactively?**

```text
terraform console
```

**Is `map()` the preferred modern approach for creating maps?**

No. Modern Terraform generally uses map/object literals.

**When is `length()` useful?**

For determining collection size and for validation/conditional expressions.

**What is the modern alternative to the old `map()` function?**

Modern Terraform generally uses map/object literals. `tomap()` can be used when an explicit conversion to a map is required, and `zipmap()` can be used to construct a map from separate lists of keys and values.

**Is `element()` always required for list indexing?**

No. For straightforward indexing, direct indexing such as:

```hcl
var.fruits[1]
```

is often clearer. The `element()` function remains available for its specific semantics.

**What is the purpose of `try()`?**

`try()` allows us to evaluate multiple expressions and return the first expression that does not produce an error.

**What is the purpose of `can()`?**

`can()` tests whether an expression can be evaluated successfully and returns a Boolean result.

**Why should we use Terraform built-in functions?**

They allow Terraform expressions to transform, validate, combine, normalize, and manipulate values without requiring external scripting for many common infrastructure-configuration tasks.
