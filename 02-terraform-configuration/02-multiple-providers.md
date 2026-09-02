
## Multiple Providers in Terraform

> **File:** `02-multiple-providers.md`

## Table of Contents

1. [Introduction](#1-introduction)
2. [Multiple Provider Types](#2-multiple-provider-types)
3. [Declaring Multiple Providers](#3-declaring-multiple-providers)
4. [Using Different Providers](#4-using-different-providers)
5. [Provider Authentication](#5-provider-authentication)
6. [Multi-Provider Architecture](#6-multi-provider-architecture)
7. [When Should We Use Multiple Providers?](#7-when-should-we-use-multiple-providers)
8. [Important Design Principle](#8-important-design-principle)
9. [Practical Example](#9-practical-example)
10. [Interview Questions](#10-interview-questions)
11. [Summary](#11-summary)

## 1. Introduction

Terraform can use multiple providers within the same configuration.

This is useful when an architecture spans multiple platforms, services, or APIs.

For example, a DevOps platform might use:

```text
Terraform
    │
    ├── AWS Provider
    │      └── Cloud Infrastructure
    │
    ├── Kubernetes Provider
    │      └── Kubernetes Resources
    │
    └── GitHub Provider
           └── GitHub Resources
```

A configuration using multiple providers is commonly called a **multi-provider configuration**.

> **Important:** Multi-provider does not necessarily mean multi-cloud.

A configuration can use multiple providers within the same cloud platform or across completely different platforms.

For example:

```text
AWS
 │
 ├── AWS Provider
 │
 └── Kubernetes Provider
        │
        └── EKS Kubernetes Resources
```

The AWS provider manages AWS infrastructure, while the Kubernetes provider manages resources inside a Kubernetes cluster.

## 2. Multiple Provider Types

A Terraform configuration can declare several different provider types.

For example:

```text
AWS Provider
    │
    └── AWS infrastructure

Kubernetes Provider
    │
    └── Kubernetes resources

GitHub Provider
    │
    └── GitHub resources
```

A realistic DevOps workflow could look like:

```text
                 Terraform
                     │
       ┌─────────────┼─────────────┐
       │             │             │
       ▼             ▼             ▼
      AWS        Kubernetes      GitHub
    Provider     Provider       Provider
       │             │             │
       ▼             ▼             ▼
     EKS          Namespace     Repository
     VPC          Deployment    Branch
     IAM          Service       Settings
```

This allows Terraform to manage related components through a common infrastructure-as-code workflow.

## 3. Declaring Multiple Providers

Provider dependencies are declared in the `required_providers` block.

Example:

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

This tells Terraform that the configuration depends on three provider plugins:

```text
hashicorp/aws
hashicorp/kubernetes
integrations/github
```

The provider source address identifies where Terraform obtains the provider.

The version constraints define which provider versions are acceptable.

Terraform installs the required providers during:

```bash
terraform init
```

## 4. Using Different Providers

After declaring the provider requirements, we configure the providers.

For example:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

A Kubernetes provider may be configured using cluster connection information:

```hcl
provider "kubernetes" {
  # Kubernetes provider configuration
}
```

And the GitHub provider can be configured for GitHub API access:

```hcl
provider "github" {
  # GitHub provider configuration
}
```

The exact configuration depends on the provider and the authentication mechanism being used.

### AWS Resource

An AWS resource belongs to the AWS provider:

```hcl
resource "aws_s3_bucket" "application" {
  bucket_prefix = "terraform-configuration-"
}
```

### Kubernetes Resource

A Kubernetes resource belongs to the Kubernetes provider:

```hcl
resource "kubernetes_namespace" "application" {
  metadata {
    name = "application"
  }
}
```

### GitHub Resource

A GitHub resource belongs to the GitHub provider:

```hcl
resource "github_repository" "application" {
  name = "terraform-multi-provider-example"
}
```

Conceptually:

```text
aws_s3_bucket
      │
      ▼
AWS Provider

kubernetes_namespace
      │
      ▼
Kubernetes Provider

github_repository
      │
      ▼
GitHub Provider
```

Terraform determines the provider associated with a resource through its resource type and provider configuration.

## 5. Provider Authentication

Each provider may require authentication to communicate with its target platform.

Authentication should be handled through appropriate mechanisms rather than hard-coded credentials.

For example:

```text
AWS
 │
 └── AWS credential chain / IAM role / federation

Kubernetes
 │
 └── kubeconfig / cluster identity / supported authentication

GitHub
 │
 └── token / application / supported authentication
```

### Avoid Hard-Coded Credentials

We should not place credentials directly into Terraform source code.

Avoid patterns such as:

```hcl
provider "aws" {
  access_key = "..."
  secret_key = "..."
}
```

or:

```hcl
provider "github" {
  token = "hard-coded-token"
}
```

Instead, use the authentication mechanisms recommended by each provider.

> **Security principle:** Terraform source code should describe infrastructure and provider configuration without exposing long-lived secrets.

## 6. Multi-Provider Architecture

Consider a common Kubernetes platform running on AWS.

The architecture may look like:

```text
                         Terraform
                             │
              ┌──────────────┴──────────────┐
              │                             │
              ▼                             ▼
         AWS Provider                Kubernetes Provider
              │                             │
       ┌──────┼──────┐                      │
       │      │      │                      │
       ▼      ▼      ▼                      ▼
      VPC    EKS    IAM              Kubernetes API
                     │                      │
                     │                ┌─────┼─────┐
                     │                │     │     │
                     ▼                ▼     ▼     ▼
                  AWS IAM     Namespace Deployment Service
```

Terraform can therefore manage both:

```text
Infrastructure layer
        │
        └── AWS Provider

Platform/workload layer
        │
        └── Kubernetes Provider
```

This can be useful when infrastructure provisioning and platform configuration need to be coordinated.

## 7. When Should We Use Multiple Providers?

Multiple providers should be used when there is a genuine architectural requirement.

### Example 1 — Cloud + Kubernetes

```text
AWS
 │
 └── EKS cluster

Kubernetes
 │
 └── Applications running in EKS
```

Terraform can potentially manage both layers.

### Example 2 — Cloud + DNS

```text
AWS
 │
 └── Infrastructure

DNS Provider
 │
 └── DNS records
```

Terraform can manage cloud infrastructure and corresponding DNS records through different providers.

### Example 3 — Cloud + GitHub

```text
AWS
 │
 └── Infrastructure

GitHub
 │
 └── Repository configuration
```

This can be useful for platform automation where infrastructure and source-control configuration are managed together.

## 8. Important Design Principle

> We should not introduce multiple providers simply because Terraform supports them.

Each provider introduces:

* A dependency
* Authentication requirements
* Provider versioning
* Provider-specific behavior
* Additional configuration
* Additional operational responsibility

Therefore, we should introduce a provider only when the architecture actually requires it.

### Poor Design

```text
Terraform
   │
   ├── AWS
   ├── Kubernetes
   ├── GitHub
   ├── Azure
   ├── Google Cloud
   └── DNS
```

if the project only needs AWS.

### Better Design

```text
Terraform
   │
   └── AWS
```

when the infrastructure requirement is entirely within AWS.

The goal is not to maximize the number of providers.

The goal is to model the infrastructure accurately and maintainably.

## 9. Practical Example

The following example demonstrates the concept of using two different providers.

### Project Structure

```text
multi-provider-example/
├── versions.tf
├── providers.tf
└── main.tf
```

### `versions.tf`

```hcl
terraform {
  required_version = "~> 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}
```

### `providers.tf`

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "github" {
  # Authentication should be supplied through a supported
  # external authentication mechanism.
}
```

### `main.tf`

```hcl
resource "aws_s3_bucket" "application" {
  bucket_prefix = "terraform-multi-provider-"

  tags = {
    Name        = "terraform-multi-provider"
    ManagedBy   = "Terraform"
    Environment = "dev"
  }
}

resource "github_repository" "application" {
  name        = "terraform-multi-provider-example"
  description = "Example repository managed with Terraform"

  visibility = "private"
}
```

The conceptual relationship is:

```text
                     Terraform
                         │
             ┌───────────┴───────────┐
             │                       │
             ▼                       ▼
        AWS Provider           GitHub Provider
             │                       │
             ▼                       ▼
        S3 Bucket                Repository
```

### Initialize the Project

```bash
terraform init
```

### Format the Configuration

```bash
terraform fmt
```

### Validate the Configuration

```bash
terraform validate
```

### Review the Plan

```bash
terraform plan
```

### Apply

```bash
terraform apply
```

> The example requires valid authentication and appropriate permissions for both AWS and GitHub. Provider-specific authentication should be configured before applying the configuration.

### Cleanup

After completing the exercise:

```bash
terraform destroy
```

This removes the resources managed by the Terraform configuration.

## 10. Interview Questions

### Q1. Can Terraform use multiple providers in the same configuration?

Yes.

A Terraform configuration can declare and use multiple provider types.

For example:

```text
AWS
Kubernetes
GitHub
```

can be used within the same configuration when the architecture requires them.

### Q2. Does multiple providers mean multi-cloud?

No.

Multiple providers simply means that the configuration uses more than one provider.

For example:

```text
AWS Provider
+
Kubernetes Provider
```

is a multi-provider configuration even though the infrastructure may be hosted entirely on AWS.

### Q3. How does Terraform know which provider manages a resource?

Terraform associates resource types with their providers.

For example:

```text
aws_instance
      ↓
AWS Provider

kubernetes_namespace
      ↓
Kubernetes Provider

github_repository
      ↓
GitHub Provider
```

Provider configurations can also be explicitly selected when multiple configurations of the same provider exist.

### Q4. Where are provider dependencies declared?

Provider dependencies are declared in the:

```hcl
terraform {
  required_providers {
    ...
  }
}
```

block.

For example:

```hcl
required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 6.0"
  }
}
```

### Q5. How are provider credentials normally handled?

Credentials should be supplied through appropriate authentication mechanisms supported by the provider.

Examples include:

```text
AWS IAM roles
AWS credential chain
Environment variables
Federated identity
Workload identity
Provider-specific authentication mechanisms
```

Long-lived credentials should not normally be hard-coded into Terraform source code.

### Q6. Can Terraform manage infrastructure and Kubernetes resources together?

Yes.

For example:

```text
AWS Provider
     │
     └── EKS infrastructure

Kubernetes Provider
     │
     └── Kubernetes resources
```

This allows Terraform to manage infrastructure and platform resources within a coordinated configuration when that architecture is appropriate.

### Q7. Why should we avoid unnecessary providers?

Every provider introduces additional:

* Dependencies
* Authentication requirements
* Version management
* Configuration
* Provider-specific behavior
* Operational complexity

Therefore, providers should be introduced based on actual architectural requirements.

### Q8. What is the difference between multiple providers and multiple provider configurations?

**Multiple providers** means different provider types are used:

```text
AWS Provider
Kubernetes Provider
GitHub Provider
```

**Multiple provider configurations** means multiple configurations of the same provider are used.

For example:

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

The second concept is covered in detail in:

```text
02-terraform-configuration/03-multiple-regions.md
```

## 11. Summary

Terraform can use multiple providers within the same configuration when an architecture spans multiple platforms or APIs.

The overall model is:

```text
                         Terraform
                             │
          ┌──────────────────┼──────────────────┐
          │                  │                  │
          ▼                  ▼                  ▼
    AWS Provider    Kubernetes Provider   GitHub Provider
          │                  │                  │
          ▼                  ▼                  ▼
      AWS APIs         Kubernetes API      GitHub API
          │                  │                  │
          ▼                  ▼                  ▼
    Infrastructure        Platform          Repository
```

The key concepts are:

```text
required_providers
        │
        └── Declare provider dependencies

provider
        │
        └── Configure provider behavior

resource
        │
        └── Use the appropriate provider
```

A multi-provider architecture is useful when there is a real infrastructure requirement, but adding providers unnecessarily increases complexity.

The next concept is **multiple configurations of the same provider**, which Terraform supports through **provider aliases**.
