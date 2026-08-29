
## Terraform EC2 Module — Practical Project

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
├── terraform.tfvars
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

| File               | Purpose                                         |
| ------------------ | ----------------------------------------------- |
| `versions.tf`      | Defines Terraform and AWS provider requirements |
| `main.tf`          | Configures AWS and calls the EC2 module         |
| `variables.tf`     | Defines root module input variables             |
| `terraform.tfvars` | Provides values for the root variables          |
| `outputs.tf`       | Exposes values returned by the EC2 module       |
| `README.md`        | Documents the practical project                 |

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

## Verify AWS CLI

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

```json
{
  "UserId": "AIDXXXXXXXXXXXXXXX",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/example"
}
```

The actual identity will depend on the configured AWS authentication mechanism.

## AWS Authentication

This project does not store AWS credentials in Terraform configuration.

Recommended authentication approaches include:

* AWS CLI profiles
* IAM roles
* Environment-based credentials
* Web identity
* OIDC-based authentication for CI/CD
* Short-lived credentials

Avoid hard-coding access keys or secret keys in `.tf` files.

## Configuration

### 1. Configure `terraform.tfvars`

Update:

```hcl
aws_region    = "ap-south-1"
ami_id        = "<ami-id>"
instance_type = "t3.micro"
instance_name = "terraform-module-demo"
environment   = "dev"
```

Replace:

```text
<ami-id>
```

with an AMI ID that is valid for the selected AWS region.

> AMI IDs are region-specific. An AMI that exists in one AWS region may not exist in another.

## Module Inputs

The root module passes the following values to the EC2 child module:

```text
Root Module
     |
     | ami_id
     | instance_type
     | instance_name
     | environment
     |
     v
EC2 Module
```

The module call is defined in `main.tf`:

```hcl
module "ec2" {
  source = "./modules/ec2"

  ami_id        = var.ami_id
  instance_type = var.instance_type
  instance_name = var.instance_name
  environment   = var.environment
}
```

The child module receives these values through its `variables.tf`.

## Module Outputs

The EC2 module exposes:

```text
instance_id
public_ip
public_dns
```

The root module consumes these outputs:

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
  description = "EC2 public DNS."
  value       = module.ec2.public_dns
}
```

The general module output syntax is:

```text
module.<module-name>.<output-name>
```

For this project:

```text
module.ec2.instance_id
module.ec2.public_ip
module.ec2.public_dns
```

## Execution

All Terraform commands should be executed from the project root:

```text
project-ec2-module/
```

### Step 1 — Format the Configuration

Run:

```bash
terraform fmt -recursive
```

This formats Terraform configuration files, including files inside the module directory.

### Step 2 — Initialize Terraform

Run:

```bash
terraform init
```

Terraform initializes the working directory and installs the required AWS provider and local module dependencies.

A successful initialization should display a message similar to:

```text
Terraform has been successfully initialized!
```

### Step 3 — Validate the Configuration

Run:

```bash
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

This confirms that the Terraform configuration is syntactically valid and internally consistent.

### Step 4 — Inspect the Module

Run:

```bash
terraform modules
```

This displays information about the modules declared in the configuration.

The project should show the local EC2 module:

```text
module.ec2
```

### Step 5 — Review the Execution Plan

Run:

```bash
terraform plan
```

Review the proposed changes carefully.

The plan should show that Terraform intends to create an EC2 instance through the module.

The resource address will be similar to:

```text
module.ec2.aws_instance.this
```

No infrastructure should be created by `terraform plan`.

### Step 6 — Apply the Configuration

Run:

```bash
terraform apply
```

Review the execution plan.

When prompted, enter:

```text
yes
```

Terraform will create the EC2 instance.

## Validation

After the deployment completes, verify the Terraform outputs:

```bash
terraform output
```

Expected outputs include:

```text
instance_id = "i-xxxxxxxxxxxxxxxxx"
public_ip   = "x.x.x.x"
public_dns  = "ec2-x-x-x-x.region.compute.amazonaws.com"
```

The exact values will depend on the EC2 instance created.

### Validate Terraform State

Run:

```bash
terraform state list
```

The resource address should resemble:

```text
module.ec2.aws_instance.this
```

This confirms that the EC2 resource is managed through the child module.

### Validate from AWS CLI

The instance can also be inspected using AWS CLI.

For example:

```bash
aws ec2 describe-instances \
  --region ap-south-1
```

For a production or larger environment, the query should normally be narrowed using appropriate filters rather than returning every instance in the region.

## Module Data Flow

The complete data flow is:

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
+---------------------+
|     EC2 Module      |
|                     |
|    variables.tf     |
|         |           |
|         v           |
|      main.tf        |
|         |           |
|         v           |
|  aws_instance.this  |
|         |           |
|         v           |
|     outputs.tf      |
+---------------------+
          |
          | Outputs
          v
    Root outputs.tf
          |
          v
    terraform output
```

This demonstrates the fundamental module pattern:

```text
Input
  ↓
Module
  ↓
Infrastructure
  ↓
Output
```

## Expected Result

After a successful `terraform apply`:

```text
Terraform Configuration
        |
        v
Root Module
        |
        v
EC2 Child Module
        |
        v
AWS EC2 Instance
        |
        +---- Instance ID
        +---- Public IP
        +---- Public DNS
```

The EC2 instance is managed by Terraform through the reusable child module.

## Common Commands

The following commands are useful while working with this project.

### Format

```bash
terraform fmt -recursive
```

### Initialize

```bash
terraform init
```

### Validate

```bash
terraform validate
```

### Inspect Modules

```bash
terraform modules
```

### Plan

```bash
terraform plan
```

### Apply

```bash
terraform apply
```

### View Outputs

```bash
terraform output
```

### List Managed Resources

```bash
terraform state list
```

### Destroy Infrastructure

```bash
terraform destroy
```

## Troubleshooting

### Module Not Installed

If Terraform reports that a module has not been installed, run:

```bash
terraform init
```

### Configuration Changed

After changing the module source or other dependency-related configuration, reinitialize Terraform:

```bash
terraform init
```

### Provider Initialization Problems

Run:

```bash
terraform init
```

If we intentionally need to upgrade installed dependencies within the configured constraints:

```bash
terraform init -upgrade
```

Review the resulting plan before applying any changes.

### Invalid AMI

If AWS reports that the AMI is invalid, verify that the AMI exists in the selected region.

Check the configured region:

```bash
aws configure get region
```

The region used by Terraform is controlled by:

```hcl
provider "aws" {
  region = var.aws_region
}
```

### Authentication Failure

Run:

```bash
aws sts get-caller-identity
```

If this command fails, resolve the AWS authentication issue before running Terraform.

## Cleanup

**Always clean up the infrastructure after completing the lab if the resources are no longer required.**

From:

```text
project-ec2-module/
```

run:

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

We can also verify the instance in the AWS Management Console or AWS CLI.

### Important

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

## Learning Outcome

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

**[../01-modules.md](../01-modules.md)**

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
