
## Project — AWS EC2 Instance Provisioning Using Terraform

## 1. Project Objective

The objective of this project is to provision an Amazon EC2 instance using Terraform.

This project demonstrates:

- AWS provider configuration
- Terraform resource blocks
- EC2 provisioning
- AMI selection
- Instance type
- Subnet configuration
- Key pair configuration
- Terraform initialization
- Terraform plan
- Terraform apply
- Terraform state
- Terraform destroy

## 2. Prerequisites

Before starting the project, verify:

- AWS account is available
- AWS CLI is installed
- Terraform is installed
- Git is installed
- VS Code is installed
- AWS authentication is configured
- Required AWS permissions are available

Verify Terraform:

```bash
terraform version
````

Verify AWS:

```bash
aws sts get-caller-identity
```

## 3. Navigate to the Project

Open the project directory:

```bash
cd 01-getting-started/project-ec2-instance
```

Verify the files:

```bash
ls
```

Expected:

```text
main.tf
steps.md
```

## 4. Configure AWS Authentication

For local learning, AWS CLI credentials can be configured using:

```bash
aws configure
```

Verify:

```bash
aws sts get-caller-identity
```

Do not place AWS credentials inside `main.tf`.

## 5. Select the AWS Region

The example uses:

```text
us-east-1
```

which is the AWS US East (N. Virginia) region.

The region can be changed in `main.tf`:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

## 6. Find an AMI

Open the AWS EC2 console.

Navigate to:

```text
EC2
→ AMIs
```

or use the Launch Instance workflow to identify an appropriate AMI.

Make sure the AMI belongs to the same region configured in Terraform.

Replace:

```hcl
ami = "REPLACE_WITH_VALID_AMI_ID"
```

with the selected AMI ID.

Example format:

```hcl
ami = "ami-xxxxxxxxxxxxxxxxx"
```

Do not blindly copy an AMI ID from another AWS region.

## 7. Find a Subnet

Open:

```text
AWS Console
→ VPC
→ Subnets
```

Identify a subnet in the configured region/VPC.

Replace:

```hcl
subnet_id = "REPLACE_WITH_VALID_SUBNET_ID"
```

with the actual subnet ID.

Example:

```hcl
subnet_id = "subnet-xxxxxxxxxxxxxxxxx"
```

## 8. Configure an EC2 Key Pair

Open:

```text
AWS Console
→ EC2
→ Key Pairs
```

Create a key pair if one does not already exist.

Copy the key-pair name.

Replace:

```hcl
key_name = "REPLACE_WITH_EXISTING_KEY_PAIR_NAME"
```

with the key-pair name.

Example:

```hcl
key_name = "aws-login"
```

The key pair allows SSH-based access to supported Linux EC2 instances.

## 9. Review the Terraform Configuration

The important configuration is:

```hcl
resource "aws_instance" "terraform_demo" {
  ami           = "ami-xxxxxxxxxxxxxxxxx"
  instance_type = "t3.micro"
  subnet_id     = "subnet-xxxxxxxxxxxxxxxxx"
  key_name      = "aws-login"
}
```

The resource type is:

```text
aws_instance
```

The local Terraform resource name is:

```text
terraform_demo
```

## 10. Format the Terraform Code

Run:

```bash
terraform fmt
```

This automatically formats Terraform configuration files.

## 11. Initialize Terraform

Run:

```bash
terraform init
```

Terraform will:

1. Read the configuration.
2. Identify the AWS provider.
3. Download the required provider.
4. Create Terraform working information.
5. Prepare the directory for execution.

## 12. Validate the Configuration

Run:

```bash
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

Validation checks the configuration syntax and internal structure.

## 13. Generate a Terraform Plan

Run:

```bash
terraform plan
```

Terraform will show the proposed infrastructure changes.

For this project we expect approximately:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

Do not blindly approve a plan.

Review:

* AMI
* instance type
* subnet
* key pair
* tags
* region
* security-related configuration

## 14. Apply the Terraform Configuration

Run:

```bash
terraform apply
```

Terraform displays the proposed changes.

Confirm with:

```text
yes
```

Terraform then communicates with AWS and creates the EC2 instance.

## 15. Verify Terraform Output

A successful operation should end with something similar to:

```text
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

## 16. Verify EC2 in AWS

Open:

```text
AWS Console
→ EC2
→ Instances
```

Verify that an instance named:

```text
terraform-ec2-instance
```

exists.

The tag is configured using:

```hcl
tags = {
  Name = "terraform-ec2-instance"
}
```

## 17. Inspect Terraform State

After successful `terraform apply`, Terraform creates:

```text
terraform.tfstate
```

Do not commit this file to a public Git repository.

The state contains information Terraform uses to track managed infrastructure.

## 18. Check Terraform State

Run:

```bash
terraform state list
```

Expected:

```text
aws_instance.terraform_demo
```

This confirms that Terraform is tracking the EC2 resource.

## 19. Show the Current State

Run:

```bash
terraform show
```

This displays the current Terraform state in a human-readable format.

## 20. Modify the Configuration

For example, change:

```hcl
instance_type = "t3.micro"
```

to:

```hcl
instance_type = "t3.small"
```

Run:

```bash
terraform plan
```

Terraform should detect the configuration change and determine the required action.

This demonstrates how Terraform compares desired configuration with the infrastructure it manages.

## 21. Destroy the Infrastructure

After completing the lab:

```bash
terraform destroy
```

Review the proposed destruction.

Confirm:

```text
yes
```

Terraform will delete the managed EC2 instance.

## 22. Verify Destruction

Run:

```bash
terraform state list
```

The EC2 resource should no longer be present after successful destruction.

Also verify in:

```text
AWS Console
→ EC2
→ Instances
```

The Terraform-managed instance should be terminated.

## 23. Complete Terraform Lifecycle

The project lifecycle is:

```text
Write Code
    ↓
terraform fmt
    ↓
terraform init
    ↓
terraform validate
    ↓
terraform plan
    ↓
terraform apply
    ↓
AWS EC2
    ↓
terraform show
    ↓
terraform destroy
```

## 24. Troubleshooting

### Error: Invalid AMI

Cause:

The AMI does not exist in the selected region.

Solution:

Select an AMI from the configured AWS region.

### Error: Subnet Not Found

Cause:

The subnet ID is incorrect or belongs to another region/account.

Solution:

Verify the subnet in:

```text
AWS Console → VPC → Subnets
```

### Error: Key Pair Does Not Exist

Cause:

The key-pair name is incorrect or unavailable in the selected region.

Solution:

Verify the key pair under:

```text
EC2 → Key Pairs
```

### Error: AccessDenied

Cause:

The AWS identity does not have sufficient permissions.

Verify:

```bash
aws sts get-caller-identity
```

Then review the IAM permissions.

### Error: No Credentials Found

Verify:

```bash
aws sts get-caller-identity
```

If authentication fails, configure the AWS CLI or use an approved AWS credential mechanism.

## 25. Important Security Rules

Never commit:

```text
terraform.tfstate
terraform.tfstate.*
*.tfvars
```

when they contain sensitive information.

Never commit:

```text
AWS Access Key
AWS Secret Access Key
Private SSH Keys
Passwords
Tokens
```

Never hard-code AWS credentials into:

```text
main.tf
variables.tf
provider.tf
```

## 26. Project Completion Criteria

The project is considered complete when:

* Terraform is installed.
* AWS CLI is configured.
* AWS authentication works.
* Terraform provider initializes successfully.
* Configuration validates successfully.
* Terraform plan is reviewed.
* EC2 instance is successfully created.
* EC2 instance is verified in AWS.
* Terraform state is understood.
* EC2 instance is successfully destroyed.

## 27. Key Learning

This project demonstrates the fundamental Terraform workflow:

```text
Configuration
      ↓
Initialization
      ↓
Validation
      ↓
Planning
      ↓
Application
      ↓
State Tracking
      ↓
Infrastructure
      ↓
Destruction
```

## Project Code — Explanation

### 1. Terraform Block

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
````

This explicitly declares the AWS provider dependency.

The provider source is:

```text
hashicorp/aws
```

Terraform uses this information during:

```bash
terraform init
```

to obtain the required provider.

### 2. Provider Block

```hcl
provider "aws" {
  region = "us-east-1"
}
```

This tells Terraform:

```text
Provider → AWS
Region   → us-east-1 (US East – N. Virginia)
```

The provider does **not** contain the AWS secret key.

Terraform obtains AWS credentials through supported AWS credential mechanisms.

### 3. Resource Block

```hcl
resource "aws_instance" "terraform_demo" {
```

The first value:

```text
aws_instance
```

is the Terraform resource type.

The second value:

```text
terraform_demo
```

is the local Terraform name.

Together:

```text
aws_instance.terraform_demo
```

identify the resource inside Terraform.

### 4. AMI

```hcl
ami = "REPLACE_WITH_VALID_AMI_ID"
```

An AMI defines the operating-system/image template used to launch the EC2 instance.

Example:

```text
Ubuntu
Amazon Linux
Red Hat
```

The AMI must be valid for the selected AWS region.

### 5. Instance Type

```hcl
instance_type = "t3.micro"
```

This determines the compute capacity of the EC2 instance.

For learning environments, a small instance type may be sufficient, but availability and pricing depend on the selected region and AWS account.

### 6. Subnet

```hcl
subnet_id = "REPLACE_WITH_VALID_SUBNET_ID"
```

The subnet determines where the EC2 instance is placed within the VPC networking architecture.

This is why basic AWS knowledge is important before learning Terraform deeply.

Terraform automates AWS infrastructure, but it does not replace understanding AWS concepts.

### 7. Key Pair

```hcl
key_name = "REPLACE_WITH_EXISTING_KEY_PAIR_NAME"
```

This specifies the EC2 key pair associated with the instance.

For Linux instances, this can be used for SSH access.

### 8. Tags

```hcl
tags = {
  Name        = "terraform-ec2-instance"
  Environment = "learning"
  ManagedBy   = "Terraform"
}
```

Tags help identify and organize resources.

A professional environment commonly uses standardized tags such as:

```text
Environment
Application
Owner
Project
CostCenter
ManagedBy
```

## Terraform Command Reference

| Command                | Purpose                        |
| ---------------------- | ------------------------------ |
| `terraform version`    | Check Terraform version        |
| `terraform init`       | Initialize project             |
| `terraform fmt`        | Format configuration           |
| `terraform validate`   | Validate configuration         |
| `terraform plan`       | Preview changes                |
| `terraform apply`      | Create/update infrastructure   |
| `terraform show`       | Display state                  |
| `terraform state list` | List managed resources         |
| `terraform destroy`    | Destroy managed infrastructure |

## End-to-End Execution Flow

```text
                  TERRAFORM EC2 PROVISIONING FLOW

                            Developer
                                │
                                ▼
                          Write main.tf
                                │
                                ▼
                          terraform fmt
                                │
                                ▼
                          terraform init
                                │
                                ▼
                        terraform validate
                                │
                                ▼
                          terraform plan
                                │
                          Review Changes
                                │
                                ▼
                        terraform apply
                                │
                                ▼
                          AWS Provider
                                │
                                ▼
                            AWS API
                                │
                                ▼
                          EC2 Instance
                                │
                                ▼
                        Terraform State
                      (terraform.tfstate)
                                │
                                │
                          Infrastructure
                            is managed
                                │
                                ▼
                       terraform destroy
                                │
                                ▼
                         EC2 Terminated
```
