
## Terraform Built-in Functions

> **File:** `08-built-in-functions.md`

## Table of Contents

1. [Introduction](#1-introduction)
2. [What Are Terraform Functions?](#2-what-are-terraform-functions)
3. [Function Syntax](#3-function-syntax)
4. [Function Categories](#4-function-categories)
5. [String Functions](#5-string-functions)
6. [Collection Functions](#6-collection-functions)
7. [Numeric Functions](#7-numeric-functions)
8. [Type Conversion Functions](#8-type-conversion-functions)
9. [Date and Time Functions](#9-date-and-time-functions)
10. [Encoding Functions](#10-encoding-functions)
11. [Filesystem Functions](#11-filesystem-functions)
12. [IP Network Functions](#12-ip-network-functions)
13. [Validation and Error-Handling Functions](#13-validation-and-error-handling-functions)
14. [Combining Functions](#14-combining-functions)
15. [Functions with Variables, Locals, and Conditionals](#15-functions-with-variables-locals-and-conditionals)
16. [Practical Example](#16-practical-example)
17. [Testing Functions with `terraform console`](#17-testing-functions-with-terraform-console)
18. [Common Mistakes and Troubleshooting](#18-common-mistakes-and-troubleshooting)
19. [Best Practices](#19-best-practices)
20. [Interview Questions](#20-interview-questions)
21. [Summary](#21-summary)

## 1. Introduction

Terraform configurations frequently need to transform, calculate, filter, combine, or validate values.

For example, we may need to:

* Convert a string to lowercase.
* Join multiple strings.
* Split a string into a list.
* Calculate the length of a collection.
* Check whether a list contains a value.
* Merge multiple maps.
* Select a value from a map.
* Convert one data type into another.
* Calculate numeric values.
* Manipulate IP addresses and CIDR ranges.
* Encode or decode data.
* Read a file.
* Generate formatted strings.

Terraform provides a large collection of **built-in functions** for these operations.

Instead of implementing our own logic externally, we can perform many common transformations directly inside Terraform expressions.

For example:

```hcl
lower(var.environment)
```

converts a string to lowercase.

Another example:

```hcl
length(var.subnets)
```

returns the number of elements in a collection.

Functions are therefore an important part of writing reusable and maintainable Terraform configurations.

### Learning Objectives

By the end of this section, we will understand:

* What Terraform built-in functions are.
* Terraform function syntax.
* Common Terraform function categories.
* String functions.
* Collection functions.
* Numeric functions.
* Type conversion functions.
* Date and time functions.
* Encoding functions.
* Filesystem functions.
* IP network functions.
* Validation and error-handling functions.
* How to combine multiple functions.
* How functions work with variables, locals, and conditionals.
* How to test functions using `terraform console`.
* Common mistakes and troubleshooting techniques.
* Best practices for using Terraform functions.

## 2. What Are Terraform Functions?

A Terraform function is a built-in operation that accepts one or more arguments and returns a value.

The general model is:

```text
              Function
                 │
        ┌────────┴────────┐
        │                 │
    Arguments         Processing
        │                 │
        └────────┬────────┘
                 ▼
              Result
```

For example:

```hcl
lower("HELLO")
```

returns:

```text
hello
```

Another example:

```hcl
length(["dev", "staging", "prod"])
```

returns:

```text
3
```

### 2.1 Why Functions Matter

Without functions, we would need to perform many transformations outside Terraform.

Functions allow us to keep infrastructure-related data processing close to the infrastructure definition.

For example:

```hcl
locals {
  resource_name = lower("${var.project_name}-${var.environment}")
}
```

This can generate a normalized resource name directly inside Terraform.

## 3. Function Syntax

Terraform functions use this general syntax:

```hcl
function_name(argument1, argument2, ...)
```

For example:

```hcl
lower("TERRAFORM")
```

or:

```hcl
join("-", ["terraform", "dev", "app"])
```

The function name comes first, followed by parentheses containing the arguments.

### 3.1 Single Argument

Example:

```hcl
length("Terraform")
```

Result:

```text
9
```

### 3.2 Multiple Arguments

Example:

```hcl
max(10, 20, 30)
```

Result:

```text
30
```

### 3.3 Nested Functions

Terraform functions can be nested.

For example:

```hcl
lower(trimspace(var.environment))
```

Terraform evaluates the inner function first:

```text
trimspace()
     │
     ▼
Cleaned string
     │
     ▼
lower()
     │
     ▼
Lowercase string
```

This is very useful for normalizing input values.

## 4. Function Categories

Terraform provides functions for several common purposes.

| Category                  | Examples                                                   | Typical Use                |
| ------------------------- | ---------------------------------------------------------- | -------------------------- |
| String                    | `lower`, `upper`, `trimspace`, `replace`                   | Text manipulation          |
| Collection                | `length`, `contains`, `concat`, `merge`                    | Lists, sets, maps          |
| Numeric                   | `min`, `max`, `ceil`, `floor`                              | Numeric calculations       |
| Type Conversion           | `tostring`, `tonumber`, `tolist`, `toset`                  | Type conversion            |
| Date/Time                 | `timestamp`, `formatdate`                                  | Time-related values        |
| Encoding                  | `base64encode`, `base64decode`, `jsonencode`, `jsondecode` | Data encoding              |
| Filesystem                | `file`, `fileexists`, `fileset`                            | Reading local files        |
| IP Network                | `cidrsubnet`, `cidrhost`, `cidrnetmask`                    | Network calculations       |
| Validation/Error Handling | `can`, `try`                                               | Safe expression evaluation |

Terraform has additional specialized functions, but these categories cover many of the functions encountered in day-to-day infrastructure work.

## 5. String Functions

String functions are among the most frequently used Terraform functions.

### 5.1 `lower`

Converts a string to lowercase.

```hcl
lower("Terraform")
```

Result:

```text
terraform
```

Example:

```hcl
locals {
  environment = lower(var.environment)
}
```

If:

```text
var.environment = "PROD"
```

the result becomes:

```text
prod
```

### 5.2 `upper`

Converts a string to uppercase.

```hcl
upper("terraform")
```

Result:

```text
TERRAFORM
```

### 5.3 `trimspace`

Removes leading and trailing whitespace.

```hcl
trimspace("  terraform  ")
```

Result:

```text
terraform
```

This can be useful when normalizing input values.

### 5.4 `trim`

Removes characters from both ends of a string based on a specified set.

Example:

```hcl
trim("--terraform--", "-")
```

Result:

```text
terraform
```

### 5.5 `replace`

Replaces occurrences of a substring.

```hcl
replace("terraform-dev", "dev", "prod")
```

Result:

```text
terraform-prod
```

Example:

```hcl
locals {
  resource_name = replace(var.project_name, " ", "-")
}
```

This can help normalize resource names.

### 5.6 `join`

Combines list elements into a string using a delimiter.

```hcl
join("-", ["terraform", "dev", "app"])
```

Result:

```text
terraform-dev-app
```

This is very useful for generating resource names.

Example:

```hcl
locals {
  resource_name = join("-", [
    var.project_name,
    var.environment,
    "instance"
  ])
}
```

### 5.7 `split`

Splits a string into a list.

```hcl
split(",", "dev,staging,prod")
```

Result:

```text
[
  "dev",
  "staging",
  "prod"
]
```

This is useful when input arrives as a delimited string.

### 5.8 `format`

Creates a formatted string.

```hcl
format("%s-%s", "terraform", "dev")
```

Result:

```text
terraform-dev
```

Another example:

```hcl
format("%s-%s-%s", var.project_name, var.environment, "app")
```

### 5.9 `formatlist`

Formats every element in a list.

Example:

```hcl
formatlist("server-%s", ["01", "02", "03"])
```

Result:

```text
[
  "server-01",
  "server-02",
  "server-03"
]
```

### 5.10 `substr`

Extracts a portion of a string.

```hcl
substr("terraform", 0, 4)
```

Result:

```text
terr
```

String indexes begin at zero.

### 5.11 `startswith`

Checks whether a string starts with a specified prefix.

```hcl
startswith("terraform-dev", "terraform")
```

Result:

```text
true
```

### 5.12 `endswith`

Checks whether a string ends with a specified suffix.

```hcl
endswith("terraform-dev", "dev")
```

Result:

```text
true
```

## 6. Collection Functions

Terraform collections commonly include:

* Lists.
* Sets.
* Maps.
* Tuples.
* Objects.

Collection functions help us inspect and transform these structures.

### 6.1 `length`

Returns the number of elements.

List:

```hcl
length(["dev", "staging", "prod"])
```

Result:

```text
3
```

String:

```hcl
length("Terraform")
```

Result:

```text
9
```

Map:

```hcl
length({
  dev  = "t3.micro"
  prod = "t3.large"
})
```

Result:

```text
2
```

### 6.2 `contains`

Checks whether a collection contains a specified value.

```hcl
contains(["dev", "staging", "prod"], "prod")
```

Result:

```text
true
```

Example:

```hcl
variable "environment" {
  type = string

  validation {
    condition = contains(
      ["dev", "staging", "prod"],
      var.environment
    )

    error_message = "Environment must be dev, staging, or prod."
  }
}
```

This is a common Terraform validation pattern.

### 6.3 `concat`

Combines lists.

```hcl
concat(
  ["subnet-a", "subnet-b"],
  ["subnet-c", "subnet-d"]
)
```

Result:

```text
[
  "subnet-a",
  "subnet-b",
  "subnet-c",
  "subnet-d"
]
```

### 6.4 `merge`

Combines maps or objects.

```hcl
merge(
  {
    Environment = "dev"
  },
  {
    ManagedBy = "Terraform"
  }
)
```

Result:

```hcl
{
  Environment = "dev"
  ManagedBy   = "Terraform"
}
```

This is extremely useful for tags.

Example:

```hcl
locals {
  common_tags = {
    ManagedBy = "Terraform"
    Project   = "platform"
  }

  environment_tags = {
    Environment = var.environment
  }

  tags = merge(
    local.common_tags,
    local.environment_tags
  )
}
```

### 6.5 `keys`

Returns the keys of a map or object.

```hcl
keys({
  dev  = "t3.micro"
  prod = "t3.large"
})
```

Result:

```text
[
  "dev",
  "prod"
]
```

### 6.6 `values`

Returns the values of a map.

```hcl
values({
  dev  = "t3.micro"
  prod = "t3.large"
})
```

Result:

```text
[
  "t3.micro",
  "t3.large"
]
```

### 6.7 `lookup`

Retrieves a value from a map.

```hcl
lookup(
  {
    dev  = "t3.micro"
    prod = "t3.large"
  },
  "prod"
)
```

Result:

```text
t3.large
```

A default value can also be supplied:

```hcl
lookup(
  {
    dev  = "t3.micro"
    prod = "t3.large"
  },
  "staging",
  "t3.small"
)
```

Result:

```text
t3.small
```

### 6.8 `flatten`

Flattens nested lists.

Example:

```hcl
flatten([
  ["subnet-a", "subnet-b"],
  ["subnet-c", "subnet-d"]
])
```

Result:

```text
[
  "subnet-a",
  "subnet-b",
  "subnet-c",
  "subnet-d"
]
```

This is useful when building collections dynamically.

### 6.9 `distinct`

Removes duplicate values.

```hcl
distinct([
  "dev",
  "prod",
  "dev",
  "staging"
])
```

Result:

```text
[
  "dev",
  "prod",
  "staging"
]
```

### 6.10 `sort`

Sorts a list of strings.

```hcl
sort([
  "prod",
  "dev",
  "staging"
])
```

Result:

```text
[
  "dev",
  "prod",
  "staging"
]
```

### 6.11 `element`

Returns an element from a list or tuple by index.

```hcl
element(
  ["subnet-a", "subnet-b", "subnet-c"],
  1
)
```

Result:

```text
subnet-b
```

For ordinary indexing, direct indexing such as:

```hcl
var.subnets[1]
```

is often clearer.

## 7. Numeric Functions

Terraform also provides functions for numeric operations.

### 7.1 `min`

Returns the smallest number.

```hcl
min(10, 20, 5)
```

Result:

```text
5
```

### 7.2 `max`

Returns the largest number.

```hcl
max(10, 20, 5)
```

Result:

```text
20
```

### 7.3 `abs`

Returns the absolute value.

```hcl
abs(-10)
```

Result:

```text
10
```

### 7.4 `ceil`

Rounds a number upward.

```hcl
ceil(10.2)
```

Result:

```text
11
```

### 7.5 `floor`

Rounds a number downward.

```hcl
floor(10.8)
```

Result:

```text
10
```

### 7.6 `signum`

Returns:

```text
-1
```

for negative numbers,

```text
0
```

for zero, and

```text
1
```

for positive numbers.

Example:

```hcl
signum(-50)
```

Result:

```text
-1
```

## 8. Type Conversion Functions

Terraform uses a type system.

Sometimes we need to explicitly convert a value from one type to another.

### 8.1 `tostring`

Converts a value to a string.

```hcl
tostring(100)
```

Result:

```text
"100"
```

### 8.2 `tonumber`

Converts a value to a number.

```hcl
tonumber("100")
```

Result:

```text
100
```

### 8.3 `tobool`

Converts a value to a Boolean.

```hcl
tobool("true")
```

Result:

```text
true
```

### 8.4 `tolist`

Converts a value to a list when Terraform can perform the conversion.

Example:

```hcl
tolist(toset(["dev", "prod"]))
```

Result:

```text
[
  "dev",
  "prod"
]
```

### 8.5 `toset`

Converts a collection to a set.

```hcl
toset([
  "dev",
  "prod",
  "dev"
])
```

The resulting set contains unique values:

```text
[
  "dev",
  "prod"
]
```

A set is unordered, so we should not depend on element ordering.

### 8.6 `tomap`

Converts a compatible value to a map.

Example:

```hcl
tomap({
  environment = "dev"
  project     = "terraform"
})
```

## 9. Date and Time Functions

Terraform provides functions for working with timestamps and date formatting.

### 9.1 `timestamp`

Returns the current timestamp.

```hcl
timestamp()
```

Example result:

```text
2026-09-02T12:00:00Z
```

The exact result changes whenever Terraform evaluates the expression.

#### Important

`timestamp()` is not appropriate for generating a value that should remain stable across plans.

If a value needs to remain stable, we should not casually use a continuously changing timestamp in resource arguments.

### 9.2 `formatdate`

Formats a timestamp.

Example:

```hcl
formatdate(
  "YYYY-MM-DD",
  "2026-09-02T12:00:00Z"
)
```

Result:

```text
2026-09-02
```

## 10. Encoding Functions

Encoding functions are useful when infrastructure resources require data in a particular representation.

### 10.1 `base64encode`

Encodes a string as Base64.

```hcl
base64encode("terraform")
```

### 10.2 `base64decode`

Decodes a Base64 string.

```hcl
base64decode("dGVycmFmb3Jt")
```

Result:

```text
terraform
```

### 10.3 `jsonencode`

Converts a Terraform value into JSON.

Example:

```hcl
jsonencode({
  environment = "dev"
  project     = "terraform"
})
```

Result is a JSON string representing the object.

This is especially useful when a cloud resource expects JSON-formatted configuration.

### 10.4 `jsondecode`

Converts a JSON string into a Terraform value.

Example:

```hcl
jsondecode(
  "{\"environment\":\"dev\"}"
)
```

Result:

```text
{
  environment = "dev"
}
```

### 10.5 YAML Encoding and Decoding

Terraform also provides:

```hcl
yamlencode(...)
```

and:

```hcl
yamldecode(...)
```

These are useful when working with Kubernetes manifests, configuration files, or other YAML-based systems.

Example:

```hcl
yamlencode({
  environment = "dev"
})
```

This generates YAML-formatted text.

## 11. Filesystem Functions

Terraform can read files from the local filesystem using built-in functions.

### 11.1 `file`

Reads the contents of a file as a string.

Example:

```hcl
file("${path.module}/user-data.sh")
```

This is useful for supplying file contents to resources.

For example:

```hcl
resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = var.instance_type

  user_data = file("${path.module}/user-data.sh")
}
```

### 11.2 `fileexists`

Checks whether a file exists.

```hcl
fileexists("${path.module}/user-data.sh")
```

Result:

```text
true
```

or:

```text
false
```

### 11.3 `fileset`

Returns a set of filenames matching a pattern.

Example:

```hcl
fileset("${path.module}/scripts", "*.sh")
```

This can be useful when working with multiple files.

### 11.4 Important Filesystem Consideration

Terraform functions that read files operate on files that are available when Terraform evaluates the configuration.

They should not be treated as a general-purpose remote file retrieval mechanism.

If a file is generated dynamically during the same Terraform run, a simple `file()` expression may not be the appropriate solution.

## 12. IP Network Functions

Terraform provides functions that are especially useful when designing cloud networking.

These functions work with CIDR notation.

For example:

```text
10.0.0.0/16
```

represents a network range.

### 12.1 `cidrsubnet`

Creates a subnet range from a larger CIDR network.

Example:

```hcl
cidrsubnet("10.0.0.0/16", 8, 1)
```

The exact result depends on the CIDR calculation parameters.

A common pattern is:

```hcl
cidrsubnet(
  var.vpc_cidr,
  8,
  1
)
```

This can be used to calculate subnet CIDRs from a VPC CIDR.

### 12.2 `cidrhost`

Returns an IP address within a CIDR range.

Example:

```hcl
cidrhost("10.0.0.0/24", 10)
```

Result:

```text
10.0.0.10
```

### 12.3 `cidrnetmask`

Returns the netmask associated with a CIDR range.

Example:

```hcl
cidrnetmask("10.0.0.0/24")
```

Result:

```text
255.255.255.0
```

### 12.4 Why CIDR Functions Matter

In real-world AWS and Azure environments, networking often needs to be generated systematically.

For example:

```text
VPC
10.0.0.0/16
    │
    ├── Public Subnet
    │     └── 10.0.1.0/24
    │
    ├── Private Subnet
    │     └── 10.0.2.0/24
    │
    └── Database Subnet
          └── 10.0.3.0/24
```

Functions such as `cidrsubnet` allow us to calculate these ranges instead of hardcoding every CIDR.

## 13. Validation and Error-Handling Functions

Some Terraform functions help us safely evaluate expressions.

### 13.1 `can`

`can` determines whether an expression can be evaluated successfully.

Example:

```hcl
can(tonumber(var.port))
```

If the conversion succeeds:

```text
true
```

If the expression would produce an error:

```text
false
```

This can be useful in validation logic.

### 13.2 `try`

`try` evaluates expressions in order and returns the first one that succeeds.

Example:

```hcl
try(
  var.configuration.name,
  "default-name"
)
```

If:

```text
var.configuration.name
```

can be evaluated, Terraform uses it.

Otherwise:

```text
default-name
```

is returned.

### 13.3 `can` vs `try`

A simple distinction is:

```text
can()
│
└── Asks: "Can this expression succeed?"

try()
│
└── Asks: "Give me the first expression that succeeds."
```

Example:

```hcl
can(tonumber(var.port))
```

returns a Boolean.

Whereas:

```hcl
try(tonumber(var.port), 8080)
```

returns a value.

## 14. Combining Functions

Terraform functions become especially powerful when combined.

For example:

```hcl
lower(
  trimspace(
    var.environment
  )
)
```

Terraform evaluates:

```text
var.environment
      │
      ▼
trimspace()
      │
      ▼
lower()
      │
      ▼
Normalized value
```

### 14.1 Example: Generate a Resource Name

```hcl
locals {
  resource_name = lower(
    join("-", [
      trimspace(var.project_name),
      trimspace(var.environment),
      "instance"
    ])
  )
}
```

If:

```text
project_name = "Terraform Demo"
environment  = "PROD"
```

the result is conceptually:

```text
terraform demo-prod-instance
```

If resource naming rules require spaces to be removed or replaced, we can add `replace()`:

```hcl
locals {
  project_name_normalized = replace(
    lower(trimspace(var.project_name)),
    " ",
    "-"
  )

  resource_name = join("-", [
    local.project_name_normalized,
    lower(trimspace(var.environment)),
    "instance"
  ])
}
```

Result:

```text
terraform-demo-prod-instance
```

## 15. Functions with Variables, Locals, and Conditionals

Functions become much more useful when combined with the Terraform features we learned in previous sections.

### 15.1 Functions with Variables

```hcl
variable "environment" {
  type = string
}

locals {
  normalized_environment = lower(trimspace(var.environment))
}
```

This allows us to accept values such as:

```text
 PROD
Prod
prod
```

and normalize them to:

```text
prod
```

### 15.2 Functions with Conditionals

Example:

```hcl
locals {
  instance_type = var.environment == "prod"
    ? "t3.large"
    : "t3.micro"
}
```

We can also use a function:

```hcl
locals {
  instance_type = lower(var.environment) == "prod"
    ? "t3.large"
    : "t3.micro"
}
```

This makes the comparison case-insensitive after normalization.

### 15.3 Functions with Maps

Using `lookup`:

```hcl
locals {
  instance_types = {
    dev     = "t3.micro"
    staging = "t3.small"
    prod    = "t3.large"
  }

  instance_type = lookup(
    local.instance_types,
    lower(var.environment),
    "t3.micro"
  )
}
```

This combines:

* Map.
* `lookup`.
* `lower`.
* Variable.
* Local value.

### 15.4 Functions with `merge`

A common tagging pattern is:

```hcl
locals {
  common_tags = {
    ManagedBy = "Terraform"
    Project   = "platform"
  }

  environment_tags = {
    Environment = var.environment
  }

  tags = merge(
    local.common_tags,
    local.environment_tags
  )
}
```

Resources can then use:

```hcl
tags = local.tags
```

This is a clean and reusable pattern.

## 16. Practical Example

Let's build a small project that combines several Terraform functions.

### 16.1 Project Structure

```text
built-in-functions-demo/
├── versions.tf
├── providers.tf
├── variables.tf
├── locals.tf
├── main.tf
├── outputs.tf
└── terraform.tfvars.example
```

### 16.2 `versions.tf`

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

### 16.3 `providers.tf`

```hcl
provider "aws" {
  region = var.aws_region
}
```

### 16.4 `variables.tf`

```hcl
variable "aws_region" {
  description = "AWS region where resources will be deployed."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition = contains(
      ["dev", "staging", "prod"],
      lower(trimspace(var.environment))
    )

    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "ami_id" {
  description = "AMI ID available in the selected AWS region."
  type        = string
}

variable "instance_type" {
  description = "Base EC2 instance type."
  type        = string
  default     = "t3.micro"
}
```

### 16.5 `locals.tf`

```hcl
locals {
  normalized_project_name = replace(
    lower(trimspace(var.project_name)),
    " ",
    "-"
  )

  normalized_environment = lower(
    trimspace(var.environment)
  )

  resource_name = join("-", [
    local.normalized_project_name,
    local.normalized_environment,
    "instance"
  ])

  environment_instance_types = {
    dev     = "t3.micro"
    staging = "t3.small"
    prod    = "t3.large"
  }

  selected_instance_type = lookup(
    local.environment_instance_types,
    local.normalized_environment,
    var.instance_type
  )

  common_tags = {
    ManagedBy = "Terraform"
    Project   = local.normalized_project_name
  }

  environment_tags = {
    Environment = local.normalized_environment
  }

  tags = merge(
    local.common_tags,
    local.environment_tags
  )
}
```

This demonstrates several functions:

```text
trimspace()
lower()
replace()
join()
lookup()
merge()
```

### 16.6 `main.tf`

```hcl
resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = local.selected_instance_type

  tags = merge(
    local.tags,
    {
      Name = local.resource_name
    }
  )
}
```

### 16.7 `outputs.tf`

```hcl
output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.example.id
}

output "instance_type" {
  description = "Selected EC2 instance type."
  value       = local.selected_instance_type
}

output "resource_name" {
  description = "Generated resource name."
  value       = local.resource_name
}

output "tags" {
  description = "Tags assigned to the instance."
  value       = local.tags
}
```

### 16.8 `terraform.tfvars.example`

```hcl
aws_region    = "us-east-1"
project_name  = "Terraform Demo"
environment   = "dev"
ami_id        = "ami-xxxxxxxxxxxxxxxxx"
instance_type = "t3.micro"
```

Replace the AMI placeholder with a valid AMI available in the selected AWS region.

### 16.9 Initialize Terraform

Run:

```bash
terraform init
```

### 16.10 Format the Configuration

Run:

```bash
terraform fmt
```

### 16.11 Validate the Configuration

Run:

```bash
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

### 16.12 Create the Plan

Run:

```bash
terraform plan
```

Terraform evaluates the functions and produces the resulting configuration.

For example:

```text
project_name = "Terraform Demo"
environment  = "dev"
```

is normalized into values conceptually similar to:

```text
project = terraform-demo
environment = dev
resource_name = terraform-demo-dev-instance
instance_type = t3.micro
```

### 16.13 Apply the Configuration

Run:

```bash
terraform apply
```

Review the plan and confirm the operation.

### 16.14 Destroy the Infrastructure

After completing the lab:

```bash
terraform destroy
```

Review and confirm the deletion.

## 17. Testing Functions with `terraform console`

Terraform provides an extremely useful command for experimenting with expressions:

```bash
terraform console
```

This opens an interactive Terraform expression console.

### 17.1 Test `lower`

Run:

```hcl
lower("TERRAFORM")
```

Expected:

```text
"terraform"
```

### 17.2 Test `upper`

```hcl
upper("terraform")
```

Expected:

```text
"TERRAFORM"
```

### 17.3 Test `length`

```hcl
length(["dev", "staging", "prod"])
```

Expected:

```text
3
```

### 17.4 Test `contains`

```hcl
contains(["dev", "staging", "prod"], "prod")
```

Expected:

```text
true
```

### 17.5 Test `join`

```hcl
join("-", ["terraform", "dev", "app"])
```

Expected:

```text
"terraform-dev-app"
```

### 17.6 Test `split`

```hcl
split(",", "dev,staging,prod")
```

Expected:

```text
[
  "dev",
  "staging",
  "prod",
]
```

### 17.7 Test `merge`

```hcl
merge(
  {
    Environment = "dev"
  },
  {
    ManagedBy = "Terraform"
  }
)
```

Expected:

```text
{
  "Environment" = "dev"
  "ManagedBy"   = "Terraform"
}
```

### 17.8 Test `lookup`

```hcl
lookup(
  {
    dev  = "t3.micro"
    prod = "t3.large"
  },
  "prod"
)
```

Expected:

```text
"t3.large"
```

### 17.9 Test `cidrsubnet`

```hcl
cidrsubnet("10.0.0.0/16", 8, 1)
```

The console displays the calculated CIDR subnet.

The exact calculation can then be used in network configurations.

### 17.10 Exit the Console

Run:

```text
exit
```

or press:

```text
Ctrl+D
```

depending on the terminal environment.

## 18. Common Mistakes and Troubleshooting

### 18.1 Calling a Function That Does Not Exist

Incorrect:

```hcl
lowercase("TERRAFORM")
```

Terraform uses:

```hcl
lower("TERRAFORM")
```

Terraform has a defined set of built-in functions. Function names must be correct.

### 18.2 Incorrect Number of Arguments

For example:

```hcl
join("-")
```

is incomplete because `join` requires a delimiter and a list of strings.

Correct:

```hcl
join("-", ["terraform", "dev"])
```

### 18.3 Incorrect Data Type

For example:

```hcl
length(100)
```

is not appropriate because `length` expects a string or collection with a length.

Instead:

```hcl
length("100")
```

or:

```hcl
length([100, 200, 300])
```

### 18.4 Confusing `contains` With String Searching

`contains` checks whether a collection contains a value.

For example:

```hcl
contains(
  ["dev", "staging", "prod"],
  "prod"
)
```

For string prefix/suffix checks, use functions such as:

```hcl
startswith()
```

or:

```hcl
endswith()
```

### 18.5 Incorrect `merge` Inputs

`merge` is intended for maps or objects.

For example:

```hcl
merge(
  {
    Environment = "dev"
  },
  {
    ManagedBy = "Terraform"
  }
)
```

is valid.

Trying to merge unrelated scalar values is incorrect.

### 18.6 Assuming Sets Preserve Order

Consider:

```hcl
toset([
  "dev",
  "prod",
  "staging"
])
```

A set is unordered.

Do not depend on a specific positional order.

If ordering matters, use an appropriate ordered collection such as a list.

### 18.7 Unexpected Results from `lookup`

Example:

```hcl
lookup(
  {
    dev  = "t3.micro"
    prod = "t3.large"
  },
  "PROD"
)
```

The key does not match `"prod"` because map keys are case-sensitive.

Normalize the input when appropriate:

```hcl
lookup(
  local.instance_types,
  lower(var.environment),
  "t3.micro"
)
```

### 18.8 Misusing `timestamp()`

A value generated with:

```hcl
timestamp()
```

changes as Terraform evaluates it.

Using it casually in resource arguments can cause unnecessary changes or continually changing values.

Use it only when a changing timestamp is actually required.

### 18.9 `file()` Cannot Find the File

Example:

```hcl
file("${path.module}/user-data.sh")
```

If the file does not exist at that path, Terraform will fail.

Verify:

```text
user-data.sh
```

exists relative to the module path.

### 18.10 Using `try()` to Hide Real Configuration Problems

`try()` can be useful:

```hcl
try(var.name, "default")
```

but it should not be used everywhere to suppress errors.

If a configuration is fundamentally invalid, silently returning a fallback can make the problem harder to detect.

Use `try()` deliberately.

## 19. Best Practices

### 19.1 Use Functions to Improve Reusability

Instead of hardcoding:

```hcl
Name = "terraform-prod-instance"
```

we can generate it:

```hcl
Name = join("-", [
  var.project_name,
  var.environment,
  "instance"
])
```

This makes the configuration reusable.

### 19.2 Normalize Input Values

For user-provided or environment-provided strings, consider:

```hcl
lower(trimspace(var.environment))
```

This reduces problems caused by:

```text
" PROD "
"Prod"
"PROD"
```

### 19.3 Use Locals for Complex Expressions

Instead of placing a large expression directly inside a resource:

```hcl
resource "aws_instance" "example" {
  instance_type = lookup(
    local.instance_types,
    lower(trimspace(var.environment)),
    "t3.micro"
  )
}
```

we can define:

```hcl
locals {
  normalized_environment = lower(trimspace(var.environment))

  instance_type = lookup(
    local.instance_types,
    local.normalized_environment,
    "t3.micro"
  )
}
```

Then:

```hcl
resource "aws_instance" "example" {
  instance_type = local.instance_type
}
```

This is easier to read and maintain.

### 19.4 Prefer Clear Functions Over Clever Expressions

Terraform code should be understandable by another engineer.

Avoid excessively nested functions such as:

```hcl
lower(
  replace(
    trimspace(
      format(
        "%s-%s",
        var.project,
        var.environment
      )
    ),
    " ",
    "-"
  )
)
```

when the logic can be separated into meaningful locals.

### 19.5 Use `terraform console` During Development

Before placing a complex expression into production configuration, test it:

```bash
terraform console
```

For example:

```hcl
join("-", ["terraform", "prod", "app"])
```

This is one of the fastest ways to understand Terraform expression behavior.

### 19.6 Use Validation for User Inputs

Functions such as:

```hcl
contains()
```

can make variable validation more reliable.

Example:

```hcl
validation {
  condition = contains(
    ["dev", "staging", "prod"],
    lower(trimspace(var.environment))
  )

  error_message = "Environment must be dev, staging, or prod."
}
```

### 19.7 Use `merge()` for Common Tags

Instead of duplicating tags across resources:

```hcl
tags = {
  ManagedBy   = "Terraform"
  Project     = "platform"
  Environment = var.environment
}
```

we can centralize common tags:

```hcl
locals {
  common_tags = {
    ManagedBy = "Terraform"
    Project   = "platform"
  }

  tags = merge(
    local.common_tags,
    {
      Environment = var.environment
    }
  )
}
```

### 19.8 Be Careful With Functions That Read Files

Functions such as:

```hcl
file()
```

depend on local filesystem contents.

Keep referenced files inside the expected project/module structure and make their purpose clear.

### 19.9 Use Specialized Functions for Specialized Problems

For example:

```text
String manipulation → string functions
Collection processing → collection functions
CIDR calculations    → CIDR functions
Type conversion      → type conversion functions
JSON/YAML processing → encoding functions
```

Using the appropriate function makes Terraform code easier to understand.

## 20. Interview Questions

### Q1. What are Terraform built-in functions?

**Answer:**

Terraform built-in functions are predefined operations that allow us to transform, calculate, inspect, or manipulate values within Terraform expressions.

Examples include:

```hcl
lower()
length()
merge()
lookup()
join()
split()
```

### Q2. How do we call a Terraform function?

**Answer:**

Terraform functions use:

```hcl
function_name(arguments)
```

Example:

```hcl
lower("TERRAFORM")
```

### Q3. Can Terraform functions be nested?

**Answer:**

Yes.

For example:

```hcl
lower(trimspace(var.environment))
```

The inner function is evaluated first, followed by the outer function.

### Q4. What is the difference between `lower()` and `upper()`?

**Answer:**

`lower()` converts text to lowercase:

```hcl
lower("PROD")
```

returns:

```text
prod
```

`upper()` converts text to uppercase:

```hcl
upper("prod")
```

returns:

```text
PROD
```

### Q5. What does `length()` do?

**Answer:**

It returns the length of a string or the number of elements in a collection.

Example:

```hcl
length(["dev", "prod"])
```

returns:

```text
2
```

### Q6. What is the difference between `concat()` and `merge()`?

**Answer:**

`concat()` combines lists:

```hcl
concat(
  ["a", "b"],
  ["c", "d"]
)
```

`merge()` combines maps or objects:

```hcl
merge(
  { Environment = "dev" },
  { ManagedBy = "Terraform" }
)
```

### Q7. What does `lookup()` do?

**Answer:**

`lookup()` retrieves a value from a map using a key.

Example:

```hcl
lookup(
  {
    dev  = "t3.micro"
    prod = "t3.large"
  },
  "prod"
)
```

returns:

```text
t3.large
```

A default value can also be provided.

### Q8. What is the difference between `can()` and `try()`?

**Answer:**

`can()` returns a Boolean indicating whether an expression can be evaluated successfully.

```hcl
can(tonumber(var.port))
```

returns:

```text
true
```

or:

```text
false
```

`try()` returns the first expression that evaluates successfully:

```hcl
try(var.port, 8080)
```

### Q9. What does `jsonencode()` do?

**Answer:**

`jsonencode()` converts a Terraform value into a JSON string.

It is useful when a resource or external system expects JSON-formatted configuration.

### Q10. What does `cidrsubnet()` do?

**Answer:**

`cidrsubnet()` calculates a subnet CIDR from a larger CIDR network.

It is commonly used when dynamically creating cloud network ranges.

### Q11. How can we test Terraform functions without applying infrastructure?

**Answer:**

Use:

```bash
terraform console
```

Then evaluate expressions directly:

```hcl
lower("TERRAFORM")
```

or:

```hcl
cidrsubnet("10.0.0.0/16", 8, 1)
```

### Q12. Should all Terraform logic be written as complex functions?

**Answer:**

No.

Functions should make configuration clearer and more reusable.

If expressions become excessively complex, we should use:

* Locals.
* Maps.
* Variables.
* Modules.
* Separate expressions.

The goal is maintainability, not complexity.

### Q13. What is a common real-world use case for `merge()`?

**Answer:**

Combining common and environment-specific tags.

For example:

```hcl
locals {
  common_tags = {
    ManagedBy = "Terraform"
    Project   = "platform"
  }

  tags = merge(
    local.common_tags,
    {
      Environment = var.environment
    }
  )
}
```

### Q14. Why are Terraform functions important in Infrastructure as Code?

**Answer:**

They allow us to dynamically transform and calculate infrastructure values without duplicating configuration.

For example, we can:

* Generate resource names.
* Calculate network ranges.
* Select environment-specific values.
* Normalize input.
* Combine tags.
* Transform JSON/YAML.
* Validate input.
* Process collections.

This makes Terraform configurations more reusable and maintainable.

## 21. Summary

Terraform built-in functions provide reusable operations for manipulating values inside Terraform configurations.

The basic syntax is:

```hcl
function_name(arguments)
```

### Important Functions

| Function       | Purpose                                |
| -------------- | -------------------------------------- |
| `lower()`      | Convert text to lowercase              |
| `upper()`      | Convert text to uppercase              |
| `trimspace()`  | Remove leading/trailing whitespace     |
| `replace()`    | Replace text                           |
| `join()`       | Combine list elements into a string    |
| `split()`      | Split a string into a list             |
| `length()`     | Return length/count                    |
| `contains()`   | Check collection membership            |
| `concat()`     | Combine lists                          |
| `merge()`      | Combine maps/objects                   |
| `lookup()`     | Retrieve a map value                   |
| `flatten()`    | Flatten nested lists                   |
| `distinct()`   | Remove duplicates                      |
| `sort()`       | Sort a list                            |
| `min()`        | Return minimum value                   |
| `max()`        | Return maximum value                   |
| `tostring()`   | Convert to string                      |
| `tonumber()`   | Convert to number                      |
| `tolist()`     | Convert to list                        |
| `toset()`      | Convert to set                         |
| `timestamp()`  | Generate current timestamp             |
| `jsonencode()` | Convert value to JSON                  |
| `jsondecode()` | Convert JSON to Terraform value        |
| `yamlencode()` | Convert value to YAML                  |
| `yamldecode()` | Convert YAML to Terraform value        |
| `file()`       | Read a local file                      |
| `fileset()`    | Find files matching a pattern          |
| `cidrsubnet()` | Calculate subnet CIDRs                 |
| `cidrhost()`   | Calculate an IP within a CIDR          |
| `can()`        | Test whether an expression can succeed |
| `try()`        | Return the first successful expression |

### Functions + Variables + Locals + Conditionals

The real power of Terraform functions comes from combining them with the language features we have already learned:

```text
                   Input Variables
                          │
                          ▼
                      Functions
                          │
              ┌───────────┴───────────┐
              │                       │
              ▼                       ▼
        Normalization           Transformation
              │                       │
              └───────────┬───────────┘
                          ▼
                        Locals
                          │
                          ▼
                  Conditional Logic
                          │
                          ▼
                  Resource Arguments
                          │
                          ▼
                 Cloud Infrastructure
```

### Key Takeaway

> Terraform functions allow us to transform, calculate, validate, and manipulate infrastructure data directly within Terraform configuration, making reusable Infrastructure as Code possible without unnecessary duplication.

The most important practical skill is not memorizing every Terraform function. Instead, we should understand the major function categories, know the commonly used functions, and know how to discover and test the appropriate function when a requirement arises.

For experimentation and troubleshooting, remember:

```bash
terraform console
```

This provides a fast way to test Terraform expressions before incorporating them into infrastructure configuration.

### Configuration Section Complete

With this section, we have covered the core Terraform configuration concepts in this directory:

```text
02-terraform-configuration/
│
├── 01-providers.md
├── 02-multiple-providers.md
├── 03-multiple-regions.md
├── 04-required-providers.md
├── 05-variables.md
├── 06-tfvars.md
├── 07-conditional-expressions.md
└── 08-built-in-functions.md
```

The next major part of the directory is the practical project:

```text
project-multi-region-multi-provider/
```

where these configuration concepts can be combined into a complete Terraform implementation.
