
## 04 — Writing the First Terraform Code, Lifecycle and State

**File:** 📄 `04-first-terraform-code-lifecycle-and-state.md`

## Table of Contents

1. [Introduction](#1-introduction)
2. [Terraform Configuration Files](#2-terraform-configuration-files)
3. [Basic Terraform Structure](#3-basic-terraform-structure)
4. [Provider Block](#4-provider-block)
5. [Resource Block](#5-resource-block)
6. [EC2 Resource](#6-ec2-resource)
7. [AMI Is Region-Specific](#7-ami-is-region-specific)
8. [Terraform Documentation](#8-terraform-documentation)
9. [Terraform Lifecycle](#9-terraform-lifecycle)
10. [`terraform init`](#10-terraform-init)
11. [`terraform plan`](#11-terraform-plan)
12. [Why `terraform plan` Is Important](#12-why-terraform-plan-is-important)
13. [`terraform apply`](#13-terraform-apply)
14. [Terraform Apply Flow](#14-terraform-apply-flow)
15. [Terraform State](#15-terraform-state)
16. [What Is Terraform State?](#16-what-is-terraform-state)
17. [Desired State vs Current Infrastructure](#17-desired-state-vs-current-infrastructure)
18. [Why State Is Important](#18-why-state-is-important)
19. [Never Commit Local State Carelessly](#19-never-commit-local-state-carelessly)
20. [Terraform State Is Not the Same as Configuration](#20-terraform-state-is-not-the-same-as-configuration)
21. [`terraform destroy`](#21-terraform-destroy)
22. [Complete Terraform Lifecycle](#22-complete-terraform-lifecycle)
23. [Important Concepts](#23-important-concepts)
24. [Practical Project](#24-practical-project)

- [Summary](#summary)

## 1. Introduction

We are now ready to write our first Terraform configuration.

> The objective of this practical exercise is to create an EC2 instance on AWS.

The learning flow is:

```text
Write Terraform Code
        ↓
terraform init
        ↓
terraform plan
        ↓
terraform apply
        ↓
EC2 Instance
        ↓
terraform destroy
```

## 2. Terraform Configuration Files

Terraform configuration files normally use:

```text
.tf
```

extension.

Example:

```text
main.tf
```

Terraform does not technically require the file to be named `main.tf`.

For example:

```text
main.tf
provider.tf
variables.tf
outputs.tf
```

are all valid.

> For a beginner project, keeping the initial configuration in `main.tf` makes the project easier to understand.

## 3. Basic Terraform Structure

A Terraform configuration commonly contains blocks such as:

```text
terraform
provider
resource
data
variable
output
module
```

For our first project, we primarily need:

```text
provider
resource
```

## 4. Provider Block

Example:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

> This defines AWS as our infrastructure provider.

## 5. Resource Block

> Terraform resources represent infrastructure objects.

Generic syntax:

```hcl
resource "<RESOURCE_TYPE>" "<LOCAL_NAME>" {

}
```

Example:

```hcl
resource "aws_instance" "example" {

}
```

Here:

```text
aws_instance
```

is the resource type.

```text
example
```

is the Terraform local name.

## 6. EC2 Resource

A simple EC2 resource can look like:

```hcl
resource "aws_instance" "example" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"

  tags = {
    Name = "terraform-demo"
  }
}
```

The important attributes are:

### AMI

```hcl
ami = "ami-xxxxxxxx"
```

Specifies the Amazon Machine Image.

### Instance Type

```hcl
instance_type = "t3.micro"
```

Defines the EC2 instance size.

### Tags

```hcl
tags = {
  Name = "terraform-demo"
}
```

Adds metadata to the resource.

## 7. AMI Is Region-Specific

> An important AWS concept is that AMI IDs are generally region-specific.

An AMI that works in:

```text
us-east-1
```

may not be valid in:

```text
ap-south-1
```

Therefore, do not blindly copy an AMI ID from another region.

> Always verify the AMI in the AWS region selected by the Terraform provider.

## 8. Terraform Documentation

We do not need to memorize every Terraform resource syntax.

Professional Terraform development relies heavily on documentation.

For example:

```text
Terraform Registry
      ↓
AWS Provider
      ↓
aws_instance
      ↓
Examples
      ↓
Required Arguments
      ↓
Optional Arguments
```

This is an important skill:

> **Learn how to find and correctly use [Terraform documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) rather than trying to memorize every resource argument.**

## 9. Terraform Lifecycle

The basic Terraform lifecycle used in this project is:

```text
terraform init
       ↓
terraform plan
       ↓
terraform apply
       ↓
Infrastructure
       ↓
terraform destroy
```

Each command serves a different purpose.

## 10. `terraform init`

Command:

```bash
terraform init
```

Purpose:

> Initialize the Terraform working directory.

Terraform reads the configuration and installs required providers.

For our AWS project:

```text
main.tf
   ↓
terraform init
   ↓
AWS Provider Download
   ↓
Terraform Working Directory Ready
```

## 11. `terraform plan`

Command:

```bash
terraform plan
```

Purpose:

> Preview the changes Terraform intends to make.

It does not normally create the infrastructure.

Example:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

This means Terraform expects:

```text
1 resource → Create
0 resources → Modify
0 resources → Destroy
```

## 12. Why `terraform plan` Is Important

> The plan acts as a review step.

Before applying infrastructure changes, we should inspect the plan.

For example:

```text
Terraform Plan
      ↓
1 EC2 instance
Instance Type = t3.micro
AMI = selected AMI
Tags = terraform-demo
```

If something looks incorrect, we fix the Terraform code before applying.

> In enterprise environments, `terraform plan` is commonly integrated into CI/CD and code-review workflows.

## 13. `terraform apply`

Command:

```bash
terraform apply
```

Terraform displays the proposed changes and normally asks for confirmation.

Example:

```text
Do you want to perform these actions?
  Only 'yes' will be accepted to approve.
```

Enter:

```text
yes
```

> Terraform then calls the AWS APIs and provisions the infrastructure.

## 14. Terraform Apply Flow

```text
terraform apply
       ↓
Terraform reads configuration
       ↓
Terraform evaluates state
       ↓
Terraform determines required changes
       ↓
AWS Provider
       ↓
    AWS API
       ↓
EC2 Instance Created
```

## 15. Terraform State

> After applying infrastructure, Terraform creates a state file.

The default local state file is:

```text
terraform.tfstate
```

This file is extremely important.

## 16. What Is Terraform State?

> Terraform state records information about infrastructure managed by Terraform.

Simplified:

```text
Terraform Configuration
        ↓
Desired State

terraform.tfstate
        ↓
Known Infrastructure State

       AWS
        ↓
Actual Infrastructure
```

Terraform uses state to understand the relationship between the configuration and infrastructure it manages.

## 17. Desired State vs Current Infrastructure

Suppose our configuration says:

```text
1 EC2 instance
```

Terraform creates the instance.

> State records information about that managed resource.

Later we change:

```text
instance_type = "t3.small"
```

Terraform can compare the configuration and known state and determine that the EC2 instance needs to be modified.

## 18. Why State Is Important

> Without state, Terraform would have difficulty efficiently tracking the resources it manages.

State helps Terraform determine:

```text
What resources are managed?
What are their IDs?
What attributes are known?
What changes are required?
```

## 19. Never Commit Local State Carelessly

A local state file can contain sensitive information.

Therefore, do not blindly commit:

```text
terraform.tfstate
terraform.tfstate.*
```

to Git.

> A standard `.gitignore` should generally include Terraform state files.

Example:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
*.tfvars.json
crash.log
crash.*.log
```

> For production, Terraform state is commonly stored remotely with appropriate locking, access control, encryption, and backup mechanisms.

## 20. Terraform State Is Not the Same as Configuration

These are different:

```text
main.tf
```

defines the desired infrastructure.

```text
terraform.tfstate
```

records Terraform's state information about managed infrastructure.

Think of it as:

```text
main.tf
   =
"What should exist?"

terraform.tfstate
   =
"What Terraform currently knows about what exists."
```

## 21. `terraform destroy`

When the lab is finished, run:

```bash
terraform destroy
```

Terraform calculates which managed resources need to be removed.

It normally asks for confirmation.

Enter:

```text
yes
```

Terraform then deletes the managed infrastructure.

## 22. Complete Terraform Lifecycle

For this project:

```text
┌────────────────────┐
│ Write main.tf      │
└──────────┬─────────┘
           ↓
┌────────────────────┐
│ terraform init     │
│ Initialize         │
└──────────┬─────────┘
           ↓
┌────────────────────┐
│ terraform plan     │
│ Preview            │
└──────────┬─────────┘
           ↓
┌────────────────────┐
│ terraform apply    │
│ Provision          │
└──────────┬─────────┘
           ↓
┌────────────────────┐
│ AWS EC2            │
└──────────┬─────────┘
           ↓
┌────────────────────┐
│ terraform destroy  │
│ Cleanup            │
└────────────────────┘
```

## 23. Important Concepts

By the end of, we should understand:

```text
IaC
Terraform
HCL
Provider
Resource
AWS Provider
terraform init
terraform plan
terraform apply
Terraform State
terraform destroy
```

The most important conceptual flow is:

```text
HCL
 ↓
Terraform
 ↓
Provider
 ↓
API
 ↓
Infrastructure
```

## 24. Practical Project

The following project demonstrates how to provision an AWS EC2 instance using Terraform.

**Project:** [AWS EC2 Instance Provisioning Using Terraform](project-ec2-instance/README.md)

## Summary

### What problem does Terraform solve?

Terraform solves the problem of manually provisioning and maintaining infrastructure by allowing infrastructure to be defined as code.

### Why Infrastructure as Code?

IaC provides:

```text
Automation
Consistency
Repeatability
Version Control
Auditability
Scalability
Collaboration
```

### Why Terraform?

Terraform provides a consistent workflow across many infrastructure providers.

### What is HCL?

HCL is Terraform's primary configuration language.

### What is a provider?

A provider allows Terraform to communicate with an external platform such as AWS.

### What is a resource?

A resource represents infrastructure managed by Terraform.

Example:

```hcl
resource "aws_instance" "terraform_demo" {
}
```

### What does `terraform init` do?

It initializes the Terraform working directory and installs required providers.

### What does `terraform plan` do?

It previews the changes Terraform intends to make.

### What does `terraform apply` do?

It applies the Terraform configuration and provisions or modifies infrastructure.

### What does `terraform destroy` do?

It destroys resources managed by the Terraform configuration/state.

### What is Terraform State?

Terraform state records information Terraform uses to track managed infrastructure and reconcile configuration with infrastructure.
