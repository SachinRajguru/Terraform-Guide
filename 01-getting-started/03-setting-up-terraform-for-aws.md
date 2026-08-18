
## 03 — Setting Up Terraform for AWS

**File:** 📄 `03-setting-up-terraform-for-aws.md`

## Table of Contents

1. [Introduction](#1-introduction)
2. [AWS Authentication](#2-aws-authentication)
3. [Security Warning](#3-security-warning)
4. [Configure AWS CLI](#4-configure-aws-cli)
5. [Verify AWS Authentication](#5-verify-aws-authentication)
6. [AWS Provider](#6-aws-provider)
7. [Provider vs Credentials](#7-provider-vs-credentials)
8. [Recommended Authentication Flow](#8-recommended-authentication-flow)
9. [Terraform Provider Configuration](#9-terraform-provider-configuration)
10. [Terraform Initialization](#10-terraform-initialization)
11. [Verify Terraform Initialization](#11-verify-terraform-initialization)
12. [`.terraform` Directory](#12-terraform-directory)
13. [Terraform Lock File](#13-terraform-lock-file)
14. [AWS Region](#14-aws-region)
15. [Understanding the Authentication Boundary](#15-understanding-the-authentication-boundary)
16. [Recommended Enterprise Approach](#16-recommended-enterprise-approach)
17. [Security Checklist](#17-security-checklist)
18. [Outcome](#18-outcome)

## 1. Introduction

> Terraform itself does not automatically know which cloud platform we want to manage.

We need to configure an AWS provider.

The overall process is:

```text
AWS Account
     ↓
AWS Credentials
     ↓
AWS CLI Configuration
     ↓
Terraform AWS Provider
     ↓
AWS APIs
     ↓
AWS Infrastructure
```

## 2. AWS Authentication

Terraform needs permission to interact with AWS.

AWS authentication can be configured using mechanisms such as:

* AWS CLI credential configuration
* environment variables
* IAM roles
* IAM Identity Center
* instance/container roles
* other supported AWS credential mechanisms

For local learning, AWS CLI configuration is convenient.

## 3. Security Warning

AWS access keys and secret access keys are sensitive credentials.

Never:

```text
Commit credentials to Git
Paste credentials into GitHub
Put credentials directly into main.tf
Share credentials in screenshots
Send credentials through chat
```

Avoid using the AWS root user for routine Terraform work.

> For learning and real environments, use appropriately scoped non-root credentials and follow organizational security policies.

## 4. Configure AWS CLI

Run:

```bash
aws configure
```

The CLI will request information such as:

```text
AWS Access Key ID
AWS Secret Access Key
Default region name
Default output format
```

Example:

```text
AWS Access Key ID:     <ACCESS-KEY>
AWS Secret Access Key: <SECRET-KEY>
Default region name:   <AWS-REGION>
Default output format: json
```

> Security: Never replace the placeholders above with real credentials in documentation, source code, screenshots, or Git commits.

## 5. Verify AWS Authentication

Run:

```bash
aws sts get-caller-identity
```

A successful response identifies the AWS principal being used.

We can also test:

```bash
aws s3 ls
```

If permissions allow S3 listing, the command should return the available buckets.

## 6. AWS Provider

Terraform uses the AWS provider to communicate with AWS.

Example:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

This configuration tells Terraform:

```text
Provider = AWS
Region   = us-east-1
```

## 7. Provider vs Credentials

This distinction is important.

The provider configuration:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

specifies **where and which provider Terraform should use**.

It does not mean that credentials should be hard-coded into the Terraform file.

Terraform can use AWS's standard credential resolution mechanisms.

## 8. Recommended Authentication Flow

For local development:

```text
AWS CLI
   ↓
AWS Credential Configuration
   ↓
Terraform AWS Provider
   ↓
AWS API
```

This is preferable to:

```hcl
provider "aws" {
  access_key = "REAL_ACCESS_KEY"
  secret_key = "REAL_SECRET_KEY"
}
```

Do not put real credentials into Terraform source code.

## 9. Terraform Provider Configuration

A simple provider block:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

This is enough for Terraform to understand that AWS is the target provider.

## 10. Terraform Initialization

Once the provider is configured, execute:

```bash
terraform init
```

Terraform reads the configuration and downloads the required provider plugins.

Simplified process:

```text
main.tf
   ↓
terraform init
   ↓
Read provider configuration
   ↓
Download AWS provider
   ↓
Initialize working directory
```

## 11. Verify Terraform Initialization

A successful initialization generally produces a message similar to:

```text
Terraform has been successfully initialized!
```

Terraform also creates local working information, including the `.terraform` directory.

## 12. `.terraform` Directory

After initialization:

```text
project/
├── main.tf
└── .terraform/
```

The `.terraform` directory contains Terraform's local working information and provider-related files.

It normally should not be committed to Git.

## 13. Terraform Lock File

Terraform may create:

```text
.terraform.lock.hcl
```

This file records provider dependency selections and checksums.

Unlike `.terraform/`, the lock file is normally useful to commit to version control.

## 14. AWS Region

AWS infrastructure is generally created inside a region.

Examples:

```text
us-east-1
us-west-2
ap-south-1
eu-west-1
```

For users in India, `ap-south-1` is the Mumbai region.

Example:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

The region should be selected based on the project's requirements.

## 15. Understanding the Authentication Boundary

There are two separate concepts:

### AWS CLI Authentication

```bash
aws configure
```

This establishes AWS CLI credentials.

### Terraform Provider Configuration

```hcl
provider "aws" {
  region = "us-east-1"
}
```

Terraform uses the AWS provider and AWS's credential mechanisms to authenticate.

Therefore:

```text
AWS CLI Credentials
       +
AWS Provider
       ↓
Terraform → AWS
```

## 16. Recommended Enterprise Approach

In production, authentication should normally use short-lived or role-based credentials where possible.

Examples:

```text
Developer
   ↓
AWS Identity Center
   ↓
Temporary Credentials
   ↓
Terraform
```

or:

```text
CI/CD Pipeline
   ↓
IAM Role
   ↓
Temporary Credentials
   ↓
Terraform
```

Avoid permanent long-lived credentials wherever a safer mechanism is available.

## 17. Security Checklist

Before running Terraform against AWS:

```text
[ ] AWS account is available
[ ] Appropriate IAM permissions exist
[ ] AWS CLI is installed
[ ] AWS authentication is configured
[ ] aws sts get-caller-identity works
[ ] AWS region is selected
[ ] Terraform AWS provider is configured
[ ] Credentials are not stored in Git
```

## 18. Outcome

At this stage:

```text
Terraform
    ↓
AWS Provider
    ↓
AWS Authentication
    ↓
AWS API
```

is ready.

> We can now start writing Terraform resources.
