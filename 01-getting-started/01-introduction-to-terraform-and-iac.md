
## 01 — Introduction to Terraform and Infrastructure as Code

**File:** 📄 `01-introduction-to-terraform-and-iac.md`

## Table of Contents

1. [Introduction](#1-introduction)
2. [What Is Infrastructure as Code?](#2-what-is-infrastructure-as-code)
3. [Why Do We Need IaC?](#3-why-do-we-need-iac)
4. [Traditional Infrastructure vs IaC](#4-traditional-infrastructure-vs-iac)
5. [Why Terraform?](#5-why-terraform)
6. [Terraform](#6-terraform)
7. [Declarative Infrastructure](#7-declarative-infrastructure)
8. [Terraform and APIs](#8-terraform-and-apis)
9. [What Is HCL?](#9-what-is-hcl)
10. [Terraform Providers](#10-terraform-providers)
11. [Why Terraform Is Important for DevOps Engineers](#11-why-terraform-is-important-for-devops-engineers)
12. [Terraform Alternatives](#12-terraform-alternatives)
13. [Key Benefits of Terraform](#13-key-benefits-of-terraform)
14. [Important Concept — Desired State](#14-important-concept--desired-state)
15. [Learning Outcome](#15-learning-outcome)

## 1. Introduction

Infrastructure management traditionally involved manually creating resources through cloud-provider consoles.

For example, suppose a DevOps engineer receives a request to create an Amazon S3 bucket.

The manual approach would be:

```text
AWS Console
    ↓
Login
    ↓
Open S3
    ↓
Create Bucket
    ↓
Configure Bucket
    ↓
Review
    ↓
Create
```

For one resource, this may be manageable.

However, imagine receiving the same request from 100 teams.

The manual process becomes:

```text
100 Requests
    ↓
100 Manual Operations
    ↓
High Effort
    ↓
Human Errors
    ↓
Configuration Inconsistency
    ↓
Difficult Auditing
```

This is one of the problems that **Infrastructure as Code (IaC)** solves.

## 2. What Is Infrastructure as Code?

**Infrastructure as Code (IaC)** is the practice of defining, provisioning, configuring, and managing infrastructure through machine-readable configuration files instead of manually creating infrastructure through graphical interfaces.

Instead of manually saying:

> Create a VPC, subnet, EC2 instance and S3 bucket.

We define the desired infrastructure in code.

For example:

```text
Terraform Configuration
        ↓
Terraform
        ↓
Cloud Provider API
        ↓
Infrastructure
```

The infrastructure definition becomes version-controlled and repeatable.

## 3. Why Do We Need IaC?

IaC addresses several common infrastructure-management problems.

### 3.1 Manual Provisioning

Manual infrastructure creation is:

* time-consuming
* repetitive
* difficult to standardize
* prone to human error
* difficult to reproduce

### 3.2 Infrastructure Consistency

Suppose two engineers manually create EC2 instances.

Engineer A may configure:

```text
Instance Type: t3.micro
Security Group: SG-A
Tags: Environment=Dev
```

Engineer B may configure:

```text
Instance Type: t2.micro
Security Group: SG-B
Tags: Environment=Development
```

The infrastructure is now inconsistent.

IaC allows us to define the configuration once and reuse it.

## 4. Traditional Infrastructure vs IaC

### Traditional Approach

```text
Engineer
   ↓
Cloud Console
   ↓
Manual Configuration
   ↓
Infrastructure
```

### IaC Approach

```text
Engineer
   ↓
Infrastructure Code
   ↓
Version Control
   ↓
Terraform
   ↓
Cloud Provider API
   ↓
Infrastructure
```

## 5. Why Terraform?

There are many IaC technologies available.

Examples include:

| Platform / Technology             | IaC Tool                     |
| --------------------------------- | ---------------------------- |
| AWS                               | CloudFormation               |
| Azure                             | Azure Resource Manager / ARM |
| OpenStack                         | Heat                         |
| Multi-cloud                       | Terraform                    |
| Multi-cloud / Kubernetes-oriented | Crossplane                   |
| Multi-cloud                       | Pulumi                       |

The challenge with cloud-specific IaC tools is that organizations may use multiple cloud platforms.

For example:

```text
Company
│
├── AWS
├── Azure
├── GCP
└── OpenStack
```

Learning a different IaC technology for every provider increases the learning and maintenance burden.

Terraform provides a common configuration language and provider-based architecture.

```text
                   Terraform
                       │
        ┌──────────────┼──────────────┐
        ↓              ↓              ↓
       AWS           Azure           GCP
        │              │              │
       APIs           APIs           APIs
```

The same Terraform concepts can therefore be used across multiple infrastructure providers.

## 6. Terraform

Terraform is an Infrastructure as Code tool originally created by HashiCorp.

Terraform allows infrastructure to be described declaratively.

We define:

> **What infrastructure should exist?**

Terraform determines:

> **What operations are required to reach that desired state?**

For example:

```text
Desired State

1 VPC
1 Subnet
1 EC2 Instance
1 Security Group
```

Terraform compares the configuration and known state with the infrastructure and determines what changes are required.

## 7. Declarative Infrastructure

Terraform follows a declarative approach.

### Imperative Approach

An imperative approach describes **how** to perform an operation.

Example:

```text
1. Create VPC
2. Create subnet
3. Create security group
4. Create EC2 instance
5. Attach security group
```

### Declarative Approach

Terraform configuration describes **what** should exist.

```text
VPC
Subnet
Security Group
EC2 Instance
```

Terraform determines the required actions.

## 8. Terraform and APIs

Cloud providers expose APIs for their services.

Terraform communicates with providers using these APIs.

Simplified architecture:

```text
Terraform HCL
     ↓
Terraform Core
     ↓
Provider
     ↓
Cloud Provider API
     ↓
AWS / Azure / GCP / etc.
```

For AWS:

```text
main.tf
   ↓
Terraform
   ↓
AWS Provider
   ↓
AWS APIs
   ↓
EC2 / VPC / S3 / IAM / etc.
```

## 9. What Is HCL?

Terraform configurations are generally written using **HCL — HashiCorp Configuration Language**.

Example:

```hcl
resource "aws_instance" "example" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"

  tags = {
    Name = "terraform-demo"
  }
}
```

HCL is designed to be human-readable while remaining machine-processable.

## 10. Terraform Providers

A provider allows Terraform to communicate with an external platform or service.

Examples:

```text
AWS Provider
Azure Provider
Google Provider
Kubernetes Provider
GitHub Provider
```

For AWS:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

This tells Terraform that AWS is the target platform and that the specified region should be used.

## 11. Why Terraform Is Important for DevOps Engineers

Terraform is widely used in modern DevOps and cloud environments because infrastructure increasingly needs to be:

* automated
* repeatable
* scalable
* version-controlled
* auditable
* consistent
* reproducible

A typical enterprise workflow can look like:

```text
Developer / DevOps Engineer
          ↓
   Terraform Code
          ↓
         Git
          ↓
      Code Review
          ↓
   CI/CD Pipeline
          ↓
   Terraform Plan
          ↓
      Approval
          ↓
   Terraform Apply
          ↓
Cloud Infrastructure
```

## 12. Terraform Alternatives

Terraform is not the only IaC solution.

Other technologies include:

* AWS CloudFormation
* Azure ARM/Bicep
* Pulumi
* Crossplane
* OpenStack Heat

Terraform's major advantage is its broad provider ecosystem and consistent workflow across infrastructure platforms.

## 13. Key Benefits of Terraform

#### 13.1 Automation

Infrastructure can be provisioned automatically.

#### 13.2 Repeatability

The same configuration can be reused.

#### 13.3 Version Control

Terraform files can be stored in Git.

#### 13.4 Reviewability

Infrastructure changes can be reviewed through pull requests.

#### 13.5 Consistency

The same configuration can be used across environments.

#### 13.6 Collaboration

Multiple engineers can work with infrastructure as code.

#### 13.7 Disaster Recovery

Infrastructure can be recreated from version-controlled configuration.

## 14. Important Concept — Desired State

Terraform works around the concept of desired state.

For example:

```text
Terraform Configuration

1 EC2 Instance
Instance Type = t3.micro
Environment = dev
```

This represents the desired state.

Terraform compares this with the infrastructure and state it knows about and determines what needs to change.

## 15. Learning Outcome

By the end of this section, we should understand:

```text
Infrastructure
      ↓
Infrastructure as Code
      ↓
  Terraform
      ↓
     HCL
      ↓
   Provider
      ↓
   Cloud API
```

The key takeaway is:

> **Terraform allows infrastructure to be defined and managed as code instead of relying on manual cloud-console operations.**
