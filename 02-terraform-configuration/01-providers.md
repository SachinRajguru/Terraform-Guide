
## Terraform Providers

> **File:** `01-providers.md`

## Table of Contents

1. [Introduction](#1-introduction)
2. [Provider and Resource Relationship](#2-provider-and-resource-relationship)
3. [Basic AWS Provider Configuration](#3-basic-aws-provider-configuration)
4. [Provider Requirements vs Provider Configuration](#4-provider-requirements-vs-provider-configuration)
5. [Provider Authentication](#5-provider-authentication)
6. [Provider Documentation](#6-provider-documentation)
7. [Practical Example](#7-practical-example)
8. [Important Points](#8-important-points)
9. [Interview Questions](#9-interview-questions)
10. [Summary](#10-summary)

## 1. Introduction

Terraform uses **providers** to interact with external platforms, services, and APIs.

A provider is a Terraform plugin that implements the integration between Terraform and an external system.

Common examples include:

* AWS
* Microsoft Azure
* Google Cloud
* Kubernetes
* GitHub
* VMware
* DNS platforms
* SaaS platforms
* Other APIs and services

A provider exposes the **resources** and **data sources** that Terraform can use to interact with the target platform.

### Simple Analogy

We can think of Terraform as the **orchestrator** and the provider as the **translator** between Terraform and an external platform.

```text
Terraform Configuration
          │
          ▼
      Terraform
          │
          ▼
       Provider
          │
          ▼
     External API
          │
          ▼
   Cloud / Platform
```

For example:

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

The AWS provider understands how Terraform should communicate with AWS APIs and exposes AWS resources such as `aws_instance`, `aws_vpc`, and `aws_s3_bucket`.

## 2. Provider and Resource Relationship

Terraform configurations use **resource types** supplied by providers.

For example:

```hcl
resource "aws_instance" "web" {
  instance_type = "t3.micro"
}
```

Here:

```text
aws_instance
```

is the resource type.

The `aws_` prefix indicates that the resource belongs to the AWS provider.

Conceptually:

```text
Terraform
    │
    ▼
AWS Provider
    │
    ├── aws_instance
    ├── aws_vpc
    ├── aws_subnet
    ├── aws_s3_bucket
    └── aws_iam_role
```

Each provider can expose:

* **Resources** — objects Terraform can create, update, or delete.
* **Data sources** — existing information Terraform can read and use in configuration.

For example:

```text
AWS Provider
     │
     ├── Resources
     │      ├── aws_instance
     │      ├── aws_vpc
     │      └── aws_s3_bucket
     │
     └── Data Sources
            ├── aws_ami
            ├── aws_vpc
            └── aws_caller_identity
```

This distinction becomes important as Terraform configurations become more advanced.

## 3. Basic AWS Provider Configuration

A basic AWS provider configuration is:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

The `region` argument tells the AWS provider which AWS region to use for resources that use this provider configuration.

For example:

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-example"
  instance_type = "t3.micro"
}
```

Conceptually:

```text
Terraform
    │
    ▼
AWS Provider
    │
    │ region = us-east-1
    ▼
AWS API
    │
    ▼
EC2
```

The provider configuration controls **how Terraform communicates with AWS**.

It does not itself create an EC2 instance.

The resource block:

```hcl
resource "aws_instance" "web" {
  ...
}
```

defines the infrastructure Terraform should manage.

Therefore:

```text
provider "aws"
        │
        └── How Terraform connects/configures AWS access

resource "aws_instance"
        │
        └── What Terraform manages in AWS
```

## 4. Provider Requirements vs Provider Configuration

Provider requirements and provider configuration are related, but they serve different purposes.

### 4.1 Provider Requirements

The `required_providers` block declares which provider dependencies the module requires.

For example:

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

This tells Terraform:

```text
Provider:
    AWS

Source:
    hashicorp/aws

Allowed version range:
    ~> 6.0
```

The provider requirement answers:

> **Which provider plugin does this configuration depend on?**

### 4.2 Provider Configuration

The provider block configures how the selected provider operates.

Example:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

This answers questions such as:

```text
Which region?
Which endpoint?
Which provider configuration?
Which authentication context?
```

The exact arguments depend on the provider.

### 4.3 The Difference

The distinction can be summarized as:

```text
required_providers
        │
        ├── Which provider?
        ├── Which source?
        └── Which versions?
        
                ↓

provider
        │
        ├── How is the provider configured?
        ├── Which region?
        ├── Which endpoint?
        └── Which provider settings?

                ↓

resources / data sources
```

A professional Terraform configuration commonly separates these concerns.

For example:

```text
project/
├── versions.tf
├── providers.tf
└── main.tf
```

`versions.tf`:

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

`providers.tf`:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

`main.tf`:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-example"
  instance_type = "t3.micro"
}
```

Terraform treats all `.tf` files in the same directory as part of the same root module, so separating these blocks into files is primarily an organizational practice rather than a functional requirement.

## 5. Provider Authentication

The provider also needs appropriate credentials or identity information to communicate with the target platform.

For AWS, authentication can be provided through mechanisms supported by the AWS SDK credential chain, such as:

* AWS CLI configuration
* Environment variables
* IAM roles
* Instance or workload roles
* Federated identity
* OIDC-based workload identity
* Other supported credential mechanisms

For local development, we may authenticate through the AWS CLI:

```bash
aws configure
```

We can then verify the active AWS identity:

```bash
aws sts get-caller-identity
```

The exact authentication mechanism should depend on the environment in which Terraform runs.

For example:

```text
Local Development
        │
        └── AWS CLI / local credential chain

CI/CD
        │
        └── Federated identity / workload identity

AWS Workload
        │
        └── IAM role
```

### Security Principle

Credentials should **not** be hard-coded into Terraform source code.

Avoid configurations such as:

```hcl
provider "aws" {
  region     = "us-east-1"
  access_key = "AKIA..."
  secret_key = "..."
}
```

Instead, use an appropriate external authentication mechanism.

> **Important:** Authentication and provider configuration are related but separate concerns. A provider block may specify the region and other settings without containing long-lived credentials.

## 6. Provider Documentation

Terraform providers evolve independently from the Terraform CLI.

A resource argument or behavior that was valid in an older provider version may be changed, deprecated, or removed in a newer version.

Therefore, we should verify provider documentation before implementing a resource.

A typical workflow is:

```text
Requirement
    │
    ▼
Provider Documentation
    │
    ▼
Resource / Data Source
    │
    ▼
Terraform Configuration
    │
    ▼
terraform validate
    │
    ▼
terraform plan
```

When working with AWS, we should verify:

* Resource documentation
* Data source documentation
* Provider version
* Required arguments
* Optional arguments
* Deprecated arguments
* Security-related behavior
* Provider-specific constraints

This becomes particularly important when working with older Terraform tutorials or repositories.

### Legacy Material

Older Terraform examples may contain:

* Deprecated provider arguments
* Old provider syntax
* Legacy resources
* Old authentication patterns
* Provider versions that are no longer supported

We should understand such examples when maintaining existing infrastructure, but we should not copy them into new projects without checking the current provider documentation.

## 7. Practical Example

A minimal provider-based project can be structured as:

```text
provider-example/
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
  }
}
```

### `providers.tf`

```hcl
provider "aws" {
  region = "us-east-1"
}
```

### `main.tf`

```hcl
resource "aws_instance" "web" {
  ami           = "ami-example"
  instance_type = "t3.micro"

  tags = {
    Name = "terraform-provider-example"
  }
}
```

Before applying the configuration, we can initialize Terraform:

```bash
terraform init
```

Format the configuration:

```bash
terraform fmt
```

Validate the configuration:

```bash
terraform validate
```

Review the proposed changes:

```bash
terraform plan
```

If the configuration and AWS prerequisites are valid, Terraform can then apply the configuration:

```bash
terraform apply
```

> The AMI ID shown above is intentionally a placeholder. AMI IDs are region-specific, so a valid AMI for the selected AWS region must be used before applying the configuration.

## 8. Important Points

The following concepts should be clear before moving to the next section:

### 1. Providers are plugins

Providers implement the integration between Terraform and external platforms or APIs.

### 2. Providers expose resources and data sources

For example:

```text
AWS Provider
    │
    ├── Resources
    │      └── aws_instance
    │
    └── Data Sources
           └── aws_ami
```

### 3. `required_providers` declares dependencies

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

### 4. `provider` configures the provider

Example:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

### 5. Provider authentication should be externalized

We should avoid embedding long-lived credentials directly into Terraform source code.

### 6. Provider versions matter

Terraform itself and Terraform providers have separate versioning.

For example:

```text
Terraform CLI
    │
    └── 1.15.x

AWS Provider
    │
    └── 6.x
```

### 7. Provider aliases enable multiple configurations

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

Provider aliases are covered in detail in:

```text
02-terraform-configuration/03-multiple-regions.md
```

## 9. Interview Questions

### Q1. What is a Terraform provider?

A Terraform provider is a plugin that implements the integration between Terraform and an external platform, service, or API.

Providers expose resources and data sources that Terraform can use to manage or read infrastructure.

### Q2. What is the difference between a provider and a resource?

A **provider** implements the integration with an external platform.

A **resource** represents an infrastructure object that Terraform manages through that provider.

For example:

```text
AWS Provider
      │
      └── aws_instance Resource
```

### Q3. What is `required_providers` used for?

`required_providers` declares the provider dependencies required by a Terraform module.

It can specify:

* Local provider name
* Provider source address
* Provider version constraint

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

### Q4. What is the purpose of a `provider` block?

A `provider` block configures a provider for use by resources and data sources.

For example:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

### Q5. What is the difference between `required_providers` and `provider`?

```text
required_providers
    ↓
Declares the provider dependency

provider
    ↓
Configures the provider
```

For example:

```hcl
required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 6.0"
  }
}
```

declares the dependency, while:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

configures it.

### Q6. Can Terraform use more than one provider?

Yes.

A configuration can use different provider types, such as:

```text
AWS
Kubernetes
GitHub
```

within the same Terraform configuration.

Multiple configurations of the same provider can also be created using provider aliases.

### Q7. Should AWS credentials be hard-coded in Terraform?

No.

Long-lived credentials should not normally be embedded directly into Terraform source code.

We should use an appropriate authentication mechanism such as:

* AWS CLI credential configuration
* Environment variables
* IAM roles
* Workload identity
* Federated authentication

### Q8. Are Terraform CLI versions and provider versions the same thing?

No.

Terraform CLI and providers are versioned independently.

For example:

```text
Terraform CLI
    └── 1.15.x

AWS Provider
    └── 6.x
```

A Terraform configuration can therefore specify constraints for both.

### Q9. Why should we check provider documentation before using a resource?

Provider resources and arguments can change independently of the Terraform CLI.

Checking the documentation helps us identify:

* Current syntax
* Required arguments
* Supported arguments
* Deprecated features
* Version-specific behavior
* Security considerations

This is especially important when working with older tutorials or existing Terraform code.

## 10. Summary

```text
                    Terraform
                        │
                        ▼
                    Provider
                        │
          ┌─────────────┴─────────────┐
          │                           │
      Resources                 Data Sources
          │                           │
          ▼                           ▼
  Manage Infrastructure        Read Information
          │
          ▼
  External Platform
```

The key distinction is:

```text
required_providers
        │
        └── Declares provider dependency
             ├── Source
             └── Version constraint

provider
        │
        └── Configures provider
             ├── Region
             ├── Endpoint
             └── Other provider settings

resources / data sources
        │
        └── Use the provider
```

Once provider fundamentals are understood, we can move to **multiple providers**, where a single Terraform configuration uses integrations with different platforms.
