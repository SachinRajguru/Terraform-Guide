
## Providers in Terraform

## Table of Contents

1. [Introduction](#1-introduction)
2. [Provider and Resource Relationship](#2-provider-and-resource-relationship)
3. [Basic AWS Provider Configuration](#3-basic-aws-provider-configuration)
4. [Provider Configuration vs Provider Requirements](#4-provider-configuration-vs-provider-requirements)
5. [Provider Documentation](#5-provider-documentation)
6. [Interview Question](#interview-question)
7. [Summary](#summary)

## 1. Introduction

> Terraform uses **providers** to interact with external APIs and platforms.

A provider is a plugin that allows Terraform to communicate with systems such as:

* AWS
* Microsoft Azure
* Google Cloud
* Kubernetes
* VMware
* GitHub
* Random data generators
* DNS platforms
* SaaS platforms

HashiCorp describes providers as plugins through which Terraform interacts with cloud providers, SaaS providers, and other APIs. Each provider exposes resource types and/or data sources that Terraform can manage. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/providers))

## 2. Provider and Resource Relationship

A useful mental model is:

```text
Terraform
    │
    ▼
Provider
    │
    ▼
External API
    │
    ▼
Infrastructure
```

For AWS:

```text
Terraform
    │
    ▼
AWS Provider
    │
    ▼
AWS API
    │
    ├── EC2
    ├── VPC
    ├── S3
    ├── IAM
    └── RDS
```

A resource belongs to a provider.

For example:

```hcl
resource "aws_instance" "web" {
  instance_type = "t3.micro"
}
```

The `aws_instance` resource is supplied by the AWS provider.

## 3. Basic AWS Provider Configuration

A simple configuration is:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

The provider configuration specifies the AWS region in which resources using this provider configuration will operate.

Authentication should generally be handled through AWS's supported credential mechanisms such as:

* AWS CLI configuration
* environment variables
* IAM roles
* workload identity mechanisms
* CI/CD identity federation

> Credentials should **not** be hard-coded into Terraform source files.

## 4. Provider Configuration vs Provider Requirement

> These are related but different concepts.

### Provider requirement

Declares:

* provider source
* provider local name
* version constraint

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

### Provider configuration

Configures the provider:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

HashiCorp recommends declaring provider requirements separately from configuring the provider. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/providers/requirements))

## 5. Provider Documentation

> Terraform providers evolve independently from Terraform itself.

Therefore, we should always consult the provider documentation before implementing resources.

The Terraform Registry contains versioned provider documentation. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/providers))

[Terraform Provider Documentation](https://registry.terraform.io/?utm_source=chatgpt.com)

## 6. Interview Question

**What is a Terraform provider?**

A Terraform provider is a plugin that implements the integration between Terraform and an external API or platform. Providers expose resource types and data sources that Terraform uses to manage infrastructure.

## Summary

```text
Provider
   ↓
Connects Terraform to external APIs
   ↓
Exposes resources/data sources
   ↓
Terraform manages infrastructure
```
