
## 04 — Writing the First Terraform Code, Lifecycle and State

> **Path:** `Terraform-Guide/01-getting-started/`

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
25. [Summary](#25-summary)

## 1. Introduction

We are now ready to write our first Terraform configuration.

The objective of this practical exercise is to understand how Terraform configuration is written, initialized, planned, applied, tracked through state, and eventually destroyed.

For our first practical example, we will provision an AWS EC2 instance.

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
AWS EC2 Instance
        ↓
Terraform State
        ↓
terraform destroy
```

The important idea is that Terraform is not simply a command that creates infrastructure.

Terraform continuously works with three important concepts:

```text
Configuration
     +
State
     +
Real Infrastructure
     ↓
Terraform
     ↓
Execution Plan
     ↓
Required Changes
```

Terraform uses configuration and state to determine the changes required to make managed infrastructure match the configuration. Before planning changes, Terraform also refreshes its knowledge of remote objects.

## 2. Terraform Configuration Files

Terraform configuration files normally use the:

```text
.tf
```

file extension.

For example:

```text
main.tf
```

Terraform does not require the file to be named `main.tf`.

We can have multiple `.tf` files in the same Terraform working directory:

```text
project/
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
└── versions.tf
```

Terraform loads the configuration from the `.tf` files in the working directory.

For a beginner project, however, keeping the initial configuration in `main.tf` makes the structure easier to understand.

A simple beginner project might therefore look like:

```text
project-ec2-instance/
├── main.tf
└── README.md
```

As the project grows, we can separate configuration into logical files.

For example:

```text
project-ec2-instance/
├── versions.tf
├── provider.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

The file separation is for organization. Terraform does not require these exact filenames.

## 3. Basic Terraform Structure

Terraform configurations can contain several types of blocks.

Common Terraform blocks include:

```text
terraform
provider
resource
data
variable
locals
output
module
```

For our first project, we primarily need:

```text
terraform
provider
resource
```

A simplified configuration looks like:

```text
Terraform Configuration
        │
        ├── terraform block
        │
        ├── provider block
        │
        └── resource block
```

For example:

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  # Resource configuration
}
```

The `terraform` block can declare provider requirements, while the `provider` block configures a provider. Providers are separate plugins that Terraform installs and uses to communicate with external systems.

## 4. Provider Block

A provider allows Terraform to communicate with an external platform.

For AWS, we use the AWS provider.

A simple provider configuration is:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

This tells Terraform:

```text
Provider → AWS
Region   → us-east-1
```

The provider is responsible for translating Terraform operations into calls to the AWS APIs.

Conceptually:

```text
Terraform
    ↓
AWS Provider
    ↓
AWS APIs
    ↓
AWS Infrastructure
```

### 4.1 Declaring the Provider Requirement

Modern Terraform configurations should explicitly declare the provider source.

For example:

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
```

A production configuration will commonly also constrain the acceptable provider version:

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

The exact version constraint should be selected according to the project requirements and the provider version we intend to support.

Terraform uses the `required_providers` block to determine which provider to install, while the `provider` block configures that provider.

### 4.2 Provider Version vs Terraform Version

Terraform and the AWS provider are separate components.

For example:

```text
Terraform CLI
      +
AWS Provider
```

They have independent versions and release cycles.

Therefore:

```text
Terraform Version
        ≠
AWS Provider Version
```

This distinction becomes important as projects become larger and more production-oriented.

## 5. Resource Block

Terraform resources represent infrastructure objects that Terraform manages.

Generic syntax:

```hcl
resource "<RESOURCE_TYPE>" "<LOCAL_NAME>" {

}
```

For example:

```hcl
resource "aws_instance" "example" {

}
```

Here:

```text
aws_instance
```

is the resource type.

And:

```text
example
```

is the Terraform local name.

Therefore:

```text
resource "aws_instance" "example"
          └──────┬──────┘
             Resource Type

resource "aws_instance" "example"
                        └───────┘
                         Local Name
```

The resource type tells Terraform which provider resource should be used.

The local name identifies that particular resource within the Terraform configuration.

For example:

```hcl
resource "aws_instance" "web" {

}
```

and:

```hcl
resource "aws_instance" "database" {

}
```

are two different Terraform resource instances, even though they use the same resource type.

## 6. EC2 Resource

We can define an AWS EC2 instance using the `aws_instance` resource.

A simplified example is:

```hcl
resource "aws_instance" "example" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"

  tags = {
    Name = "terraform-demo"
  }
}
```

### 6.1 AMI

```hcl
ami = "ami-xxxxxxxx"
```

The `ami` argument specifies the Amazon Machine Image used to launch the instance.

The value:

```text
ami-xxxxxxxx
```

is only a placeholder.

We must use a valid AMI ID for the selected AWS region.

### 6.2 Instance Type

```hcl
instance_type = "t3.micro"
```

The instance type determines the compute characteristics of the EC2 instance.

Examples include:

```text
t3.micro
t3.small
t3.medium
```

The appropriate instance type depends on the workload, cost requirements, availability, and project objectives.

### 6.3 Tags

```hcl
tags = {
  Name = "terraform-demo"
}
```

Tags help us identify and organize AWS resources.

For example:

```text
Name = terraform-demo
```

can make the EC2 instance easier to identify in the AWS console.

Tags are also useful for:

* Cost allocation
* Resource organization
* Automation
* Operations
* Governance
* Environment identification

A more descriptive example might be:

```hcl
tags = {
  Name        = "terraform-demo"
  Environment = "dev"
  ManagedBy   = "Terraform"
}
```

## 7. AMI Is Region-Specific

An important AWS concept is that AMI IDs are generally region-specific.

For example:

```text
AMI in us-east-1
       ≠
AMI in ap-south-1
```

An AMI ID that works in:

```text
us-east-1
```

may not be valid in:

```text
ap-south-1
```

Therefore, we should never blindly copy an AMI ID from another region.

The relationship is:

```text
AWS Region
     ↓
Available AMIs
     ↓
Select compatible AMI
     ↓
Terraform aws_instance
```

For example:

```hcl
provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "example" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"
}
```

The AMI must be valid for `ap-south-1`.

> Always verify the AMI in the AWS region selected by the Terraform provider.

For reusable projects, hard-coding an AMI ID is often not ideal. We can later learn how to use data sources to dynamically locate an appropriate AMI.

## 8. Terraform Documentation

We do not need to memorize every Terraform resource argument.

Professional Terraform development relies heavily on documentation.

A typical workflow is:

```text
Requirement
    ↓
Terraform Registry
    ↓
AWS Provider
    ↓
Resource
    ↓
Documentation
    ↓
Required Arguments
    ↓
Optional Arguments
    ↓
Examples
    ↓
Terraform Configuration
```

For example, if we want to create an EC2 instance:

```text
aws_instance
```

we should consult the AWS provider documentation for the resource rather than guessing its arguments.

The Terraform Registry contains provider documentation and version-specific information.

> **Important professional skill:**
> Learn how to find and correctly use Terraform documentation rather than trying to memorize every resource argument.

## 9. Terraform Lifecycle

The basic Terraform workflow used in this project is:

```text
Write Configuration
        ↓
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

| Command              | Purpose                                              |
| -------------------- | ---------------------------------------------------- |
| `terraform init`     | Initialize the working directory                     |
| `terraform validate` | Validate the configuration syntax and structure      |
| `terraform plan`     | Preview proposed infrastructure changes              |
| `terraform apply`    | Apply the proposed changes                           |
| `terraform destroy`  | Create and apply a plan to destroy managed resources |

A practical workflow is therefore:

```text
Write
  ↓
Format
  ↓
Validate
  ↓
Initialize
  ↓
Plan
  ↓
Review
  ↓
Apply
  ↓
Verify
  ↓
Destroy
```

We will use `terraform validate` as part of the practical workflow even though the core lifecycle is usually introduced using `init → plan → apply`.

## 10. `terraform init`

Command:

```bash
terraform init
```

Purpose:

> Initialize the Terraform working directory.

Terraform reads the configuration and installs the required providers.

For our AWS project:

```text
main.tf
   ↓
terraform init
   ↓
Read provider requirements
   ↓
Resolve provider version
   ↓
Download AWS provider
   ↓
Update dependency lock file
   ↓
Terraform Working Directory Ready
```

Terraform CLI installs providers when initializing a working directory. If a provider requirement or configuration changes, the working directory may need to be reinitialized.

A successful initialization normally ends with a message similar to:

```text
Terraform has been successfully initialized!
```

## 11. `terraform plan`

Command:

```bash
terraform plan
```

Purpose:

> Preview the changes Terraform proposes to make to the infrastructure.

Terraform compares:

```text
Configuration
      +
Current State
      +
Current Remote Objects
      ↓
Execution Plan
```

For a new EC2 resource, the plan may contain:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

This means Terraform proposes:

```text
1 resource  → Create
0 resources → Change
0 resources → Destroy
```

The `plan` command does not normally make the proposed infrastructure changes. It creates an execution plan that we can review before applying it.

### 11.1 Typical Plan Symbols

Terraform commonly displays symbols such as:

```text
+   create
~   update in-place
-   destroy
-/+ destroy and recreate
```

For example:

```text
+ aws_instance.example
```

means Terraform plans to create the resource.

An update may appear as:

```text
~ aws_instance.example
```

A replacement may be shown as:

```text
-/+ aws_instance.example
```

The exact change depends on the resource and the provider's behavior.

## 12. Why `terraform plan` Is Important

The plan acts as a review step.

Before applying infrastructure changes, we should inspect the plan carefully.

For example:

```text
Terraform Plan
       ↓
Create EC2 Instance
       ↓
AMI = selected AMI
       ↓
Instance Type = t3.micro
       ↓
Tags = terraform-demo
```

If something looks incorrect, we should fix the Terraform configuration before applying it.

For example, if we intended:

```text
t3.micro
```

but the plan shows:

```text
m5.large
```

we should investigate before proceeding.

The plan is especially important in professional environments because infrastructure changes can affect:

* Cost
* Availability
* Security
* Networking
* Data
* Production workloads

Terraform planning is also commonly incorporated into code-review and CI/CD workflows.

## 13. `terraform apply`

Command:

```bash
terraform apply
```

Terraform creates an execution plan and, when run interactively without a saved plan file, normally asks for approval before making the changes.

Example:

```text
Do you want to perform these actions?

  Terraform will perform the following actions:

  ...

  Only 'yes' will be accepted to approve.
```

Enter:

```text
yes
```

Terraform then executes the approved changes through the configured provider.

Conceptually:

```text
terraform apply
        ↓
Execution Plan
        ↓
Review / Approval
        ↓
AWS Provider
        ↓
AWS API
        ↓
EC2 Instance
```

After a successful apply, Terraform updates its state to record the resulting managed infrastructure.

### 13.1 Important: `apply` Does Not Mean "Create Only"

Terraform is declarative.

Therefore:

```bash
terraform apply
```

can potentially:

```text
Create resources
Update resources
Replace resources
Destroy resources
```

depending on the difference between the desired configuration and the infrastructure represented by the current state and remote objects.

For example:

```text
Configuration Change
        ↓
terraform plan
        ↓
Determine Required Action
        ↓
Create / Update / Replace / Destroy
```

## 14. Terraform Apply Flow

A simplified Terraform apply flow is:

```text
terraform apply
       ↓
Read Configuration
       ↓
Load Terraform State
       ↓
Refresh Remote Objects
       ↓
Determine Differences
       ↓
Create Execution Plan
       ↓
Review / Approval
       ↓
AWS Provider
       ↓
AWS API
       ↓
Infrastructure Changes
       ↓
Update Terraform State
```

This is more accurate than thinking of Terraform as simply:

```text
main.tf → AWS
```

Terraform maintains a relationship between:

```text
Configuration
      ↕
Terraform State
      ↕
Remote Infrastructure
```

That relationship is fundamental to understanding Terraform.

## 15. Terraform State

After infrastructure is created, Terraform maintains state.

With the default local backend, the state is stored in:

```text
terraform.tfstate
```

Terraform state is one of the most important concepts in Terraform.

A simplified project may look like:

```text
project/
├── main.tf
├── .terraform/
├── .terraform.lock.hcl
└── terraform.tfstate
```

The exact files present depend on the configuration and Terraform operations performed.

## 16. What Is Terraform State?

Terraform state is the information Terraform stores about the infrastructure managed by a Terraform configuration.

HashiCorp describes the primary purpose of state as maintaining the bindings between Terraform resource instances and real-world remote objects. Terraform uses state to map resources in configuration to objects in the remote system and to determine required changes.

A simplified model is:

```text
Terraform Configuration
        ↓
Desired Configuration
        ↓
Terraform State
        ↓
Remote Infrastructure
```

For example:

```hcl
resource "aws_instance" "example" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"
}
```

Terraform state can contain information that associates:

```text
aws_instance.example
        ↓
EC2 Instance ID
        ↓
i-xxxxxxxxxxxxxxxxx
```

This mapping is essential.

Without such a mapping, Terraform would have difficulty determining which real-world object corresponds to a Terraform resource instance.

## 17. Desired State vs Current Infrastructure

This distinction is extremely important.

Suppose our configuration defines:

```text
1 EC2 instance
```

Terraform creates the instance and records information about it in state.

Later, we change:

```hcl
instance_type = "t3.small"
```

Terraform can compare the configuration with the current state and refresh its knowledge of the remote object before determining the required changes.

Conceptually:

```text
Configuration
    ↓
What we want
    ↓
Terraform
    ↑
State
    ↑
What Terraform knows
    ↑
Remote Infrastructure
    ↑
What actually exists
```

The three concepts should not be treated as identical.

### Configuration

Defines what we want Terraform to manage.

```text
Desired configuration
```

### State

Records Terraform's knowledge and resource-to-object mappings.

```text
Terraform's recorded state
```

### Remote Infrastructure

The actual objects existing in AWS.

```text
Real infrastructure
```

Terraform uses these concepts together when creating an execution plan.

## 18. Why State Is Important

Terraform state helps answer questions such as:

```text
Which resources are managed?

Which remote objects correspond to those resources?

What resource IDs are associated with them?

What attributes are known?

What changes are required?
```

For example:

```text
Terraform Resource
aws_instance.example
        ↓
Terraform State
        ↓
EC2 Instance ID
i-xxxxxxxxxxxxxxxxx
        ↓
AWS EC2 Instance
```

State therefore acts as an important mapping layer between Terraform configuration and real-world infrastructure.

Terraform requires state to function correctly as an infrastructure management system.

## 19. Never Commit Local State Carelessly

Terraform state can contain sensitive information depending on the resources and providers being managed.

Therefore, we should never blindly commit local state files to Git.

Avoid committing:

```text
terraform.tfstate
terraform.tfstate.*
```

A typical `.gitignore` can include:

```gitignore
# Terraform working directory
.terraform/

# Terraform state files
*.tfstate
*.tfstate.*

# Terraform variable files
*.tfvars
*.tfvars.json

# Crash logs
crash.log
crash.*.log

# Optional local override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Terraform plan files
*.tfplan
```

> The exact `.gitignore` policy should be adapted to the repository and organization's requirements.

### 19.1 State Can Contain Sensitive Data

We should treat Terraform state as sensitive.

Do not assume that:

```text
Terraform state = harmless metadata
```

Instead:

```text
Terraform state
      ↓
Potentially sensitive
      ↓
Protect appropriately
```

HashiCorp recommends avoiding state storage in version control and recommends secure state storage with appropriate access control and collaboration mechanisms.

### 19.2 Remote State

For team and production environments, state is commonly stored remotely.

Conceptually:

```text
Developer / CI/CD
       ↓
Terraform
       ↓
Remote Backend
       ↓
Terraform State
```

A remote backend can provide centralized state storage and, depending on the backend, locking and access-control capabilities.

HashiCorp recommends HCP Terraform or an appropriate remote backend for secure collaboration rather than relying on local state files.

## 20. Terraform State Is Not the Same as Configuration

These are different concepts.

### Terraform Configuration

For example:

```text
main.tf
```

defines what we want Terraform to manage.

Think:

```text
"What should Terraform manage?"
```

### Terraform State

For example:

```text
terraform.tfstate
```

records Terraform's current state information and mappings for managed infrastructure.

Think:

```text
"What does Terraform currently know about the
infrastructure it manages?"
```

### Remote Infrastructure

For example:

```text
AWS EC2
```

is the actual infrastructure.

Think:

```text
"What actually exists in AWS?"
```

The relationship is:

```text
                Desired
              Configuration
                   │
                   ↓
              ┌─────────┐
              │Terraform│
              └────┬────┘
                   │
          ┌────────┴────────┐
          ↓                 ↓
        State         Remote Infrastructure
          │                 │
          └───────┬─────────┘
                  ↓
          Execution Plan
```

This distinction becomes increasingly important when we learn:

* Remote state
* State locking
* State migration
* Import
* Drift
* Modules
* Workspaces
* CI/CD
* Infrastructure recovery

## 21. `terraform destroy`

When the lab is finished, we should clean up the resources created during practice.

Run:

```bash
terraform destroy
```

Terraform creates an execution plan for destroying the resources managed by the current workspace.

It normally asks for confirmation.

Example:

```text
Do you really want to destroy all resources?

Only 'yes' will be accepted to confirm.
```

Enter:

```text
yes
```

Terraform then calls the provider APIs to remove the managed infrastructure.

Conceptually:

```text
terraform destroy
        ↓
Read Configuration / State
        ↓
Determine Resources to Remove
        ↓
Create Destroy Plan
        ↓
Approval
        ↓
AWS Provider
        ↓
AWS API
        ↓
EC2 Instance Deleted
        ↓
State Updated
```

HashiCorp documents `terraform destroy` as creating an execution plan to delete all resources managed by the workspace.

> **Important:** Always verify the destroy plan before approving it, especially when working in shared or production environments.

## 22. Complete Terraform Lifecycle

For this project, the complete learning workflow is:

```text
┌───────────────────────────┐
│ Write Terraform Code      │
│ main.tf                   │
└─────────────┬─────────────┘
              ↓
┌───────────────────────────┐
│ terraform fmt             │
│ Format Configuration      │
└─────────────┬─────────────┘
              ↓
┌───────────────────────────┐
│ terraform init            │
│ Initialize                │
└─────────────┬─────────────┘
              ↓
┌───────────────────────────┐
│ terraform validate        │
│ Validate Configuration    │
└─────────────┬─────────────┘
              ↓
┌───────────────────────────┐
│ terraform plan            │
│ Preview Changes            │
└─────────────┬─────────────┘
              ↓
┌───────────────────────────┐
│ Review Plan               │
└─────────────┬─────────────┘
              ↓
┌───────────────────────────┐
│ terraform apply           │
│ Provision / Modify        │
└─────────────┬─────────────┘
              ↓
┌───────────────────────────┐
│ AWS Infrastructure        │
│ EC2 Instance              │
└─────────────┬─────────────┘
              ↓
┌───────────────────────────┐
│ Terraform State           │
└─────────────┬─────────────┘
              ↓
┌───────────────────────────┐
│ terraform destroy         │
│ Cleanup                   │
└───────────────────────────┘
```

The fundamental Terraform workflow can be summarized as:

```text
INIT
  ↓
PLAN
  ↓
APPLY
  ↓
MANAGE
  ↓
DESTROY
```

For professional workflows, we should also include:

```text
FMT
  ↓
VALIDATE
  ↓
PLAN
  ↓
REVIEW
  ↓
APPLY
```

## 23. Important Concepts

By the end of this section, we should understand:

```text
Infrastructure as Code
Terraform
HCL
Terraform Configuration
Provider
Provider Requirements
AWS Provider
Resource
AWS EC2
AMI
AWS Region
terraform init
terraform validate
terraform plan
terraform apply
Terraform State
Remote Infrastructure
terraform destroy
```

The most important conceptual flow is:

```text
HCL
 ↓
Terraform Configuration
 ↓
Provider
 ↓
API
 ↓
Infrastructure
```

But Terraform also maintains state:

```text
              Configuration
                   ↓
                Terraform
                   ↓
              Execution Plan
               ↙         ↘
            State       Provider
                          ↓
                         API
                          ↓
                    Infrastructure
```

This is the foundation for understanding more advanced Terraform concepts.

## 24. Practical Project

The following project demonstrates how to provision an AWS EC2 instance using Terraform.

### Project

**AWS EC2 Instance Provisioning Using Terraform**

Project location:

```text
01-getting-started/
└── project-ec2-instance/
    ├── main.tf
    └── README.md
```

Documentation:

[**AWS EC2 Instance Provisioning Using Terraform**](./project-ec2-instance/README.md)

The project should demonstrate the complete practical workflow:

```text
Configure AWS
      ↓
Write main.tf
      ↓
terraform init
      ↓
terraform fmt
      ↓
terraform validate
      ↓
terraform plan
      ↓
terraform apply
      ↓
Verify EC2
      ↓
terraform destroy
      ↓
Verify Cleanup
```

### 24.1 Example Configuration

A simplified configuration can look like:

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "terraform_demo" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"

  tags = {
    Name      = "terraform-demo"
    ManagedBy = "Terraform"
  }
}
```

> Replace the placeholder AMI ID with a valid AMI for the selected AWS region.

### 24.2 Practical Commands

From the project directory:

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

Preview the changes:

```bash
terraform plan
```

Apply the configuration:

```bash
terraform apply
```

After confirming the infrastructure is working, clean up:

```bash
terraform destroy
```

This ensures that the lab does not leave unnecessary AWS resources running.

## 25. Summary

### What problem does Terraform solve?

Terraform helps us define, provision, modify, and manage infrastructure through code rather than relying entirely on manual infrastructure operations.

### Why Infrastructure as Code?

Infrastructure as Code provides benefits such as:

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

Terraform provides a declarative infrastructure workflow and supports many infrastructure and service providers through provider plugins.

### What is HCL?

HCL, or HashiCorp Configuration Language, is Terraform's primary configuration language.

Example:

```hcl
resource "aws_instance" "example" {
  instance_type = "t3.micro"
}
```

### What is a provider?

A provider is a Terraform plugin that allows Terraform to communicate with an external platform or API.

For AWS:

```text
Terraform
    ↓
AWS Provider
    ↓
AWS API
```

Providers are installed separately from Terraform and have their own versions.

### What is a resource?

A resource represents an infrastructure object managed by Terraform.

Example:

```hcl
resource "aws_instance" "terraform_demo" {
  # configuration
}
```

Here:

```text
aws_instance
```

is the resource type, while:

```text
terraform_demo
```

is the local Terraform name.

### What does `terraform init` do?

It initializes the Terraform working directory and installs the required providers.

```bash
terraform init
```

### What does `terraform validate` do?

It checks whether the Terraform configuration is syntactically valid and internally consistent enough for Terraform to validate it.

```bash
terraform validate
```

### What does `terraform plan` do?

It creates an execution plan showing the changes Terraform proposes to make.

```bash
terraform plan
```

It allows us to review the proposed changes before applying them.

### What does `terraform apply` do?

It applies the Terraform configuration by executing the approved changes through the configured provider.

```bash
terraform apply
```

Depending on the configuration and current infrastructure, this can create, update, replace, or remove resources.

### What does `terraform destroy` do?

It creates and applies a plan to destroy resources managed by the Terraform workspace.

```bash
terraform destroy
```

### What is Terraform State?

Terraform state records information Terraform needs to track and manage infrastructure, including mappings between Terraform resource instances and real-world remote objects.

The default local state file is:

```text
terraform.tfstate
```

### Why is Terraform State important?

State allows Terraform to maintain the relationship between:

```text
Terraform Configuration
        ↓
Terraform State
        ↓
Real Infrastructure
```

This mapping is fundamental to Terraform's ability to determine what changes are required.

### Should Terraform State be committed to Git?

We should not casually commit Terraform state to Git.

State can contain sensitive information and requires appropriate protection.

For team and production environments, use an appropriate remote backend or HCP Terraform with suitable access control, security, and collaboration mechanisms.

### Final Mental Model

The most important concept from this section is:

```text
              Terraform Configuration
                       │
                       │
                       ↓
                 ┌──────────┐
                 │ Terraform│
                 └────┬─────┘
                      │
             ┌────────┴────────┐
             ↓                 ↓
          State            Provider
             │                 │
             │                 ↓
             │              AWS API
             │                 │
             │                 ↓
             └────────────→ AWS Infrastructure
```

And the practical workflow is:

```text
Write
  ↓
Format
  ↓
Validate
  ↓
Initialize
  ↓
Plan
  ↓
Review
  ↓
Apply
  ↓
Verify
  ↓
Destroy
```

> **The key takeaway:** Terraform is not simply a tool that creates infrastructure. It uses configuration, state, providers, and execution plans to continuously manage infrastructure in a predictable and declarative way.
