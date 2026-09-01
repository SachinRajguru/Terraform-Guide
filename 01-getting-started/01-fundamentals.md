
## 01 — Terraform Fundamentals

> **Path:** `Terraform-Guide/01-getting-started/`

## Table of Contents

1. [Overview](#1-overview)
2. [What We Will Learn](#2-what-we-will-learn)
3. [The Problem: Manually Creating Infrastructure](#3-the-problem-manually-creating-infrastructure)
4. [Moving from Manual Work to Automation](#4-moving-from-manual-work-to-automation)
5. [What Is an API?](#5-what-is-an-api)
6. [CLI vs SDK vs IaC](#6-cli-vs-sdk-vs-iac)
7. [What Is Infrastructure as Code?](#7-what-is-infrastructure-as-code)
8. [Why Do We Need IaC?](#8-why-do-we-need-iac)
9. [Examples of Infrastructure as Code Tools](#9-examples-of-infrastructure-as-code-tools)
10. [The Challenge with Provider-Specific IaC](#10-the-challenge-with-provider-specific-iac)
11. [What Is Terraform?](#11-what-is-terraform)
12. [What Is a Terraform Provider?](#12-what-is-a-terraform-provider)
13. [Terraform and API-Based Infrastructure](#13-terraform-and-api-based-infrastructure)
14. [What Is HCL?](#14-what-is-hcl)
15. [Terraform Is Declarative](#15-terraform-is-declarative)
16. [Imperative vs Declarative](#16-imperative-vs-declarative)
17. [Why Cloud Knowledge Is Still Required](#17-why-cloud-knowledge-is-still-required)
18. [Terraform Documentation Is Part of the Skill](#18-terraform-documentation-is-part-of-the-skill)
19. [Terraform Basic Lifecycle](#19-terraform-basic-lifecycle)
20. [Terraform State — First Introduction](#20-terraform-state--first-introduction)
21. [Important State Warning](#21-important-state-warning)
22. [Desired State vs Terraform State vs Actual Infrastructure](#22-desired-state-vs-terraform-state-vs-actual-infrastructure)
23. [Terraform Alternatives](#23-terraform-alternatives)
24. [Terraform Licensing — Important Modern Update](#24-terraform-licensing--important-modern-update)
25. [Real-World Scenario](#25-real-world-scenario)
26. [Interview Questions and Answers](#26-interview-questions-and-answers)
27. [Key Takeaways](#27-key-takeaways)
28. [Terraform Best Practices](#28-terraform-best-practices)

## 1. Overview

Terraform is an **Infrastructure as Code (IaC)** tool used to define, provision, modify, and manage infrastructure through **declarative configuration files**.

Instead of manually creating cloud resources through a graphical console, we describe the **desired infrastructure as code** and allow Terraform to communicate with the target platform through APIs.

Terraform helps us manage infrastructure in a **repeatable, consistent, version-controlled, and automated** way.

## 2. What We Will Learn

By the end of this section, we should understand:

* Why manually creating infrastructure does not scale
* What Infrastructure as Code means
* Why infrastructure automation is required
* What APIs are and how they enable programmatic infrastructure management
* How CLI tools and SDKs can automate infrastructure operations
* Cloud-provider-specific IaC tools
* Why Terraform exists
* Terraform's provider-based architecture
* Terraform and HCL
* How Terraform interacts with provider APIs
* Terraform alternatives
* Why Terraform is widely used in DevOps and Cloud environments
* Why cloud knowledge is still required
* Terraform's basic workflow
* Terraform state at a high level
* The concept of Desired state
* Basic Terraform best practices

## 3. The Problem: Manually Creating Infrastructure

Suppose we receive a simple requirement:

> Create an Amazon S3 bucket.

A beginner-friendly manual process might be:

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
Review Configuration
    ↓
Create
```

For a single bucket, this may be perfectly acceptable.

Now imagine that the same request comes from **100 teams**.

If one manual request takes approximately **2 minutes**:

2 minutes × 100 teams = 200 minutes

That is approximately **3 hours and 20 minutes** of repetitive work.

> However, time is not the only problem.

Manual infrastructure creation can introduce:

* Human error
* Configuration inconsistency
* Repetitive work
* Poor auditability
* Difficult reproducibility
* Dependency on individual engineers
* Difficult change management
* Difficulty scaling operations

The fundamental problem is **not that the cloud console is bad**.

The problem is that **manual infrastructure operations do not scale efficiently**.

This leads us to an important question:

> **Can we perform these infrastructure operations programmatically instead of manually clicking through the console?**

This is where **automation** becomes important.

## 4. Moving from Manual Work to Automation

Instead of repeatedly using a graphical interface to create and manage infrastructure, we can communicate with cloud platforms **programmatically**.

Common approaches include:

```text
Programming / Automation
          │
          ├── CLI
          │
          ├── SDK
          │
          └── API
```

For AWS, these approaches can be represented as:

```text
AWS CLI
   ↓
AWS APIs
   ↓
AWS Infrastructure
```

and:

```text
Python Program
      ↓
  Boto3 SDK
      ↓
   AWS APIs
      ↓
AWS Infrastructure
```

### Example: Using the AWS SDK

A Python program can use **Boto3**, the AWS SDK for Python, to communicate with AWS and request the creation of an S3 bucket:

```python
import boto3

# Create an S3 client.
s3 = boto3.client("s3")

# Request creation of an S3 bucket.
s3.create_bucket(
    Bucket="example-bucket-name"
)
```

The Python program does not directly create the bucket itself. Instead, Boto3 communicates with the appropriate AWS service through AWS APIs.

### From Manual Operations to Programmatic Automation

With a graphical console, the workflow may look like:

```text
Manual Operation
      ↓
    Click
      ↓
    Click
      ↓
    Click
      ↓
Infrastructure
```

With programmatic automation, it becomes:

```text
Program / Script
      ↓
CLI / SDK
      ↓
Cloud API
      ↓
Infrastructure
```

The key idea is:

> We are no longer manually clicking through the cloud console. We are communicating with the cloud platform programmatically.

This is an important step toward **Infrastructure as Code (IaC)**. Instead of manually performing infrastructure operations, we can describe and automate those operations using code and configuration.

## 5. What Is an API?

An API, or Application Programming Interface, provides a programmatic way for one system to communicate with another.

A simplified view is:

```text
Our Program
    │
    │ API request
    ▼
AWS API
    │
    ▼
AWS Service
    │
    ▼
S3 / EC2 / VPC / IAM / etc.
```

For example:

```text
Python
   │
   │ boto3
   ▼
AWS API
   │
   ▼
Amazon S3
```

The API is what allows software to request actions from AWS.

## 6. CLI vs SDK vs IaC

There are several ways to automate infrastructure.

| Approach       | Example                | Typical Use                           |
| -------------- | ---------------------- | ------------------------------------- |
| Console        | AWS Management Console | Manual operations                     |
| CLI            | AWS CLI                | Command-line automation               |
| SDK            | Python + boto3         | Application/script automation         |
| IaC            | Terraform              | Declarative infrastructure management |
| CloudFormation | AWS CloudFormation     | AWS-native IaC                        |

A script can certainly create infrastructure.

However, as infrastructure becomes more complex, we need a structured approach to describing the desired infrastructure and managing its lifecycle.

Consider an environment containing:

```text
VPC
 ├── Public Subnets
 ├── Private Subnets
 ├── Route Tables
 ├── Internet Gateway
 ├── NAT Gateway
 ├── Security Groups
 ├── EC2
 ├── Load Balancer
 └── Database
```

Writing and maintaining all of this as custom application code can become unnecessarily complex.

This is where **Infrastructure as Code** becomes important.

## 7. What Is Infrastructure as Code?

**Infrastructure as Code (IaC)** is the practice of defining, provisioning, and managing infrastructure through **machine-readable configuration or code** rather than relying primarily on manual graphical operations.

### Traditional Approach

In a traditional approach, infrastructure may be created and configured manually through a cloud provider's graphical console:

```text
Engineer
    │
    ▼
Cloud Console
    │
    ▼
Manual Configuration
    │
    ▼
Infrastructure
```

For example, an engineer might manually perform operations such as:

```text
Create VPC
Create Subnet
Create Security Group
Create EC2
Create S3
Configure Networking
Configure Access
```

These operations may work for small environments, but repeating them manually becomes increasingly difficult as infrastructure grows.

### Infrastructure as Code Approach

With IaC, we define the desired infrastructure using machine-readable configuration or code:

```text
Engineer
    │
    ▼
Infrastructure Code
    │
    ▼
   IaC Tool
    │
    ▼
Cloud Provider / Platform API
    │
    ▼
Infrastructure
```

Instead of manually performing each operation, we describe **what infrastructure should exist**, and the IaC tool performs the necessary operations to create or manage that infrastructure.

### Traditional Approach vs IaC

| Area            | Traditional Approach     | IaC Approach                |
| --------------- | ------------------------ | --------------------------- |
| Provisioning    | Manual                   | Automated                   |
| Configuration   | Console / CLI            | Code / Configuration        |
| Repeatability   | Difficult                | High                        |
| Consistency     | Depends on engineer      | Standardized                |
| Version Control | Limited                  | Version-controlled          |
| Review          | Manual                   | Code review / Pull Request  |
| Auditability    | More difficult           | Easier                      |
| Reproduction    | Difficult                | Easier                      |
| Scaling         | Increasing manual effort | Automation                  |
| Collaboration   | Difficult to standardize | Version-controlled workflow |

The key difference is that, with IaC, infrastructure definitions can be treated similarly to other engineering artifacts.

The infrastructure definition can be:

* Version controlled
* Reviewed
* Reused
* Automated
* Tested
* Audited
* Reproduced

### IaC Does Not Eliminate Engineering Decisions

IaC does not eliminate the need for engineering knowledge or architectural decisions.

We still need to decide things such as:

```text
Which network architecture?
Which subnets?
Which security rules?
Which instance types?
Which access policies?
Which availability requirements?
Which scaling strategy?
```

IaC changes **how those decisions are represented and managed**.

Instead of keeping infrastructure decisions primarily in someone's memory or manually configured environments, we can make those decisions:

```text
Explicit
   ↓
Versioned
   ↓
Reviewable
   ↓
Repeatable
   ↓
Automatable
```

This makes infrastructure more **consistent, repeatable, auditable, and manageable**.

Infrastructure therefore becomes an **engineering artifact** that can be managed using many of the same practices we use for application code.

## 8. Why Do We Need IaC?

Infrastructure as Code becomes valuable when infrastructure grows beyond a small number of manually managed resources.

The main problems IaC helps address are **manual effort, inconsistency, lack of repeatability, limited traceability, configuration drift, and scaling challenges**.

### 8.1 Manual Provisioning

Manual provisioning is often:

* Time-consuming
* Repetitive
* Difficult to standardize
* Prone to human error
* Difficult to reproduce
* Difficult to audit
* Difficult to scale

For a small environment, manually creating a few resources may be manageable.

As the environment grows, however, the number of manual steps increases and maintaining consistency becomes more difficult.

### 8.2 Infrastructure Consistency

Suppose two engineers manually create EC2 instances.

Engineer A creates:

```text
Instance Type = t3.micro
Security Group = SG-A
Environment = Dev
```

Engineer B creates:

```text
Instance Type = t2.micro
Security Group = SG-B
Environment = Development
```

Both instances may technically work.

However, the infrastructure is not consistent.

The differences may be intentional, but they may also be the result of different assumptions or manual configuration.

With IaC:

```text
Infrastructure Definition
          ↓
     Version Control
          ↓
Reusable Configuration
          ↓
Consistent Infrastructure
```

We can define common standards while allowing environment-specific values where necessary.

### 8.3 Repeatability

If we need the same infrastructure tomorrow, we should not have to remember every click or command performed today.

IaC provides a repeatable infrastructure definition:

```text
Infrastructure Code
        ↓
    Reusable
        ↓
    Repeatable
        ↓
Consistent Infrastructure
```

The same definition can be used to create similar environments such as:

```text
Development
    ↓
Staging
    ↓
Production
```

with appropriate environment-specific values.

### 8.4 Version Control

IaC configuration can be stored in a version-control system such as Git.

This provides:

* Change history
* Change tracking
* Code review
* Pull requests
* Collaboration
* Auditability
* Ability to reference previous versions
* Ability to revert configuration changes when appropriate

A typical workflow can look like:

```text
Infrastructure Code
        ↓
       Git
        ↓
  Commit History
        ↓
   Pull Request
        ↓
   Code Review
        ↓
    Approved
        ↓
     Applied
```

Infrastructure changes therefore become visible and traceable instead of existing only as manual actions performed through a console.

### 8.5 Configuration Drift

Another important problem with manually managed infrastructure is **configuration drift**.

Configuration drift occurs when the actual infrastructure gradually differs from the intended configuration.

For example:

```text
Expected Configuration
        │
        ▼
   EC2 = t3.micro
        │
        │ Manual change
        ▼
Actual Configuration
   EC2 = t3.small
```

Someone may manually modify a resource after it was originally created.

Over time, the actual environment can become different from the documented or intended configuration.

IaC helps us maintain a defined representation of the desired infrastructure and provides mechanisms to detect and manage differences between the desired configuration and the actual environment.

### 8.6 Scalability

Modern environments may contain:

* Multiple environments
* Multiple regions
* Hundreds or thousands of resources
* Multiple teams
* Highly available architectures
* Complex networking
* Security controls
* Databases
* Kubernetes clusters

Manual provisioning becomes increasingly difficult as infrastructure grows.

IaC helps turn repeated infrastructure operations into an **automated and standardized engineering workflow**.

Instead of repeating the same manual steps for every environment, we can maintain reusable infrastructure definitions and apply them consistently.

## 9. Examples of Infrastructure as Code Tools

Different platforms and ecosystems provide different approaches to Infrastructure as Code.

| Platform / Scope    | Technology     | Primary Role                                    |
| ------------------- | -------------- | ----------------------------------------------- |
| AWS                 | CloudFormation | AWS-native IaC                                  |
| Azure               | ARM Templates  | Azure-native infrastructure templates           |
| Azure               | Bicep          | Modern Azure-native IaC language                |
| OpenStack           | Heat           | OpenStack orchestration                         |
| Multi-provider      | Terraform      | Provider-based IaC                              |
| Multi-provider      | Pulumi         | IaC using general-purpose programming languages |
| Kubernetes-oriented | Crossplane     | Kubernetes-based infrastructure control plane   |

These technologies are not identical.

They differ in their:

* Target platforms
* Configuration models
* Programming or configuration languages
* State-management approaches
* Provider or integration models
* Ecosystems
* Operational workflows

At a high level, they can be grouped as:

```text
Infrastructure as Code
        │
        ├── Cloud-specific
        │     ├── AWS CloudFormation
        │     ├── Azure ARM Templates
        │     └── Azure Bicep
        │
        ├── Multi-provider
        │     ├── Terraform
        │     └── Pulumi
        │
        └── Kubernetes-oriented
              └── Crossplane
```

The appropriate choice depends on the organization's platform, architecture, team skills, operational requirements, and desired level of portability.

In this handbook, we focus on **Terraform** and its approach to Infrastructure as Code.

## 10. The Challenge with Provider-Specific IaC

Many cloud platforms provide their own native Infrastructure as Code solutions.

For example:

```text id="b8q6tx"
Company A
   │
   └── AWS
        └── CloudFormation

Company B
   │
   └── Azure
        └── ARM / Bicep

Company C
   │
   └── OpenStack
        └── Heat

Company D
   │
   └── Google Cloud
        └── Google Cloud IaC tooling
```

These tools can work very well within their respective ecosystems.

However, an engineer or organization working across multiple platforms may need to understand different:

* Tools
* Languages or configuration formats
* Resource models
* Workflows
* Deployment models
* Operational practices

This can create additional **learning, maintenance, and operational overhead**.

For example, an organization operating across AWS and Azure may need to maintain knowledge of both CloudFormation and Azure's native IaC technologies.

This leads to an important question:

> Can we use a common Infrastructure as Code approach across multiple infrastructure platforms?

This is one of the problems that **Terraform is designed to address**.

Terraform uses a **provider-based architecture** that allows it to interact with different infrastructure platforms through their respective providers.

We will explore this architecture in the next section.

## 11. What Is Terraform?

Terraform is a **declarative Infrastructure as Code (IaC) tool** originally created by HashiCorp.

Terraform allows us to describe infrastructure using configuration files and use **providers** to communicate with external platforms and services.

A high-level view of Terraform is:

```text
Terraform Configuration
          │
          │ HCL
          ▼
       Terraform
          │
          │ Provider
          ▼
AWS / Azure / GCP / Kubernetes / etc.
          │
          ▼
     Provider API
          │
          ▼
     Infrastructure
```

The central question Terraform helps us answer is:

> What infrastructure should exist?

We describe the **desired infrastructure**, and Terraform determines the operations required to move the managed environment toward that configuration.

This is the fundamental idea behind Terraform's **declarative approach**.

We focus primarily on describing the desired end state rather than writing a step-by-step procedure for creating every resource.

## 12. What Is a Terraform Provider?

A **Terraform provider** is a plugin that enables Terraform to interact with a specific **platform, service, or API**.

Examples include providers for:

* AWS
* Azure
* Google Cloud
* Kubernetes
* GitHub
* Cloudflare
* Databases
* SaaS platforms

For AWS, the commonly used provider is:

```text
hashicorp/aws
```

The AWS provider exposes Terraform **resources** and **data sources** corresponding to AWS capabilities.

Conceptually:

```text
Terraform
    │
    ▼
AWS Provider
    │
    ▼
AWS APIs
    │
    ▼
AWS Services
```

The provider acts as the integration layer between Terraform and the external platform.

### 12.1 Provider vs Resource vs Data Source

These three concepts are important for understanding how Terraform interacts with external platforms.

### Provider

A **provider** supplies the integration between Terraform and an external platform or service.

For example:

```text
AWS Provider
```

The provider enables Terraform to communicate with AWS and exposes the capabilities that Terraform can use.

### Resource

A **resource** represents an individual infrastructure object that Terraform can **create, manage, update, or destroy**.

Examples of AWS resources include:

```text
aws_vpc
aws_subnet
aws_instance
aws_s3_bucket
aws_iam_role
```

Conceptually:

```text
AWS Provider
      │
      ├── aws_vpc
      ├── aws_subnet
      ├── aws_instance
      ├── aws_s3_bucket
      └── aws_iam_role
```

For example, if we define an `aws_s3_bucket` resource, Terraform can manage the lifecycle of that S3 bucket.

### Data Source

A **data source** allows Terraform to **read information about existing infrastructure or external data** without necessarily creating or managing that object.

For example, an AWS VPC may already exist, and we may want Terraform to retrieve information about it:

```text
Terraform
    │
    ▼
Data Source
    │
    ▼
AWS API
    │
    ▼
Existing VPC Information
```

A data source is therefore commonly used when we need to **look up existing information** and use that information elsewhere in our Terraform configuration.

For example:

```text
Existing VPC
     │
     ▼
Data Source
     │
     ▼
VPC ID
     │
     ▼
Used by another Terraform Resource
```

At a high level:

| Concept         | Purpose                                                          |
| --------------- | ---------------------------------------------------------------- |
| **Provider**    | Connects Terraform to an external platform or service            |
| **Resource**    | Represents and manages an infrastructure object                  |
| **Data Source** | Reads information about existing infrastructure or external data |

The relationship can be summarized as:

```text
Terraform Provider
       │
       ├── Resources
       │      └── Manage infrastructure objects
       │
       └── Data Sources
              └── Read existing information
```

For example:

```text
Terraform Configuration
        │
        ▼
    AWS Provider
        │
        ├── Resources
        │     ├── aws_vpc
        │     ├── aws_subnet
        │     ├── aws_instance
        │     └── aws_s3_bucket
        │
        └── Data Sources
              └── Read existing AWS information
        │
        ▼
      AWS APIs
        │
        ▼
   AWS Infrastructure
```

The key distinction is:

> **Resources are used to manage infrastructure, while data sources are used to read information.**

We will explore resources and data sources in greater detail in their respective sections.

### 12.2 Provider, Resource, and Data Source — Simple Analogy

A simple way to remember these concepts is:

```text
Provider
   ↓
"How do we communicate with AWS?"

Resource
   ↓
"What infrastructure do we manage?"

Data Source
   ↓
"What existing information do we need to read?"
```

For example:

```text
AWS Provider
     │
     ├── Resource
     │      └── Create/manage an S3 bucket
     │
     └── Data Source
            └── Read information about an existing VPC
```

This distinction becomes important as we start writing real Terraform configurations.

## 13. Terraform and API-Based Infrastructure

Terraform is sometimes informally described as following an **"API as code"** approach.

A more precise explanation is:

> Terraform configurations are declarative, and providers translate Terraform operations into API interactions with the target platform.

For example:

```text
main.tf
   │
   │ Terraform Configuration
   ▼
Terraform CLI
   │
   ▼
AWS Provider
   │
   ▼
AWS APIs
   │
   ▼
EC2 / VPC / S3 / IAM / etc.
```

When we write a Terraform resource such as:

```hcl
resource "aws_instance" "example" {
  # Terraform configuration
}
```

we are **not directly writing an AWS API request**.

Instead, we describe the desired infrastructure in Terraform configuration.

Terraform processes that configuration, and the AWS provider translates the required operations into interactions with the appropriate AWS APIs.

We normally do not need to manually construct or call AWS API requests for standard Terraform operations.

Terraform and its providers handle that interaction for us.

### Key Idea

The important distinction is:

```text
We describe:
"What infrastructure should exist?"
              │
              ▼
          Terraform
              │
              ▼
"What operations are required?"
              │
              ▼
           Provider
              │
              ▼
"How do we communicate with the platform?"
              │
              ▼
          Cloud API
```

This abstraction allows us to manage infrastructure using a **consistent declarative configuration model** rather than manually constructing platform-specific API requests.

## 14. What Is HCL?

**HCL** stands for **HashiCorp Configuration Language**.

Terraform configurations are generally written using the Terraform language, whose native syntax is based on HCL. Terraform's language is designed to be human-readable while remaining machine-processable.

For example:

```hcl
resource "aws_instance" "example" {
  # Amazon Machine Image used by the EC2 instance.
  ami = "ami-xxxxxxxx"

  # EC2 instance size.
  instance_type = "t3.micro"

  # Tags associated with the instance.
  tags = {
    Name = "terraform-demo"
  }
}
```

HCL is designed to provide a structured way to describe configuration.

Terraform's language is built around concepts such as:

* Blocks
* Arguments
* Expressions
* Resources
* Variables
* Outputs
* Data sources
* Modules
* Meta-arguments

These concepts will be covered in detail in later sections.

### 14.1 Important HCL Concepts

At a high level:

### Blocks

Blocks are containers that define a particular type of configuration.

For example:

```hcl
resource "aws_instance" "example" {
  # Block body
}
```

Here, `resource` is the block type and `aws_instance` and `example` are labels.

### Arguments

Arguments assign values to names within a block.

```hcl
instance_type = "t3.micro"
```

Here:

```text
instance_type
      │
      └── Argument name

"t3.micro"
      │
      └── Argument value
```

### Expressions

Expressions produce or calculate values and can reference other configuration objects.

For example:

```hcl
instance_type = var.instance_type
```

Here, the value is obtained from an input variable.

These are the fundamental building blocks of Terraform configuration.

### 14.2 Terraform File Extension

Terraform configuration files normally use the:

```text
.tf
```

file extension.

Common examples include:

```text
main.tf
provider.tf
variables.tf
outputs.tf
backend.tf
```

The names are conventions used to organize configuration for readability.

Terraform normally loads all `.tf` and `.tf.json` configuration files within a module and evaluates them together. The filename itself does not normally determine execution order.

For example:

```text
terraform-project/
│
├── main.tf
├── provider.tf
├── variables.tf
└── outputs.tf
```

Terraform treats these configuration files as part of the same module.

### 14.3 Terraform Also Supports JSON

Terraform also supports a JSON representation of its configuration language using:

```text
.tf.json
```

For example:

```text
main.tf.json
```

The native Terraform language is generally preferred for human-authored configuration, while the JSON representation can be useful when configuration is generated programmatically.

For this handbook, we will primarily use **HCL-based `.tf` files**.

## 15. Terraform Is Declarative

Terraform is primarily **declarative**.

This means we describe **what we want**, rather than explicitly writing every individual operation required to create it.

For example:

```hcl
resource "aws_instance" "example" {
  # Amazon Machine Image.
  ami = "ami-xxxxxxxx"

  # EC2 instance size.
  instance_type = "t3.micro"
}
```

We are expressing the desired configuration:

> We want an EC2 instance with these properties.

We are not manually writing a sequence such as:

```text
1. Call AWS API.
2. Create network interface.
3. Create instance.
4. Configure networking.
5. Attach security controls.
6. Wait for the operation.
7. Check the result.
```

Terraform determines the operations required to move the managed infrastructure toward the declared configuration.

The Terraform language documentation explicitly describes Terraform's language as declarative: it describes an intended goal rather than the steps required to reach that goal.

## 16. Imperative vs Declarative

Understanding the difference between **imperative** and **declarative** approaches is important for understanding Terraform.

### 16.1 Imperative

An imperative approach describes **how something should be done**.

For example:

```text
1. Create VPC
2. Create subnet
3. Create security group
4. Create EC2 instance
5. Attach security group
6. Configure networking
```

We explicitly describe the sequence of operations.

The focus is:

> How do we achieve the result?

### 16.2 Declarative

A declarative approach describes **what should exist**.

For example:

```text
VPC
Subnet
Security Group
EC2 Instance
```

The focus is:

> What should the final infrastructure look like?

Terraform then determines the operations required to reach that desired configuration.

Conceptually:

```text
Desired Configuration
        │
        ▼
     Terraform
        │
        ▼
Required Operations
        │
        ▼
Actual Infrastructure
```

### 16.3 Simple Analogy

Consider ordering food.

### Imperative

We might describe the process:

```text
1. Take bread
2. Add vegetables
3. Add sauce
4. Add filling
5. Toast
6. Serve
```

We are describing **how to prepare the food**.

### Declarative

Instead, we simply say:

> I want one sandwich.

We describe the desired result.

The system determines how to produce it.

Terraform follows the second model.

We describe the **desired infrastructure**, and Terraform determines the operations required to achieve that configuration.

The important idea is:

```text
Imperative
   ↓
How should it be done?

Declarative
   ↓
What should exist?
```

Terraform's declarative model is one of the fundamental concepts we need to understand before learning Terraform's workflow, planning, state, and resource management.

## 17. Why Cloud Knowledge Is Still Required

Terraform does not replace **cloud-platform knowledge**.

For example:

```hcl
resource "aws_instance" "example" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"
  subnet_id     = "subnet-xxxxxxxx"
}
```

Terraform can use this configuration to manage an EC2 instance.

However, Terraform does not automatically teach us:

* What an AMI is
* What a subnet is
* What a VPC is
* What a security group does
* How routing works
* How IAM permissions work
* How EC2 networking works
* How Availability Zones work
* How AWS Regions work

We still need to understand the underlying cloud platform to design infrastructure correctly.

For example, Terraform can accept:

```hcl
subnet_id = "subnet-xxxxxxxx"
```

But Terraform does not decide whether that subnet is:

* Public or private
* In the correct VPC
* In the correct Availability Zone
* Associated with the appropriate route table
* Appropriate for the workload

Those are **cloud architecture decisions**.

Therefore:

```text
Terraform Skill
       +
Cloud Platform Knowledge
       ↓
Effective Infrastructure Engineer
```

For AWS + Terraform, we should therefore understand the relevant **AWS fundamentals** alongside Terraform.

> Terraform provides the automation and infrastructure-management capability; cloud knowledge provides the understanding required to design and operate that infrastructure correctly.

## 18. Terraform Documentation Is Part of the Skill

We should not attempt to memorize every Terraform resource argument.

Professional Terraform engineers regularly consult:

* Terraform documentation
* Terraform Registry
* Provider documentation
* Provider examples
* Module documentation

A typical workflow is:

```text
Requirement
    ↓
Terraform Registry / Documentation
    ↓
Find Provider
    ↓
Find Resource / Data Source
    ↓
Review Arguments
    ↓
Review Examples
    ↓
Write Configuration
    ↓
terraform fmt
    ↓
terraform validate
    ↓
terraform plan
```

For example, if the requirement is:

> Create an EC2 instance in an existing subnet.

We can use the documentation to determine:

```text
Which provider?
      ↓
AWS Provider

Which resource?
      ↓
aws_instance

Which arguments?
      ↓
ami
instance_type
subnet_id
security_group_ids
tags
...
```

We then implement the configuration and use Terraform's commands to format, validate, and plan the configuration.

The important professional skill is therefore not memorizing every resource argument.

It is knowing **how to find, understand, evaluate, and correctly apply the information in the documentation**.

> The ability to read Terraform and provider documentation effectively is more valuable than memorizing every resource syntax.

## 19. Terraform Basic Lifecycle

A basic Terraform workflow is:

```text
Terraform Configuration
          │
          ▼
   terraform init
          │
          ▼
   terraform plan
          │
          ▼
     Review Plan
          │
          ▼
  terraform apply
          │
          ▼
    Infrastructure
          │
          ▼
  terraform destroy
```

These commands form the basic Terraform lifecycle and will be studied in detail in later sections.

At this stage, we should understand the purpose of each command.

### `terraform init`

Initializes the Terraform working directory and prepares it for use.

This includes tasks such as installing the required providers and initializing required modules and backend configuration as appropriate.

### `terraform plan`

Creates a **proposed execution plan** showing the changes Terraform intends to make to the infrastructure.

The plan allows us to review the proposed changes before applying them.

### `terraform apply`

Applies the configuration and makes the required changes to the infrastructure.

Terraform uses the configuration, state, and provider information to determine and perform the required operations.

### `terraform destroy`

Destroys infrastructure managed by the Terraform configuration.

This command should be used carefully because it can remove infrastructure and potentially cause data loss or service disruption.

> At a high level: `init` prepares Terraform, `plan` shows what Terraform intends to change, `apply` makes the changes, and `destroy` removes the managed infrastructure.

## 20. Terraform State — First Introduction

Terraform maintains **state information** about the infrastructure it manages.

By default, when using local state, Terraform stores this information in:

```text
terraform.tfstate
```

Terraform uses state to maintain a mapping between the **Terraform configuration** and the corresponding **real infrastructure objects**.

At a high level:

```text
Terraform Configuration
        │
        │ Desired State
        ▼
     Terraform
        │
        ├──────────────┐
        ▼              ▼
Terraform State     Cloud
        │              │
        └─── Mapping ──┘
```

This state information helps Terraform determine what changes are required when the configuration changes.

For example:

```text
Configuration
     ↓
Desired State
     ↓
Terraform State
     ↓
Actual Infrastructure
     ↓
Determine Required Changes
```

At this stage, we only need to understand that **Terraform state is an important part of how Terraform tracks and manages infrastructure**.

We will study Terraform state, state storage, remote state, locking, state operations, and backends in much greater depth in the dedicated **Terraform State and Backends** section.

## 21. Important State Warning

The `terraform.tfstate` file should **not** be treated like an ordinary source-code file.

Depending on the configuration and resources being managed, Terraform state can contain **sensitive information**.

Therefore, we should not commit local state files to a public source-control repository.

For example, we should not do:

```bash
git add terraform.tfstate
git commit -m "Add Terraform state"
```

Instead, local state files should generally be excluded from version control:

```gitignore
# Terraform state
*.tfstate
*.tfstate.*
```

For team environments, Terraform state is commonly stored using a **remote backend** with appropriate access control and concurrency/locking mechanisms.

The detailed design and management of remote state and backends will be covered later.

> For now, remember: Terraform configuration defines what we want, while Terraform state helps Terraform track the infrastructure it manages.

## 22. Desired State vs Terraform State vs Actual Infrastructure

These three concepts should be distinguished at a high level.

```text
Desired State
      │
      │ Defined by Terraform Configuration
      ▼
Terraform Configuration
      │
      ▼
   Terraform
      │
      ├───────────────┐
      ▼               ▼
Terraform State    Provider
                      │
                      ▼
              Actual Infrastructure
```

### Desired State

The **desired state** is what we declare in our Terraform configuration.

For example:

```hcl
resource "aws_instance" "example" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"
}
```

This expresses that we want an EC2 instance with the specified properties.

### Terraform State

**Terraform state** is the persisted information Terraform maintains about the infrastructure it manages.

It helps Terraform understand the relationship between the Terraform configuration and the real infrastructure objects.

At this stage, we only need to understand that state is an important part of how Terraform tracks and manages infrastructure.

### Actual Infrastructure

**Actual infrastructure** is what currently exists in the target platform, such as AWS, Azure, or another provider platform.

For example:

```text
Terraform Configuration
        │
        │ Desired State
        ▼
     Terraform
        │
        ├───────────────┐
        ▼               ▼
Terraform State      Provider
                        │
                        ▼
              Actual Infrastructure
```

The important idea is:

> Configuration describes what we want, state records Terraform's knowledge of managed infrastructure, and the cloud contains what actually exists.

These concepts are related, but they are **not interchangeable**.

We will explore the relationship between configuration, state, and actual infrastructure—including **drift, refresh, reconciliation, remote state, and backends**—in much greater detail in the dedicated **Terraform State and Backends** section.

## 23. Terraform Alternatives

Terraform is not the only Infrastructure as Code solution.

Different tools take different approaches to infrastructure management.

### 23.1 AWS CloudFormation

**Purpose:** AWS-native Infrastructure as Code.

```text
CloudFormation
      ↓
    AWS
```

**Strengths:**

* Deep AWS integration
* Native integration with AWS services

**Trade-off:**

* Primarily focused on AWS

### 23.2 Azure ARM Templates

**Purpose:** Azure-native resource-management templates.

```text
ARM Template
      ↓
Azure Resource Manager
      ↓
Azure
```

ARM remains part of the Azure resource-management foundation.

### 23.3 Azure Bicep

**Purpose:** Modern Azure-native declarative IaC authoring.

```text
Bicep
  ↓
ARM
  ↓
Azure
```

Bicep provides a cleaner authoring experience than raw ARM JSON and is commonly used for modern Azure-native IaC.

### 23.4 Pulumi

Pulumi allows infrastructure to be defined using general-purpose programming languages such as:

* TypeScript
* Python
* Go
* C#

Conceptually:

```text
Programming Language
        ↓
      Pulumi
        ↓
 Infrastructure
```

The major conceptual difference is that Pulumi emphasizes general-purpose programming languages, whereas Terraform primarily uses its declarative configuration language based on HCL.

### 23.5 Crossplane

Crossplane is a **Kubernetes-oriented infrastructure control-plane technology**.

Conceptually:

```text
Kubernetes
    ↓
Crossplane
    ↓
Cloud Infrastructure
```

It is particularly relevant to Kubernetes-centric platform engineering environments.

### 23.6 OpenStack Heat

Heat is OpenStack's orchestration technology.

```text
OpenStack
    ↓
   Heat
```

It is primarily relevant to OpenStack environments.

### 23.7 OpenTofu

OpenTofu is an **open-source, Terraform-compatible Infrastructure as Code project** that emerged following HashiCorp's licensing change.

Modern IaC discussions may therefore include:

```text
Terraform
OpenTofu
Pulumi
CloudFormation
Bicep
Crossplane
```

These tools are not identical.

They differ in areas such as:

* Configuration model
* Programming language
* Provider ecosystem
* Platform support
* State management
* Kubernetes integration
* Licensing
* Organizational requirements

The appropriate choice depends on factors such as:

* Organizational requirements
* Platform strategy
* Licensing requirements
* Provider support
* Ecosystem maturity
* Existing engineering skills
* Operational standards

## 24. Terraform Licensing — Important Modern Update

Older learning material often describes Terraform simply as an **open-source tool**.

That description requires historical clarification.

Terraform was historically distributed under the **Mozilla Public License 2.0 (MPL 2.0)**.

HashiCorp announced a licensing change in 2023, and Terraform releases beginning with **Terraform 1.6.0** use the **Business Source License 1.1 (BUSL 1.1)**.

Therefore, at a high level:

```text
Terraform ≤ 1.5.x
        ↓
Historically MPL 2.0

Terraform ≥ 1.6.x
        ↓
BUSL 1.1
```

The important distinction is:

> Current Terraform should not simply be described as "open source" without qualification. Current Terraform releases are source-available under BUSL 1.1.

This distinction can be important for organizations building commercial products, hosted services, or other products around Terraform.

For teams using Terraform to manage their own infrastructure, the organization's specific use case and the current license terms should still be evaluated where licensing matters.

### Important Terminology

We should distinguish between:

```text
Terraform
   ↓
HashiCorp's Terraform product

OpenTofu
   ↓
Open-source Terraform-compatible project
```

OpenTofu is therefore relevant when discussing Terraform alternatives, particularly for organizations evaluating open-source Terraform-compatible options.

> Licensing is a current-status topic and can change over time. When making licensing decisions, we should always verify the current official license terms rather than relying solely on older training material.

## 25. Real-World Scenario

Consider an organization with three environments:

```text
Development
Staging
Production
```

Each environment may require infrastructure such as:

```text
VPC
 ├── Public Subnets
 ├── Private Subnets
 ├── Route Tables
 ├── Internet Gateway
 ├── NAT Gateway
 ├── Security Groups
 ├── EC2
 ├── Load Balancer
 ├── S3
 ├── IAM
 └── Monitoring
```

### Without IaC

Without Infrastructure as Code, engineers may repeatedly create and configure infrastructure through the cloud console:

```text
Engineer
   ↓
Cloud Console
   ↓
Manual Configuration
   ↓
Development


Engineer
   ↓
Cloud Console
   ↓
Manual Configuration
   ↓
Staging


Engineer
   ↓
Cloud Console
   ↓
Manual Configuration
   ↓
Production
```

As the number of environments and resources increases, this approach can lead to:

* Repeated manual effort
* Configuration inconsistencies
* Human errors
* Difficulty reproducing environments
* Limited visibility into infrastructure changes

### With Terraform

With Terraform, we can define the infrastructure as code and establish a repeatable engineering workflow:

```text
Terraform Configuration
        ↓
       Git
        ↓
   Pull Request
        ↓
    Code Review
        ↓
 terraform plan
        ↓
  Review / Approval
        ↓
 terraform apply
        ↓
   Environment
```

The configuration can then be reused across Development, Staging, and Production with appropriate environment-specific values and requirements.

For example:

```text
                 Terraform Code
                       │
             ┌─────────┼─────────┐
             ▼         ▼         ▼
            Dev     Staging     Prod
             │         │         │
             ▼         ▼         ▼
        Environment Environment Environment
```

The goal is not necessarily to make every environment identical.

Instead, Terraform allows us to **define infrastructure consistently, version it, review changes, reuse proven patterns, and automate provisioning** while still allowing appropriate differences between environments.

> The real-world value of Terraform is not simply creating cloud resources. It is turning infrastructure management into a repeatable, reviewable, version-controlled engineering process.

## 26. Interview Questions and Answers

### Q1. What is Infrastructure as Code?

**Answer:**
Infrastructure as Code is the practice of defining and managing infrastructure through machine-readable configuration rather than manually creating infrastructure through graphical interfaces.

### Q2. Why do we use IaC?

**Answer:**
IaC improves repeatability, consistency, automation, version control, reviewability, and scalability of infrastructure management.

### Q3. What is Terraform?

**Answer:**
Terraform is a declarative Infrastructure as Code tool used to provision and manage infrastructure through providers.

### Q4. What is a Terraform provider?

**Answer:**
A provider is a Terraform plugin that allows Terraform to communicate with an external platform or service and exposes resources and data sources for that platform.

### Q5. What is HCL?

**Answer:**
HCL stands for HashiCorp Configuration Language. It is the native configuration syntax used by Terraform.

### Q6. Is Terraform a scripting language?

**Answer:**
No. Terraform configuration is declarative rather than an imperative scripting language. We describe the desired infrastructure and Terraform determines the operations required.

### Q7. Does Terraform replace AWS knowledge?

**Answer:**
No. Terraform automates AWS infrastructure, but engineers still need to understand AWS services and concepts.

### Q8. What are Terraform alternatives?

**Answer:**
Examples include Pulumi, Crossplane, CloudFormation, Azure Bicep/ARM, and OpenStack Heat.

### Q9. Why is Terraform popular?

**Answer:**
Its declarative model, provider ecosystem, reusable modules, state management, workflow, and broad industry adoption make it widely used for infrastructure automation.

### Q10. What is Terraform state?

**Answer:**
Terraform state records mappings between Terraform-managed resource instances and real infrastructure objects and is used to determine future changes.

### Q11. What is Terraform's current licensing model?

**Answer:**
Terraform was historically licensed under MPL 2.0. Beginning with Terraform 1.6.0, Terraform releases use the Business Source License 1.1 (BUSL-1.1). OpenTofu is a separate open-source Terraform-compatible project that emerged following HashiCorp's licensing change.

## 27. Key Takeaways

We learned:

* Manual infrastructure provisioning does not scale well.
* APIs enable programmatic interaction with cloud services.
* CLI tools and SDKs can automate infrastructure operations.
* Infrastructure as Code (IaC) defines and manages infrastructure through machine-readable configuration.
* Cloud providers offer provider-specific IaC tools.
* Terraform provides a multi-provider IaC model.
* Terraform uses a declarative configuration language based on HCL.
* Terraform providers enable interaction with external platforms and services.
* Terraform is declarative: we describe the desired infrastructure rather than manually defining every operation.
* Desired state describes the infrastructure we want Terraform to manage.
* Terraform state helps Terraform track and manage infrastructure.
* Actual infrastructure is what currently exists on the target platform.
* Configuration drift can occur when actual infrastructure differs from the declared configuration.
* Terraform does not eliminate the need for cloud-platform knowledge.
* Reading Terraform, provider, and module documentation is an essential professional skill.
* Terraform has alternatives such as OpenTofu, Pulumi, CloudFormation, Bicep, and Crossplane.
* Terraform's current licensing differs from its historical MPL 2.0 licensing.
* Terraform's basic lifecycle includes `terraform init`, `terraform plan`, `terraform apply`, and, when appropriate, `terraform destroy`.

## 28. Terraform Best Practices

The following are important Terraform practices that we should follow from the beginning.

Some of these topics will be covered in much greater detail in later sections. At this stage, we only need to understand the basic principle.

### Configuration and Version Control

* Store Terraform configuration in version control such as Git.
* Use pull requests and code review for infrastructure changes.
* Keep Terraform configuration organized and readable.
* Use reusable modules where they provide clear value.

### Security

* Never hard-code cloud credentials in Terraform configuration.
* Avoid using root-user credentials for normal Terraform operations.
* Follow the principle of least privilege.
* Prefer short-lived or dynamically obtained credentials where practical.
* Treat Terraform state as potentially sensitive information.

### Validation and Planning

Before applying infrastructure changes:

```bash
terraform fmt
terraform validate
terraform plan
```

* Use `terraform fmt` for consistent formatting.
* Use `terraform validate` to validate the configuration.
* Review `terraform plan` before applying changes.
* Do not blindly apply infrastructure changes without reviewing the plan.

### Documentation

* Read Terraform and provider documentation instead of guessing resource arguments.
* Verify resource arguments, requirements, and behavior before implementation.
* Keep module and infrastructure documentation up to date.

### State Management

* Do not commit `terraform.tfstate` or other Terraform state files to source control.
* Use appropriate remote state management for collaborative environments.
* Protect Terraform state with appropriate access controls.
* Understand state management before performing state-related operations.

Detailed state and backend practices will be covered in the **Terraform State and Backends** section.

### Version Management

* Pin or constrain important Terraform and provider versions in real projects.
* Review Terraform and provider changes before upgrading.
* Test infrastructure after version upgrades.

Detailed version and provider-management practices will be covered in later sections.

### Lab Cleanup

When working with temporary infrastructure:

```bash
terraform destroy
```

Destroy temporary lab infrastructure after practice when it is no longer required.

This helps prevent unnecessary cloud costs and keeps our lab environments clean.

> These are introductory best practices. We will revisit many of them throughout the guide and examine their implementation and reasoning in the relevant sections.
