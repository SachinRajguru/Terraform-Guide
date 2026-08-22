
## `02-multiple-providers.md`

## Multiple Providers in Terraform

## Table of Contents

1. [Introduction](#1-introduction)
2. [Example](#2-example)
3. [Using Different Providers](#3-using-different-providers)
4. [Provider Authentication](#4-provider-authentication)
5. [Why Multiple Providers Matter](#5-why-multiple-providers-matter)
6. [Important Design Principle](#6-important-design-principle)
7. [Interview Question](#7-interview-question)

## 1. Introduction

Terraform can use multiple providers within the same configuration.

> This is useful when an architecture spans multiple platforms.

For example:

```text
Terraform
   │
   ├── AWS Provider
   │      └── EC2
   │
   ├── Kubernetes Provider
   │      └── Kubernetes Resources
   │
   └── GitHub Provider
          └── Repository
```

A multi-provider architecture does not necessarily mean multi-cloud. A project can use multiple providers within the same platform or across different platforms.

## 2. Example

Consider an architecture where:

* AWS provides compute infrastructure.
* Kubernetes manages workloads.
* GitHub manages source repositories.

The configuration may declare:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }

    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}
```

Provider configurations are then defined separately.

```hcl
provider "aws" {
  region = "us-east-1"
}
```

## 3. Using Different Providers

Resources identify their provider through their resource type.

Example:

```hcl
resource "aws_s3_bucket" "application" {
  bucket_prefix = "terraform-configuration-"
}
```

A Kubernetes resource belongs to the Kubernetes provider:

```hcl
resource "kubernetes_namespace" "application" {
  metadata {
    name = "application"
  }
}
```

The resource type tells Terraform which provider normally handles the resource.

## 4. Provider Authentication

Provider credentials should be handled through secure authentication mechanisms.

For example, AWS credentials can be supplied through the AWS CLI credential chain rather than:

```hcl
provider "aws" {
  access_key = "..."
  secret_key = "..."
}
```

> Hard-coded credentials are inappropriate for production repositories.

## 5. Why Multiple Providers Matter

Multi-provider configurations are common in DevOps environments.

For example:

```text
AWS
 │
 ├── VPC
 ├── EC2
 └── EKS
      │
      ▼
Kubernetes Provider
      │
      ├── Namespace
      ├── Deployment
      └── Service
```

Terraform can therefore manage infrastructure and platform configuration within one workflow.

## 6. Important Design Principle

> We should not introduce multiple providers simply because Terraform supports them.

A provider should be introduced when there is a genuine infrastructure or platform requirement.

## 7. Interview Question

**How can Terraform manage infrastructure across multiple platforms?**

Terraform can declare multiple providers in a configuration. Each provider supplies resources and data sources for its corresponding platform or API.
