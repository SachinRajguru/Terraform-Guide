
## Multiple AWS Regions in Terraform

**File:** 📄 `03-multiple-regions.md`

## Table of Contents

1. [Introduction](#1-introduction)
2. [Provider Aliases](#2-provider-aliases)
3. [Assigning a Provider to a Resource](#3-assigning-a-provider-to-a-resource)
4. [Important AMI Consideration](#4-important-ami-consideration)
5. [Complete Example](#5-complete-example)
6. [Why Aliases Are Important](#6-why-aliases-are-important)
7. [Interview Question](#7-interview-question)

## 1. Introduction

A single Terraform configuration can manage AWS resources in multiple regions.

This is useful for:

* Disaster recovery
* High availability
* Geographic deployments
* Data residency
* Multi-region applications
* Business continuity

> Terraform accomplishes this using **provider aliases**.

## 2. Provider Aliases

Consider two AWS regions:

```text
us-east-1
us-west-2
```

We can create two AWS provider configurations:

```hcl
provider "aws" {
  alias  = "east"
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}
```

The alias creates a named provider configuration.

## 3. Assigning a Provider to a Resource

The provider can then be selected using the `provider` meta-argument.

```hcl
resource "aws_instance" "east" {
  provider = aws.east

  ami           = "ami-example"
  instance_type = "t3.micro"
}
```

And:

```hcl
resource "aws_instance" "west" {
  provider = aws.west

  ami           = "ami-example"
  instance_type = "t3.micro"
}
```

The result is:

```text
Terraform
   │
   ├── aws.east
   │      └── us-east-1
   │           └── EC2
   │
   └── aws.west
          └── us-west-2
               └── EC2
```

## 4. Important AMI Consideration

An AMI ID is generally **region-specific**.

Therefore, we should not assume that an AMI ID valid in `us-east-1` is valid in `us-west-2`.

> For production-quality configurations, dynamic AMI discovery or region-specific variables should be considered.

## 5. Complete Example

```hcl
provider "aws" {
  alias  = "east"
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

resource "aws_instance" "east" {
  provider = aws.east

  ami           = "ami-example-east"
  instance_type = "t3.micro"
}

resource "aws_instance" "west" {
  provider = aws.west

  ami           = "ami-example-west"
  instance_type = "t3.micro"
}
```

## 6. Why Aliases Are Important

Without aliases, Terraform would have no way to distinguish multiple configurations of the same provider.

Aliases provide:

```text
aws.east
aws.west
aws.dr
aws.primary
```

> The alias name is chosen by the configuration author.

It does not have to equal the AWS region name.

## 7. Interview Question

**How do you configure Terraform for multiple AWS regions?**

Create multiple configurations of the AWS provider using `alias`, then assign the appropriate provider configuration to resources using the `provider` meta-argument.
