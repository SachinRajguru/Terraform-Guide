
## Terraform EC2 Module — Practical Project

> **File:** `README.md`

## Table of Contents

* [Overview](#overview)
* [Architecture](#architecture)
* [Project Structure](#project-structure)
* [Prerequisites](#prerequisites)
* [Module Design](#module-design)
* [Step-by-Step Execution](#step-by-step-execution)
  * [Step 1 — Create the Local Variables File](#step-1--create-the-local-variables-file)
  * [Step 2 — Review the Root Module](#step-2--review-the-root-module)
  * [Step 3 — Initialize Terraform](#step-3--initialize-terraform)
  * [Step 4 — Format the Configuration](#step-4--format-the-configuration)
  * [Step 5 — Validate the Configuration](#step-5--validate-the-configuration)
  * [Step 6 — Review the Terraform Plan](#step-6--review-the-terraform-plan)
  * [Step 7 — Apply the Configuration](#step-7--apply-the-configuration)
  * [Step 8 — Review Terraform Outputs](#step-8--review-terraform-outputs)
  * [Step 9 — Inspect Terraform State](#step-9--inspect-terraform-state)
  * [Understanding the Complete Data Flow](#understanding-the-complete-data-flow)
* [Module Files](#module-files)
  * [Root `versions.tf`](#root-versionstf)
  * [Root `variables.tf`](#root-variablestf)
  * [Root `main.tf`](#root-maintf)
  * [Root `outputs.tf`](#root-outputstf)
* [Child Module](#child-module-1)
  * [`modules/ec2/versions.tf`](#modulesec2versionstf)
  * [`modules/ec2/variables.tf`](#modulesec2variablestf)
  * [`modules/ec2/main.tf`](#modulesec2maintf)
  * [`modules/ec2/outputs.tf`](#modulesec2outputstf)
* [Validation Checklist](#validation-checklist)
* [Cleanup](#cleanup)
* [Learning Outcomes](#learning-outcomes)
* [Related Documentation](#related-documentation)
* [Final Project Flow](#final-project-flow)

## Overview

This project demonstrates how a standard Terraform EC2 configuration can be transformed into a reusable **Terraform module**.

The implementation starts with a root Terraform configuration and delegates EC2 instance creation to a reusable local child module.

The project demonstrates:

* Terraform module structure
* Root and child modules
* Module inputs
* Module outputs
* Local module sources
* Terraform provider requirements
* Terraform initialization and validation
* Infrastructure planning and deployment
* Terraform state management
* Infrastructure cleanup

For the conceptual and detailed explanation of Terraform Modules, refer to:

**[Terraform Modules — Complete Guide](../01-modules.md)**

## Architecture

The project follows a simple root-module and child-module architecture:

```text
                   Root Module
                project-ec2-module/
                        |
                        |
                   module "ec2"
                        |
                        v
                 EC2 Child Module
                   modules/ec2/
                        |
                        v
                 AWS EC2 Instance
```

The root module is responsible for:

* Configuring the AWS provider
* Defining project-level variables
* Calling the EC2 module
* Supplying module inputs
* Exposing module outputs

The child module is responsible for:

* Defining the EC2 resource
* Accepting configuration through variables
* Exposing useful EC2 attributes through outputs

## Project Structure

```text
project-ec2-module/
│
├── README.md
├── versions.tf
├── main.tf
├── variables.tf
├── terraform.tfvars.example
├── outputs.tf
│
└── modules/
    └── ec2/
        ├── versions.tf
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### Root Module

| File                       | Purpose                                              |
| -------------------------- | ---------------------------------------------------- |
| `versions.tf`              | Defines Terraform and AWS provider requirements      |
| `main.tf`                  | Configures AWS and calls the EC2 module              |
| `variables.tf`             | Defines root module input variables                  |
| `terraform.tfvars.example` | Provides an example configuration for root variables |
| `outputs.tf`               | Exposes values returned by the EC2 module            |
| `README.md`                | Documents the practical project                      |

### Child Module

| File           | Purpose                                                |
| -------------- | ------------------------------------------------------ |
| `versions.tf`  | Declares provider requirements for the reusable module |
| `main.tf`      | Defines the EC2 instance                               |
| `variables.tf` | Defines module input variables                         |
| `outputs.tf`   | Defines module output values                           |

## Prerequisites

Before executing this project, ensure that the following tools are installed and configured.

| Tool        | Purpose                             |
| ----------- | ----------------------------------- |
| Terraform   | Infrastructure as Code              |
| AWS CLI     | AWS command-line access             |
| Git         | Version control                     |
| AWS Account | Infrastructure deployment           |
| Code Editor | Terraform configuration development |

### Verify Terraform

Run:

```bash
terraform version
```

The project should be executed using a currently supported Terraform CLI release.

Record the exact Terraform version used for the project so that the execution environment remains reproducible.

### Verify AWS CLI

Run:

```bash
aws --version
```

### Verify AWS Authentication

Run:

```bash
aws sts get-caller-identity
```

A successful response confirms that the AWS CLI can authenticate with the configured AWS account.

Example:

```text
{
    "UserId": "...",
    "Account": "...",
    "Arn": "..."
}
```

> Do not commit AWS credentials to the repository.

## Module Design

The project follows a simple input/output interface.

```text
Root Module
     |
     | Inputs
     v
EC2 Child Module
     |
     | Creates
     v
AWS EC2 Instance
     |
     | Outputs
     v
Root Module
```

The root module supplies:

* AMI ID
* Instance type
* Instance name
* Environment

The child module returns:

* Instance ID
* Public IP
* Public DNS

## Step-by-Step Execution

### Step 1 — Create the Local Variables File

The repository contains:

```text
terraform.tfvars.example
```

Create the local `terraform.tfvars` file from the example:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Then update the values:

```hcl
aws_region    = "us-east-1"
ami_id        = "<ami-id>"
instance_type = "t3.micro"
instance_name = "terraform-module-demo"
environment   = "dev"
```

> `terraform.tfvars` should normally remain uncommitted when it contains environment-specific or sensitive values.

### Step 2 — Review the Root Module

The root module configures the AWS provider and calls the child module.

```hcl
provider "aws" {
  region = var.aws_region
}

module "ec2" {
  source = "./modules/ec2"

  ami_id        = var.ami_id
  instance_type = var.instance_type
  instance_name = var.instance_name
  environment   = var.environment
}
```

The important part is:

```hcl
module "ec2" {
  source = "./modules/ec2"
}
```

The `source` tells Terraform where the local child module is located.

### Step 3 — Initialize Terraform

From:

```text
03-modules/project-ec2-module/
```

run:

```bash
terraform init
```

Terraform initializes:

* The working directory
* The AWS provider
* The local module
* Dependency information

A successful initialization should complete without errors.

### Step 4 — Format the Configuration

Run:

```bash
terraform fmt -recursive
```

This formats Terraform configuration files, including files inside the child module.

### Step 5 — Validate the Configuration

Run:

```bash
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

This confirms that the Terraform configuration is syntactically and structurally valid.

### Step 6 — Review the Terraform Plan

Run:

```bash
terraform plan
```

Review the proposed changes carefully.

The plan should show the EC2 instance that will be created through the module.

Conceptually:

```text
Root Module
     |
     v
module.ec2
     |
     v
aws_instance.this
```

The module itself is not an AWS resource.

The child module contains the resource that Terraform ultimately creates.

### Step 7 — Apply the Configuration

Run:

```bash
terraform apply
```

Review the proposed changes.

Confirm:

```text
yes
```

Terraform will create the EC2 instance.

### Step 8 — Review Terraform Outputs

Run:

```bash
terraform output
```

The root module exposes values returned by the child module.

Example:

```text
instance_id = "i-xxxxxxxxxxxxxxxxx"
public_dns  = "ec2-xx-xx-xx-xx.compute-1.amazonaws.com"
public_ip   = "xx.xx.xx.xx"
```

The output flow is:

```text
aws_instance.this
        |
        v
Child Module Output
        |
        v
module.ec2.instance_id
        |
        v
Root Module Output
        |
        v
terraform output
```

### Step 9 — Inspect Terraform State

Run:

```bash
terraform state list
```

The resource managed by the module should appear in the state.

The resource address will follow the module path:

```text
module.ec2.aws_instance.this
```

This demonstrates an important Terraform concept:

> Resources created inside a child module are addressed through the module path.

### Understanding the Complete Data Flow

The complete project flow is:

```text
terraform.tfvars
       |
       v
Root Variables
       |
       v
module "ec2"
       |
       | Inputs
       v
Child Module Variables
       |
       v
aws_instance.this
       |
       | Outputs
       v
Child Module Outputs
       |
       v
Root Module Outputs
       |
       v
terraform output
```

This is the fundamental pattern for Terraform modules:

```text
Inputs
   |
   v
Module
   |
   v
Resources
   |
   v
Outputs
```

## Module Files

### Root `versions.tf`

```hcl
terraform {
  required_version = ">= 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.60"
    }
  }
}
```

### Root `variables.tf`

```hcl
variable "aws_region" {
  description = "AWS region where the EC2 instance will be created."
  type        = string
}

variable "ami_id" {
  description = "AMI ID used to launch the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}
```

### Root `main.tf`

```hcl
provider "aws" {
  region = var.aws_region
}

module "ec2" {
  source = "./modules/ec2"

  ami_id        = var.ami_id
  instance_type = var.instance_type
  instance_name = var.instance_name
  environment   = var.environment
}
```

### Root `outputs.tf`

```hcl
output "instance_id" {
  description = "EC2 instance ID."
  value       = module.ec2.instance_id
}

output "public_ip" {
  description = "EC2 public IP address."
  value       = module.ec2.public_ip
}

output "public_dns" {
  description = "EC2 public DNS address."
  value       = module.ec2.public_dns
}
```

## Child Module

### `modules/ec2/versions.tf`

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
```

### `modules/ec2/variables.tf`

```hcl
variable "ami_id" {
  description = "AMI ID used to launch the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "instance_name" {
  description = "Name tag for the EC2 instance."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}
```

### `modules/ec2/main.tf`

```hcl
resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name        = var.instance_name
    Environment = var.environment
  }
}
```

### `modules/ec2/outputs.tf`

```hcl
output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance."
  value       = aws_instance.this.public_ip
}

output "public_dns" {
  description = "Public DNS name of the EC2 instance."
  value       = aws_instance.this.public_dns
}
```

## Validation Checklist

After applying the configuration, verify:

### Terraform

```bash
terraform validate
```

### Terraform State

```bash
terraform state list
```

Expected resource path:

```text
module.ec2.aws_instance.this
```

### Terraform Outputs

```bash
terraform output
```

### AWS

Verify the EC2 instance through the AWS Management Console or AWS CLI.

## Cleanup

Always clean up the infrastructure after completing the lab if the resources are no longer required.

Run:

```bash
terraform destroy
```

Review the proposed destruction and confirm:

```text
yes
```

Terraform will destroy the EC2 instance managed by the module.

### Verify Cleanup

Run:

```bash
terraform state list
```

The EC2 resource should no longer appear.

We can also verify the instance through the AWS Management Console or AWS CLI.

### Important: Do Not Delete Terraform State

Do **not** simply delete:

```text
terraform.tfstate
```

to remove infrastructure.

Deleting Terraform state does not delete the actual AWS resources.

The correct process is:

```text
terraform destroy
       |
       v
AWS Resources Deleted
       |
       v
Terraform State Updated
```

## Learning Outcomes

After completing this project, we should be able to:

* Understand the purpose of Terraform modules.
* Distinguish between root and child modules.
* Create a local Terraform module.
* Define module input variables.
* Pass values from a root module to a child module.
* Define module outputs.
* Consume child-module outputs from the root module.
* Initialize and validate a module-based Terraform project.
* Inspect module-managed resources.
* Execute and validate infrastructure deployment.
* Safely destroy infrastructure after completing a lab.
* Understand how the same module pattern can be extended to larger infrastructure projects.

## Related Documentation

For the conceptual and detailed explanation of Terraform Modules, refer to:

**[Terraform Modules — Complete Guide](../01-modules.md)**

The main guide covers:

* Terraform module fundamentals
* Root and child modules
* Local modules
* Git/GitHub modules
* Terraform Registry modules
* Module versioning
* Module design
* Security considerations
* Troubleshooting
* Best practices
* Interview questions
* End-to-end module implementation

## Final Project Flow

```text
                    Root Module
               project-ec2-module/
                        |
                        |
                 module "ec2"
                        |
                        v
                  Child Module
                   modules/ec2/
                        |
                        v
                aws_instance.this
                        |
                        v
                    AWS EC2
```

The key concept demonstrated by this project is:

> The root module provides the configuration and inputs, while the child module encapsulates the reusable infrastructure implementation and exposes outputs back to the root module.
