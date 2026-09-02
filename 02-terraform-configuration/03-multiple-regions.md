
## Terraform Multiple Regions

> **File:** `03-multiple-regions.md`

## Table of Contents

1. [Introduction](#1-introduction)
2. [What Is a Region?](#2-what-is-a-region)
3. [Why Use Multiple Regions?](#3-why-use-multiple-regions)
4. [How Terraform Handles Multiple Regions](#4-how-terraform-handles-multiple-regions)
5. [Provider Aliases for Multiple Regions](#5-provider-aliases-for-multiple-regions)
6. [Configuring Resources in Different Regions](#6-configuring-resources-in-different-regions)
7. [Practical Example](#7-practical-example)
8. [Validating the Configuration](#8-validating-the-configuration)
9. [Common Mistakes and Troubleshooting](#9-common-mistakes-and-troubleshooting)
10. [Best Practices](#10-best-practices)
11. [Interview Questions](#11-interview-questions)
12. [Summary](#12-summary)

## 1. Introduction

Cloud applications often need infrastructure in more than one geographic region.

For example, an organization may deploy:

* Production infrastructure in the United States.
* Disaster recovery infrastructure in another region.
* Application infrastructure close to customers in different geographic locations.
* Development and testing resources in separate regions.

Terraform supports multi-region infrastructure by allowing us to configure the same provider multiple times with different settings.

For AWS, we can configure multiple AWS provider instances, each targeting a different region.

The key Terraform concept used for this is the **provider alias**.

### Learning Objectives

By the end of this section, we will understand:

* What cloud regions are.
* Why organizations use multiple regions.
* How Terraform manages multiple provider configurations.
* What provider aliases are.
* How to deploy resources into different AWS regions.
* How to explicitly associate resources with provider aliases.
* How Terraform distinguishes resources using provider configurations.
* Common multi-region configuration mistakes.
* Best practices for designing multi-region Terraform configurations.

## 2. What Is a Region?

A **cloud region** is a geographic area where a cloud provider operates a collection of infrastructure facilities.

AWS, for example, provides regions such as:

```text
us-east-1
us-west-2
eu-west-1
ap-south-1
ap-southeast-1
```

Each region operates independently to a significant degree and contains multiple Availability Zones.

A simplified architecture looks like this:

```text
                    AWS
                     │
        ┌────────────┴────────────┐
        │                         │
    us-east-1                 eu-west-1
     Region                    Region
        │                         │
   ┌────┴────┐               ┌────┴────┐
   │         │               │         │
  AZ-a      AZ-b            AZ-a      AZ-b
```

### Region vs Availability Zone

A **Region** is a geographic area.

An **Availability Zone (AZ)** is an isolated infrastructure location within a region.

For example:

```text
AWS Region: us-east-1

├── Availability Zone A
├── Availability Zone B
├── Availability Zone C
└── ...
```

Multi-region architecture means deploying infrastructure across different regions.

Multi-AZ architecture means deploying infrastructure across multiple Availability Zones within the same region.

These are related but different architectural concepts.

## 3. Why Use Multiple Regions?

Organizations may use multiple regions for several reasons.

### 3.1 Disaster Recovery

A secondary region can be used as a disaster recovery location.

```text
Primary Region
us-east-1
    │
    │ Application
    │ Database
    │ Services
    │
    ▼
Secondary Region
us-west-2
    │
    │ Disaster Recovery
    │
    ▼
Failover
```

If the primary region becomes unavailable, workloads can potentially be recovered or failed over to the secondary region.

### 3.2 High Availability

For applications with strict availability requirements, distributing workloads across regions can reduce dependence on a single geographic location.

However, multi-region architecture is significantly more complex than simply deploying the same resources twice.

### 3.3 Geographic Proximity

Applications can be deployed closer to users.

For example:

```text
Users in India
      │
      ▼
ap-south-1

Users in Europe
      │
      ▼
eu-west-1

Users in North America
      │
      ▼
us-east-1
```

This can help reduce network latency and improve user experience.

### 3.4 Regulatory and Data Residency Requirements

Some organizations may need workloads or data to remain within specific geographic boundaries.

Region selection therefore needs to consider:

* Data residency.
* Compliance requirements.
* Legal requirements.
* Service availability.
* Network latency.
* Cost.

### 3.5 Business Continuity

A secondary region can form part of a broader business continuity strategy.

Terraform can help us reproduce infrastructure consistently across regions, but Terraform itself does not automatically provide application-level disaster recovery.

## 4. How Terraform Handles Multiple Regions

Terraform does not automatically know that a resource should be deployed into another region simply because another region is defined somewhere in the configuration.

Instead, we create multiple configurations of the same provider.

For AWS, this means creating multiple `aws` provider configurations.

For example:

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}
```

This creates two AWS provider configurations:

```text
AWS Provider
│
├── Default configuration
│   └── us-east-1
│
└── west alias
    └── us-west-2
```

Resources can then explicitly select the appropriate provider configuration.

## 5. Provider Aliases for Multiple Regions

### 5.1 What Is a Provider Alias?

A **provider alias** gives a provider configuration an additional name so that we can reference that specific configuration from resources, modules, or data sources.

Example:

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}
```

Here:

```text
Default AWS Provider
        │
        └── us-east-1

AWS Provider: west
        │
        └── us-west-2
```

The first provider configuration is the default configuration.

The second configuration is identified using:

```text
aws.west
```

### 5.2 Using the Default Provider

If a resource does not specify a provider, Terraform uses the default provider configuration.

Example:

```hcl
resource "aws_instance" "primary" {
  ami           = var.primary_ami_id
  instance_type = "t3.micro"
}
```

This resource uses:

```text
aws
```

and therefore uses the default AWS provider configuration.

If the default provider is configured for:

```hcl
region = "us-east-1"
```

the resource is created in `us-east-1`, subject to the resource and account configuration.

### 5.3 Using an Aliased Provider

To use another region, we explicitly specify the provider:

```hcl
resource "aws_instance" "secondary" {
  provider = aws.west

  ami           = var.secondary_ami_id
  instance_type = "t3.micro"
}
```

The important line is:

```hcl
provider = aws.west
```

This tells Terraform:

> Create this resource using the AWS provider configuration named `west`.

Since `aws.west` points to `us-west-2`, the resource is managed through that regional provider configuration.

## 6. Configuring Resources in Different Regions

A common pattern is:

```text
Terraform Root Module
│
├── AWS Provider
│   └── us-east-1
│
├── AWS Provider (alias = west)
│   └── us-west-2
│
├── Resource A
│   └── uses default provider
│
└── Resource B
    └── uses aws.west
```

### Example

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

resource "aws_instance" "primary" {
  ami           = var.primary_ami_id
  instance_type = "t3.micro"

  tags = {
    Name = "primary-instance"
  }
}

resource "aws_instance" "secondary" {
  provider = aws.west

  ami           = var.secondary_ami_id
  instance_type = "t3.micro"

  tags = {
    Name = "secondary-instance"
  }
}
```

The resulting architecture is:

```text
                   Terraform
                       │
             ┌─────────┴─────────┐
             │                   │
      Default Provider       aws.west
             │                   │
         us-east-1           us-west-2
             │                   │
             ▼                   ▼
        Primary EC2        Secondary EC2
```

### Important

An AMI is generally **region-specific**.

Therefore, an AMI ID that works in `us-east-1` should not be assumed to work in `us-west-2`.

For this reason, multi-region configurations commonly use separate AMI variables or region-aware data sources.

For example:

```hcl
variable "primary_ami_id" {
  type = string
}

variable "secondary_ami_id" {
  type = string
}
```

Then:

```hcl
resource "aws_instance" "primary" {
  ami = var.primary_ami_id
}

resource "aws_instance" "secondary" {
  provider = aws.west
  ami      = var.secondary_ami_id
}
```

## 7. Practical Example

We will create a simple multi-region configuration.

The purpose of this example is to understand **provider aliases and regional resource placement**.

It is not intended to represent a complete production multi-region architecture.

### 7.1 Project Structure

```text
multi-region-demo/
├── versions.tf
├── providers.tf
├── variables.tf
├── terraform.tfvars.example
└── main.tf
```

### 7.2 Define Terraform and Provider Requirements

Create:

```text
versions.tf
```

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

This declares:

* The Terraform CLI version range.
* The AWS provider source.
* The AWS provider version range.

### 7.3 Configure the Providers

Create:

```text
providers.tf
```

```hcl
provider "aws" {
  region = var.primary_region
}

provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
}
```

We now have:

```text
aws
└── primary region

aws.secondary
└── secondary region
```

### 7.4 Define Variables

Create:

```text
variables.tf
```

```hcl
variable "primary_region" {
  description = "Primary AWS region."
  type        = string
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "Secondary AWS region."
  type        = string
  default     = "us-west-2"
}

variable "primary_ami_id" {
  description = "AMI ID available in the primary region."
  type        = string
}

variable "secondary_ami_id" {
  description = "AMI ID available in the secondary region."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}
```

### 7.5 Create Resources

Create:

```text
main.tf
```

```hcl
resource "aws_instance" "primary" {
  ami           = var.primary_ami_id
  instance_type = var.instance_type

  tags = {
    Name = "multi-region-primary"
  }
}

resource "aws_instance" "secondary" {
  provider = aws.secondary

  ami           = var.secondary_ami_id
  instance_type = var.instance_type

  tags = {
    Name = "multi-region-secondary"
  }
}
```

Notice the difference:

```hcl
resource "aws_instance" "primary" {
```

uses the default provider.

Whereas:

```hcl
resource "aws_instance" "secondary" {
  provider = aws.secondary
```

uses the secondary provider configuration.

### 7.6 Configure Variables

Create:

```text
terraform.tfvars
```

Example:

```hcl
primary_region   = "us-east-1"
secondary_region = "us-west-2"

primary_ami_id   = "ami-xxxxxxxxxxxxxxxxx"
secondary_ami_id = "ami-yyyyyyyyyyyyyyyyy"

instance_type = "t3.micro"
```

The AMI IDs must be replaced with valid AMIs available in their respective regions.

### 7.7 Initialize Terraform

Run:

```bash
terraform init
```

Terraform downloads the required AWS provider and prepares the working directory.

### 7.8 Format the Configuration

Run:

```bash
terraform fmt
```

This formats the Terraform configuration using Terraform's standard formatting rules.

### 7.9 Validate the Configuration

Run:

```bash
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

### 7.10 Review the Execution Plan

Run:

```bash
terraform plan
```

Before applying the configuration, review:

* Resources Terraform intends to create.
* Provider configuration used by each resource.
* Region-specific configuration.
* AMI IDs.
* Instance types.
* Tags.

We should confirm that:

```text
aws_instance.primary
        │
        └── us-east-1

aws_instance.secondary
        │
        └── us-west-2
```

### 7.11 Apply the Configuration

Run:

```bash
terraform apply
```

Review the proposed changes and confirm the operation when prompted.

Terraform then creates the resources using their respective provider configurations.

### 7.12 Verify the Deployment

We can verify the resources through the AWS console or AWS CLI.

The expected architecture is:

```text
AWS
│
├── us-east-1
│   └── multi-region-primary
│
└── us-west-2
    └── multi-region-secondary
```

We can also inspect Terraform state:

```bash
terraform state list
```

Example:

```text
aws_instance.primary
aws_instance.secondary
```

### 7.13 Clean Up

When the lab is complete, destroy the resources:

```bash
terraform destroy
```

Review the deletion plan and confirm the operation.

This is particularly important when practicing in AWS because running resources can generate charges.

## 8. Validating the Configuration

A professional Terraform workflow should validate the configuration before applying changes.

### Step 1 — Format

```bash
terraform fmt
```

### Step 2 — Validate

```bash
terraform validate
```

### Step 3 — Review the Plan

```bash
terraform plan
```

### Step 4 — Apply

```bash
terraform apply
```

### Step 5 — Verify

Confirm that resources exist in their intended regions.

### Step 6 — Destroy

```bash
terraform destroy
```

A useful verification checklist is:

```text
[ ] Terraform configuration formatted
[ ] Configuration validated
[ ] Primary provider points to intended region
[ ] Secondary provider alias points to intended region
[ ] Region-specific AMIs are valid
[ ] Resources explicitly use the intended provider
[ ] terraform plan reviewed
[ ] Resources verified in AWS
[ ] Resources destroyed after practice
```

## 9. Common Mistakes and Troubleshooting

### 9.1 Forgetting the Provider Alias

Incorrect:

```hcl
provider "aws" {
  alias  = "secondary"
  region = "us-west-2"
}

resource "aws_instance" "secondary" {
  ami = var.secondary_ami_id
}
```

The resource does not automatically select `aws.secondary`.

Correct:

```hcl
resource "aws_instance" "secondary" {
  provider = aws.secondary

  ami = var.secondary_ami_id
}
```

### 9.2 Using the Wrong AMI for a Region

An AMI ID is generally tied to a specific AWS region.

For example:

```text
ami-AAAA
│
└── us-east-1
```

does not mean the same ID can be used in:

```text
us-west-2
```

Use a region-appropriate AMI.

### 9.3 Expecting a Provider Alias to Change All Resources

Consider:

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}
```

The following:

```hcl
resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = "t3.micro"
}
```

still uses the default provider.

It does not automatically use:

```text
aws.west
```

We must explicitly specify:

```hcl
provider = aws.west
```

### 9.4 Using Variables Without Considering Region

This can become problematic:

```hcl
variable "ami_id" {
  type = string
}
```

when the same AMI is expected to work across multiple regions.

A better educational design is:

```hcl
variable "primary_ami_id" {
  type = string
}

variable "secondary_ami_id" {
  type = string
}
```

This makes the regional dependency explicit.

In more advanced configurations, we can use region-aware data sources or maps to select appropriate values automatically.

### 9.5 Resource Dependencies Across Regions

Some resources cannot simply communicate across regions without additional architecture.

For example:

```text
Region A
EC2
 │
 │
 └──── Network / Application Architecture ────┐
                                              │
Region B                                      │
EC2                                           │
```

Cross-region architectures may require:

* Cross-region networking.
* DNS.
* Load balancing.
* Replication.
* Database replication.
* Object replication.
* IAM configuration.
* Encryption key considerations.
* Monitoring.
* Failover mechanisms.

Terraform can provision these components, but it does not automatically design the complete multi-region architecture for us.

## 10. Best Practices

### 10.1 Use Meaningful Alias Names

Prefer:

```hcl
alias = "secondary"
```

or:

```hcl
alias = "west"
```

over vague names such as:

```hcl
alias = "provider2"
```

The alias should communicate its purpose.

### 10.2 Keep Provider Configuration Centralized

A professional project can keep provider configuration in:

```text
providers.tf
```

and Terraform/provider requirements in:

```text
versions.tf
```

This keeps the root module organized.

### 10.3 Make Region Selection Explicit

Prefer:

```hcl
provider = aws.secondary
```

when a resource must be created through a specific regional provider.

Explicit configuration improves readability and reduces accidental deployment into the wrong region.

### 10.4 Treat Region-Specific Values Carefully

Values such as:

* AMI IDs.
* Availability Zone names.
* Subnet IDs.
* VPC IDs.
* Security group IDs.

can be region-specific.

We should avoid assuming that a value from one region can be reused in another.

### 10.5 Use Data Sources for Dynamic Discovery

Instead of hardcoding values where appropriate, Terraform data sources can discover information from AWS.

For example:

```hcl
data "aws_ami" "example" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["example-image-*"]
  }
}
```

In multi-region configurations, the data source must use the appropriate provider configuration when regional discovery is required.

For example:

```hcl
data "aws_ami" "secondary" {
  provider = aws.secondary

  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["example-image-*"]
  }
}
```

This is an important pattern for advanced Terraform configurations.

### 10.6 Use Remote State for Collaborative Environments

A multi-region architecture does not require a separate Terraform state file for every region.

A single root module can manage multiple provider configurations and resources.

For collaborative or production environments, state should generally be stored in an appropriate remote backend rather than committed to Git.

### 10.7 Do Not Confuse Multi-Region With Disaster Recovery

Deploying resources in two regions does not automatically create a disaster recovery solution.

A real DR design must also consider:

```text
Infrastructure
+
Data Replication
+
Application Replication
+
Traffic Management
+
Monitoring
+
Failover
+
Recovery Procedures
```

Terraform is an infrastructure automation tool that can help implement such an architecture; it is not itself the complete DR strategy.

## 11. Interview Questions

### Q1. How do we deploy Terraform resources into multiple AWS regions?

**Answer:**

We configure multiple AWS provider instances using provider aliases and associate resources with the appropriate provider configuration.

Example:

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

resource "aws_instance" "secondary" {
  provider = aws.west

  ami           = var.ami_id
  instance_type = "t3.micro"
}
```

### Q2. What is a provider alias?

**Answer:**

A provider alias gives a provider configuration an additional name so that Terraform can distinguish between multiple configurations of the same provider.

Example:

```hcl
provider "aws" {
  alias  = "secondary"
  region = "us-west-2"
}
```

The configuration can then be referenced as:

```hcl
aws.secondary
```

### Q3. What happens if we do not specify `provider = aws.secondary`?

**Answer:**

If the resource does not explicitly specify an aliased provider, Terraform normally uses the default provider configuration for that resource.

Therefore:

```hcl
resource "aws_instance" "example" {
  ...
}
```

uses the default AWS provider rather than an aliased configuration.

### Q4. Can we use the same AWS provider more than once?

**Answer:**

Yes.

We can configure the same provider multiple times using aliases.

For example:

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}
```

### Q5. Are AMI IDs reusable across AWS regions?

**Answer:**

Generally, no.

AMI IDs are region-specific. An AMI ID available in one region should not be assumed to be available in another region.

For multi-region infrastructure, we should provide region-appropriate AMIs or discover them dynamically.

### Q6. Is multi-region the same as multi-AZ?

**Answer:**

No.

Multi-AZ means deploying across multiple Availability Zones within one AWS region.

Multi-region means deploying across multiple AWS regions.

Example:

```text
Multi-AZ

us-east-1
├── AZ-A
├── AZ-B
└── AZ-C
```

versus:

```text
Multi-Region

us-east-1
└── Region A

us-west-2
└── Region B
```

### Q7. Does Terraform automatically provide disaster recovery when we deploy to two regions?

**Answer:**

No.

Terraform can provision infrastructure in multiple regions, but disaster recovery also requires considerations such as data replication, application replication, traffic management, monitoring, failover, and recovery procedures.

### Q8. Can one Terraform root module manage resources in multiple regions?

**Answer:**

Yes.

A single root module can configure multiple provider instances and use them for resources in different regions.

For example:

```text
Root Module
│
├── aws
│   └── us-east-1
│
├── aws.secondary
│   └── us-west-2
│
├── Resource A
│   └── us-east-1
│
└── Resource B
    └── us-west-2
```

## 12. Summary

Terraform supports multi-region infrastructure by allowing us to configure multiple instances of the same provider.

The core pattern is:

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "secondary"
  region = "us-west-2"
}
```

We then associate resources with the required provider:

```hcl
resource "aws_instance" "secondary" {
  provider = aws.secondary

  ami           = var.secondary_ami_id
  instance_type = "t3.micro"
}
```

The key concepts are:

```text
Provider
   │
   ├── Default Configuration
   │      └── us-east-1
   │
   └── Aliased Configuration
          └── us-west-2
```

The most important takeaway is:

> Provider aliases allow Terraform to manage multiple configurations of the same provider, making them essential for multi-region infrastructure.

### What We Learned

* A cloud region is a geographic infrastructure location.
* Multi-region architecture uses multiple cloud regions.
* Terraform supports multiple configurations of the same provider.
* Provider aliases distinguish those configurations.
* Resources can explicitly select an aliased provider.
* Region-specific values such as AMI IDs must be handled carefully.
* Multi-region infrastructure is more complex than simply duplicating resources.
* Multi-region does not automatically equal disaster recovery.
* Data sources can help dynamically discover region-specific resources.
* A single Terraform root module can manage resources across multiple regions.

### Next Section

Next, we will learn about **`required_providers`** and how Terraform declares provider dependencies, sources, and version constraints.
