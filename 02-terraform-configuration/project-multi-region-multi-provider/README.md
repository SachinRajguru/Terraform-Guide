
## Multi-Region Multi-Provider Terraform Project

> **File:** `README.md`

This project demonstrates how we can combine multiple Terraform configuration concepts into a practical Infrastructure as Code implementation.

The project uses:

* **AWS** as the primary cloud provider.
* **AWS provider aliases** to deploy resources across multiple AWS regions.
* **Azure** as a second cloud provider.
* Variables for configurable infrastructure.
* `.tfvars` for environment-specific values.
* Conditional expressions for optional resource deployment.
* Built-in Terraform functions for value transformation and selection.
* Locals for reusable expressions.
* Outputs for exposing resource information.
* Provider aliases for explicit provider-to-resource mapping.

The objective is not to build a production-ready multi-cloud platform. The objective is to understand **how Terraform configuration works when multiple providers, regions, variables, conditionals, and functions are used together.**

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Learning Objectives](#2-learning-objectives)
3. [Concepts Covered](#3-concepts-covered)
4. [Architecture](#4-architecture)
5. [Project Structure](#5-project-structure)
6. [Prerequisites](#6-prerequisites)
7. [Cloud Authentication](#7-cloud-authentication)
8. [Terraform Configuration Design](#8-terraform-configuration-design)
9. [Provider Configuration](#9-provider-configuration)
10. [Variables](#10-variables)
11. [Terraform Variable Values](#11-terraform-variable-values)
12. [Locals and Built-in Functions](#12-locals-and-built-in-functions)
13. [Conditional Resource Deployment](#13-conditional-resource-deployment)
14. [Resource Deployment](#14-resource-deployment)
15. [Outputs](#15-outputs)
16. [Terraform Initialization](#16-terraform-initialization)
17. [Terraform Formatting and Validation](#17-terraform-formatting-and-validation)
18. [Terraform Plan](#18-terraform-plan)
19. [Terraform Apply](#19-terraform-apply)
20. [Verify the Deployment](#20-verify-the-deployment)
21. [Understanding Provider Mapping](#21-understanding-provider-mapping)
22. [Changing Regions](#22-changing-regions)
23. [Changing Environments](#23-changing-environments)
24. [Testing Conditional Deployment](#24-testing-conditional-deployment)
25. [Troubleshooting](#25-troubleshooting)
26. [Best Practices](#26-best-practices)
27. [Cleanup and Destroy](#27-cleanup-and-destroy)
28. [What We Learned](#28-what-we-learned)
29. [Interview Questions](#29-interview-questions)
30. [Summary](#30-summary)

## 1. Project Overview

In the previous sections, we learned individual Terraform configuration concepts.

We covered:

```text
Providers
    ↓
Multiple Providers
    ↓
Multiple Regions
    ↓
Required Providers
    ↓
Variables
    ↓
.tfvars
    ↓
Conditional Expressions
    ↓
Built-in Functions
```

Now we combine these concepts into a single project.

The project follows this general flow:

```text
                    Terraform Configuration
                              │
                              ▼
                      Required Providers
                              │
                 ┌────────────┴────────────┐
                 │                         │
                 ▼                         ▼
              AWS Provider            Azure Provider
                 │
        ┌────────┴────────┐
        │                 │
        ▼                 ▼
     AWS Region 1      AWS Region 2
        │                 │
        ▼                 ▼
     EC2 Instance      EC2 Instance

                              │
                              ▼
                      Conditional Logic
                              │
                              ▼
                    Environment Selection
                              │
                              ▼
                      Terraform Outputs
```

The same Terraform configuration can therefore manage resources across multiple provider configurations.

## 2. Learning Objectives

By completing this project, we will understand how to:

* Configure multiple Terraform providers.
* Configure multiple AWS provider instances.
* Use provider aliases.
* Deploy resources to different AWS regions.
* Configure Azure alongside AWS.
* Define provider version requirements.
* Create reusable input variables.
* Validate variable values.
* Use `.tfvars` files.
* Use locals.
* Use built-in Terraform functions.
* Use conditional expressions.
* Explicitly map resources to providers.
* Generate useful outputs.
* Execute the complete Terraform workflow.
* Validate infrastructure before deployment.
* Change configuration without rewriting resource definitions.
* Safely destroy the resources after practice.

## 3. Concepts Covered

This project brings together the concepts from the previous documentation files.

| Topic                   | File                            | Demonstrated In This Project                            |
| ----------------------- | ------------------------------- | ------------------------------------------------------- |
| Providers               | `01-providers.md`               | AWS and Azure                                           |
| Multiple Providers      | `02-multiple-providers.md`      | Multiple provider configurations                        |
| Multiple Regions        | `03-multiple-regions.md`        | AWS regional provider aliases                           |
| Required Providers      | `04-required-providers.md`      | `versions.tf`                                           |
| Variables               | `05-variables.md`               | `variables.tf`                                          |
| `.tfvars`               | `06-tfvars.md`                  | `terraform.tfvars`                                      |
| Conditional Expressions | `07-conditional-expressions.md` | Optional Azure deployment                               |
| Built-in Functions      | `08-built-in-functions.md`      | `lower`, `trimspace`, `format`, `merge`, `lookup`, etc. |

## 4. Architecture

### 4.1 High-Level Architecture

```text
                           Terraform
                               │
                               │
                    ┌──────────┴──────────┐
                    │                     │
                    ▼                     ▼
                   AWS                  Azure
                    │                     │
          ┌─────────┴─────────┐           │
          │                   │           │
          ▼                   ▼           ▼
      us-east-1           us-west-2  Resource Group
          │                   │
          ▼                   ▼
    EC2 Instance        EC2 Instance
```

### 4.2 AWS Provider Configuration

We will create two AWS provider configurations:

```text
AWS Provider
│
├── default
│     └── us-east-1
│
└── west
      └── us-west-2
```

The second provider configuration uses an alias:

```hcl
alias = "west"
```

Resources can then explicitly select the required provider.

### 4.3 Azure Provider

Azure will use its own provider:

```text
Azure Provider
      │
      ▼
Azure Resource Group
```

This demonstrates that a single Terraform configuration can use more than one provider.

## 5. Project Structure

The final project structure is:

```text
project-multi-region-multi-provider/
│
├── README.md
│
├── versions.tf
├── providers.tf
├── variables.tf
├── terraform.tfvars.example
├── main.tf
└── outputs.tf
```

After Terraform initialization, additional local files/directories may appear:

```text
project-multi-region-multi-provider/
│
├── .terraform/
├── .terraform.lock.hcl
│
├── README.md
├── versions.tf
├── providers.tf
├── variables.tf
├── terraform.tfvars.example
├── main.tf
└── outputs.tf
```

#### Important

`.terraform/` is generated by Terraform and should normally **not** be committed to Git.

`.terraform.lock.hcl` should normally be committed because it records the selected provider dependency versions.

## 6. Prerequisites

Before executing the project, we should have:

### Required Tools

* Terraform
* AWS CLI
* Azure CLI
* Git

Verify Terraform:

```bash
terraform version
```

Verify AWS CLI:

```bash
aws --version
```

Verify Azure CLI:

```bash
az version
```

Verify Git:

```bash
git --version
```

### 6.1 Required Cloud Access

We need valid credentials for:

```text
AWS
Azure
```

The identities used by Terraform must have sufficient permissions to create and destroy the resources used in this project.

For a learning environment, we should use dedicated lab accounts or appropriately scoped identities rather than unnecessarily broad production credentials.

## 7. Cloud Authentication

Terraform providers need credentials to communicate with the cloud platforms.

### 7.1 AWS Authentication

We can authenticate using the AWS CLI:

```bash
aws configure
```

Then verify:

```bash
aws sts get-caller-identity
```

The command should return information about the authenticated AWS identity.

### 7.2 Azure Authentication

Authenticate with Azure:

```bash
az login
```

Verify:

```bash
az account show
```

If multiple Azure subscriptions are available, select the required subscription:

```bash
az account set --subscription "<SUBSCRIPTION_ID_OR_NAME>"
```

Verify again:

```bash
az account show
```

### 7.3 Security Note

We should **not** place cloud credentials directly inside:

```text
providers.tf
terraform.tfvars
main.tf
```

For example, avoid committing:

```hcl
access_key = "..."
secret_key = "..."
```

or other sensitive credentials.

Use supported authentication mechanisms such as:

* AWS CLI credentials.
* AWS environment variables.
* IAM roles.
* Azure CLI authentication.
* Managed identities.
* Workload identities.
* CI/CD identity mechanisms.

## 8. Terraform Configuration Design

The project separates Terraform configuration into logical files.

```text
versions.tf
    │
    └── Terraform and provider requirements

providers.tf
    │
    └── Provider configurations

variables.tf
    │
    └── Input definitions

terraform.tfvars
    │
    └── Input values

main.tf
    │
    └── Infrastructure resources

outputs.tf
    │
    └── Deployment information
```

This separation improves readability and maintainability.

Terraform automatically loads all `.tf` files in the same directory as a single configuration.

The filenames therefore provide **organizational structure**, not execution order.

## 9. Provider Configuration

We will configure:

* AWS default provider → `us-east-1`
* AWS aliased provider → `us-west-2`
* Azure provider → selected subscription

Example provider relationships:

```text
aws
│
├── default
│     └── us-east-1
│
└── west
      └── us-west-2

azurerm
└── Azure subscription
```

The actual provider configuration will be implemented in:

```text
providers.tf
```

The provider requirements will be implemented in:

```text
versions.tf
```

This follows the organizational approach established in the previous sections.

## 10. Variables

The project uses variables for values that may change between deployments.

Typical values include:

```text
AWS region
AWS secondary region
Azure location
Project name
Environment
AMI IDs
Instance types
Azure deployment flag
```

Instead of hardcoding these values throughout the configuration, we define them once in `variables.tf`.

### 10.1 Environment

The environment can be:

```text
dev
staging
prod
```

The variable validation ensures that invalid environments are rejected before deployment.

For example:

```text
development
production
testing
```

would not be accepted if they are outside the defined allowed values.

## 11. Terraform Variable Values

The project includes:

```text
terraform.tfvars.example
```

This file demonstrates the expected variable values.

We can create our local file:

```text
terraform.tfvars
```

from the example:

```bash
cp terraform.tfvars.example terraform.tfvars
```

On Windows PowerShell:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

We then update the values for our environment.

### 11.1 Why Use `.tfvars`?

Separating variable definitions from variable values allows the same Terraform configuration to be reused.

For example:

```text
Development
    │
    └── terraform.tfvars

Staging
    │
    └── staging.tfvars

Production
    │
    └── production.tfvars
```

The Terraform configuration does not need to be duplicated.

### 11.2 Do Not Commit Sensitive Values

If `terraform.tfvars` contains sensitive information, it should not be committed.

A typical `.gitignore` entry is:

```gitignore
terraform.tfvars
*.tfvars
```

while keeping:

```text
terraform.tfvars.example
```

in Git.

## 12. Locals and Built-in Functions

The project uses locals to centralize calculated values.

For example:

```text
Project Name
      │
      ▼
trimspace()
      │
      ▼
lower()
      │
      ▼
replace()
      │
      ▼
Normalized Project Name
```

Then:

```text
Normalized Project Name
          +
    Environment
          +
    Resource Type
          │
          ▼
       format()
          │
          ▼
    Resource Name
```

### 12.1 Example

A resource name can be generated using:

```hcl
format(
  "%s-%s-instance",
  local.normalized_project_name,
  local.environment
)
```

Instead of manually writing:

```text
terraform-dev-instance
terraform-prod-instance
```

for every environment.

### 12.2 Environment-Specific Instance Type

A map can be used:

```hcl
{
  dev     = "t3.micro"
  staging = "t3.small"
  prod    = "t3.large"
}
```

and `lookup()` can select the appropriate value.

Conceptually:

```text
    environment
        │
        ▼
     lookup()
        │
  ┌─────┼─────────────┐
  │     │             │
 dev  staging       prod
  │     │             │
  ▼     ▼             ▼
micro small         large
```

This demonstrates how functions can replace repetitive conditional expressions when a simple lookup table is more appropriate.

## 13. Conditional Resource Deployment

We will also demonstrate Terraform conditional expressions.

For example, Azure deployment can be controlled by:

```hcl
variable "deploy_azure" {
  type    = bool
  default = true
}
```

Then the resource can use:

```hcl
count = var.deploy_azure ? 1 : 0
```

Conceptually:

```text
deploy_azure
     │
     ├── true
     │     └── Create Azure resource
     │
     └── false
           └── Do not create Azure resource
```

This allows the same configuration to support different deployment scenarios.

## 14. Resource Deployment

The project contains resources across:

```text
AWS us-east-1
AWS us-west-2
Azure
```

The AWS resources explicitly select their providers.

For example:

```hcl
resource "aws_instance" "east" {
  provider = aws

  # configuration
}
```

and:

```hcl
resource "aws_instance" "west" {
  provider = aws.west

  # configuration
}
```

The important distinction is:

```text
aws
    │
    └── default AWS provider configuration

aws.west
    │
    └── aliased AWS provider configuration
```

The resource therefore knows exactly which provider configuration it should use.

### 14.1 Provider-to-Resource Mapping

The architecture becomes:

```text
                         Terraform
                             │
                ┌────────────┼────────────┐
                │            │            │
                ▼            ▼            ▼
               aws        aws.west     azurerm
                │            │            │
                ▼            ▼            ▼
           us-east-1      us-west-2     Azure
                │            │            │
                ▼            ▼            ▼
               EC2          EC2     Resource Group
```

This explicit mapping is one of the most important concepts demonstrated by the project.

## 15. Outputs

The project exposes useful information using `outputs.tf`.

Examples include:

```text
AWS East Instance ID
AWS West Instance ID
AWS East Public IP
AWS West Public IP
Azure Resource Group Name
Generated Resource Names
```

After deployment:

```bash
terraform output
```

can be used to display the results.

A specific output can also be queried:

```bash
terraform output aws_east_instance_id
```

## 16. Terraform Initialization

Once the project files are ready, move into the project directory:

```bash
cd project-multi-region-multi-provider
```

Initialize Terraform:

```bash
terraform init
```

Terraform will:

1. Read the configuration.
2. Identify required providers.
3. Download the required providers.
4. Initialize the working directory.
5. Create or update `.terraform.lock.hcl`.

Expected output will indicate successful initialization.

## 17. Terraform Formatting and Validation

### 17.1 Format

Run:

```bash
terraform fmt
```

To check which files would be changed without modifying them:

```bash
terraform fmt -check
```

### 17.2 Validate

Run:

```bash
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

Validation checks the Terraform configuration structure and expression correctness.

It does not replace `terraform plan`.

## 18. Terraform Plan

Before creating infrastructure, generate a plan:

```bash
terraform plan
```

Terraform evaluates:

```text
Variables
    │
    ▼
Locals
    │
    ▼
Functions
    │
    ▼
Conditionals
    │
    ▼
Provider Mapping
    │
    ▼
Resources
    │
    ▼
Execution Plan
```

Review the plan carefully.

We should verify that:

* The expected AWS regions are used.
* The expected AWS resources are planned.
* The Azure resource is included or excluded as expected.
* Instance types are correct.
* Resource names are correct.
* Tags are correct.
* No unexpected resource changes are shown.

## 19. Terraform Apply

Once the plan has been reviewed:

```bash
terraform apply
```

Terraform displays the proposed changes again.

Confirm the operation when prompted.

Terraform then creates the resources.

The deployment may look conceptually like:

```text
Terraform
    │
    ├── AWS us-east-1
    │      └── EC2
    │
    ├── AWS us-west-2
    │      └── EC2
    │
    └── Azure
            └── Resource Group
```

## 20. Verify the Deployment

After a successful deployment, verify the Terraform outputs:

```bash
terraform output
```

### 20.1 Verify AWS

Verify the current AWS identity:

```bash
aws sts get-caller-identity
```

Then verify the resources in the appropriate AWS regions using the AWS CLI or AWS Console.

For example:

```bash
aws ec2 describe-instances --region us-east-1
```

and:

```bash
aws ec2 describe-instances --region us-west-2
```

### 20.2 Verify Azure

List resource groups:

```bash
az group list --output table
```

We should see the resource group created by Terraform.

## 21. Understanding Provider Mapping

Provider aliases are especially important when multiple configurations of the same provider are required.

Consider:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

This is the default AWS provider.

Then:

```hcl
provider "aws" {
  alias  = "west"
  region = "us-west-2"
}
```

This creates another AWS provider configuration.

The resources then select the desired configuration.

### Default Provider

```hcl
resource "aws_instance" "east" {
  provider = aws
}
```

### Aliased Provider

```hcl
resource "aws_instance" "west" {
  provider = aws.west
}
```

This is the fundamental mechanism Terraform uses for multi-region AWS configurations.

## 22. Changing Regions

One benefit of provider configuration is that region information can be separated from the resource definition.

Instead of changing:

```hcl
resource "aws_instance" "example" {
  # resource configuration
}
```

we can change the provider configuration:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

to another supported region.

However, we should understand that changing a resource's region generally means Terraform will manage a different remote object because cloud resources are regional.

Before making such a change in a real environment, we should review the plan carefully.

## 23. Changing Environments

We can change the environment through:

```text
terraform.tfvars
```

For example:

```hcl
environment = "dev"
```

can become:

```hcl
environment = "prod"
```

The same Terraform configuration can then calculate:

```text
Different resource names
Different instance types
Different tags
Different conditional behavior
```

depending on the configuration.

This demonstrates one of the major benefits of Infrastructure as Code:

> The configuration describes infrastructure logic while variable values control deployment-specific behavior.

## 24. Testing Conditional Deployment

Suppose:

```hcl
deploy_azure = true
```

Terraform plans the Azure resource.

If we change:

```hcl
deploy_azure = false
```

the Azure resource is no longer included in the desired configuration.

Run:

```bash
terraform plan
```

and inspect the proposed changes.

This demonstrates how conditional expressions affect the Terraform resource graph.

## 25. Troubleshooting

### 25.1 Provider Authentication Error

#### Symptom

Terraform cannot authenticate with AWS or Azure.

#### Check AWS

```bash
aws sts get-caller-identity
```

#### Check Azure

```bash
az account show
```

If authentication is invalid, authenticate again using the appropriate mechanism.

### 25.2 AWS Region Does Not Support the Selected AMI

An AMI is generally region-specific.

An AMI ID that works in:

```text
us-east-1
```

may not be valid in:

```text
us-west-2
```

We should therefore provide an appropriate AMI ID for each region.

Do not assume that the same AMI ID is valid across AWS regions.

### 25.3 Azure Subscription Not Selected

Check:

```bash
az account show
```

If required:

```bash
az account set --subscription "<SUBSCRIPTION_ID_OR_NAME>"
```

### 25.4 Invalid Environment

If we configure:

```hcl
environment = "testing"
```

while the validation allows only:

```text
dev
staging
prod
```

Terraform will report a variable validation error.

Use one of the permitted values.

### 25.5 Incorrect Provider Alias

Incorrect:

```hcl
provider = aws.west1
```

when the provider is actually:

```hcl
alias = "west"
```

Correct:

```hcl
provider = aws.west
```

The alias must match exactly.

### 25.6 Terraform State Already Contains Resources

If we change configuration after applying it, Terraform compares:

```text
Configuration
      +
State
      +
Remote Infrastructure
```

and determines what needs to change.

Always review:

```bash
terraform plan
```

before applying changes.

### 25.7 Unexpected Resource Destruction

Never blindly execute:

```bash
terraform apply
```

when a plan shows unexpected deletions or replacements.

First determine:

* What changed?
* Did the provider change?
* Did the region change?
* Did a resource argument change?
* Did a variable change?
* Did a provider alias change?
* Did the state change?

Then decide whether the proposed change is intentional.

## 26. Best Practices

### 26.1 Separate Provider Requirements From Configuration

Use:

```text
versions.tf
```

for:

```hcl
terraform {
  required_providers {
    ...
  }
}
```

and:

```text
providers.tf
```

for:

```hcl
provider "aws" {
  ...
}
```

This keeps the configuration organized.

### 26.2 Use Provider Aliases for Multiple Regions

For multi-region AWS deployments, explicitly define provider aliases.

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

Then explicitly map resources:

```hcl
provider = aws.west
```

### 26.3 Keep Environment Values in Variables

Avoid hardcoding:

```hcl
environment = "prod"
```

throughout the configuration.

Instead:

```hcl
var.environment
```

should drive environment-specific behavior.

### 26.4 Use Locals for Repeated Expressions

If an expression is used multiple times, consider a local.

For example:

```hcl
locals {
  environment = lower(trimspace(var.environment))
}
```

Then use:

```hcl
local.environment
```

throughout the configuration.

### 26.5 Use Functions to Reduce Duplication

Instead of manually creating:

```text
terraform-dev-instance
terraform-staging-instance
terraform-prod-instance
```

generate names dynamically.

This improves reuse.

### 26.6 Validate Inputs Early

Use variable validation to catch invalid values before infrastructure deployment.

For example:

```hcl
validation {
  condition = contains(
    ["dev", "staging", "prod"],
    var.environment
  )

  error_message = "Environment must be dev, staging, or prod."
}
```

### 26.7 Review the Plan

The recommended workflow is:

```bash
terraform fmt
terraform validate
terraform plan
terraform apply
```

We should understand the plan before applying it.

### 26.8 Do Not Commit Secrets

Do not commit:

```text
terraform.tfvars
```

if it contains secrets.

Prefer:

```text
terraform.tfvars.example
```

with safe example values.

### 26.9 Commit the Lock File

Normally commit:

```text
.terraform.lock.hcl
```

because it records selected provider versions and helps maintain consistent provider dependencies across environments.

### 26.10 Destroy Lab Infrastructure

Cloud resources can continue generating costs after the lab is complete.

After practice:

```bash
terraform destroy
```

Verify that the resources have been removed.

## 27. Cleanup and Destroy

Once we have completed the project, destroy the infrastructure:

```bash
terraform destroy
```

Terraform displays the resources that will be removed.

Review the plan carefully and confirm.

### 27.1 Verify AWS Cleanup

Check both regions:

```bash
aws ec2 describe-instances --region us-east-1
```

and:

```bash
aws ec2 describe-instances --region us-west-2
```

Verify that the Terraform-created instances have been removed.

### 27.2 Verify Azure Cleanup

Check resource groups:

```bash
az group list --output table
```

Verify that the Terraform-created resource group is no longer present.

### 27.3 Why Cleanup Matters

Terraform labs can create billable cloud resources.

The complete learning workflow should therefore be:

```text
Create
  │
  ▼
Validate
  │
  ▼
Test
  │
  ▼
Understand
  │
  ▼
Destroy
```

Cleanup is part of responsible cloud engineering.

## 28. What We Learned

This project connected the individual Terraform configuration concepts into one practical implementation.

We learned how:

```text
Terraform
    │
    ├── Providers
    │      ├── AWS
    │      └── Azure
    │
    ├── Provider Aliases
    │      ├── AWS Default
    │      └── AWS West
    │
    ├── Multiple Regions
    │      ├── us-east-1
    │      └── us-west-2
    │
    ├── Variables
    │
    ├── .tfvars
    │
    ├── Locals
    │
    ├── Functions
    │
    ├── Conditionals
    │
    ├── Resources
    │
    └── Outputs
```

work together.

The most important architectural concept is provider mapping:

```text
Resource
   │
   ▼
Provider Configuration
   │
   ▼
Cloud / Region
```

For example:

```text
aws_instance.east
       │
       ▼
      aws
       │
       ▼
   us-east-1
```

while:

```text
aws_instance.west
       │
       ▼
    aws.west
       │
       ▼
   us-west-2
```

## 29. Interview Questions

### Q1. Why do we use provider aliases in Terraform?

**Answer:**

Provider aliases allow us to create multiple configurations of the same provider.

For example, we can configure AWS for:

```text
us-east-1
us-west-2
```

and assign an alias to the second configuration.

Resources can then explicitly select the required provider.

### Q2. How do we deploy AWS resources into multiple regions using Terraform?

**Answer:**

We create multiple AWS provider configurations using aliases.

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

Then resources explicitly select the required provider:

```hcl
provider = aws.west
```

### Q3. Can Terraform manage AWS and Azure resources in the same configuration?

**Answer:**

Yes.

Terraform supports multiple providers in the same configuration.

For example:

```text
AWS Provider
Azure Provider
```

can both be declared and used by resources in the same Terraform project.

### Q4. What is the difference between a provider and a provider alias?

**Answer:**

A provider is a configuration for communicating with a particular infrastructure platform.

An alias creates an additional named configuration of that provider.

For example:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

is the default configuration.

While:

```hcl
provider "aws" {
  alias  = "west"
  region = "us-west-2"
}
```

is an aliased configuration.

### Q5. Why should we not hardcode environment-specific values?

**Answer:**

Hardcoding reduces reusability.

Using variables allows the same Terraform configuration to be reused for:

```text
dev
staging
prod
```

without duplicating the infrastructure code.

### Q6. What is the purpose of `terraform.tfvars`?

**Answer:**

`terraform.tfvars` provides values for Terraform input variables.

It separates configuration values from the variable definitions and infrastructure resources.

### Q7. Why do we use locals?

**Answer:**

Locals allow us to define reusable calculated values and simplify complex expressions.

For example:

```hcl
locals {
  environment = lower(trimspace(var.environment))
}
```

The calculated value can then be reused throughout the configuration.

### Q8. How can we conditionally create a Terraform resource?

**Answer:**

We can use conditional expressions together with `count` or `for_each`.

For example:

```hcl
count = var.deploy_azure ? 1 : 0
```

If `deploy_azure` is `true`, Terraform creates one instance of the resource.

If it is `false`, Terraform creates zero instances.

### Q9. Why might the same AMI ID not work in multiple AWS regions?

**Answer:**

AWS AMIs are generally region-specific.

An AMI ID available in one region may not exist in another region.

For multi-region deployments, we should use an AMI that is available in each target region.

### Q10. Why should we run `terraform plan` before `terraform apply`?

**Answer:**

`terraform plan` allows us to review the changes Terraform intends to make before modifying infrastructure.

This helps us identify:

* Unexpected changes.
* Resource replacements.
* Resource deletions.
* Incorrect regions.
* Incorrect provider mappings.
* Incorrect variable values.

## 30. Summary

This project demonstrates how individual Terraform configuration concepts come together in a practical Infrastructure as Code workflow.

The complete flow is:

```text
                    Terraform Project
                           │
                           ▼
                    Required Providers
                           │
             ┌─────────────┴─────────────┐
             │                           │
             ▼                           ▼
            AWS                        Azure
             │
       ┌─────┴─────┐
       │           │
       ▼           ▼
   us-east-1   us-west-2
       │           │
       ▼           ▼
      EC2         EC2
```

Alongside the infrastructure configuration:

```text
Variables
    │
    ▼
.tfvars
    │
    ▼
Locals
    │
    ▼
Functions
    │
    ▼
Conditionals
    │
    ▼
Resources
    │
    ▼
Outputs
```

The standard execution workflow is:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

After completing the practice:

```bash
terraform destroy
```

The key takeaway is:

> Terraform configuration becomes powerful when providers, provider aliases, variables, `.tfvars`, conditionals, functions, locals, resources, and outputs are combined into reusable Infrastructure as Code.

This project therefore serves as the practical implementation of the concepts covered throughout:

```text
02-terraform-configuration/
│
├── 01-providers.md
├── 02-multiple-providers.md
├── 03-multiple-regions.md
├── 04-required-providers.md
├── 05-variables.md
├── 06-tfvars.md
├── 07-conditional-expressions.md
├── 08-built-in-functions.md
│
└── project-multi-region-multi-provider/
    ├── README.md
    ├── versions.tf
    ├── providers.tf
    ├── variables.tf
    ├── terraform.tfvars.example
    ├── main.tf
    └── outputs.tf
```

The next step is to create the actual Terraform implementation files and execute the project from this README.
