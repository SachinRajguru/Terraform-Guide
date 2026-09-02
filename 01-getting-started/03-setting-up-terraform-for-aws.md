
## Setting Up Terraform for AWS

> **File:** `03-setting-up-terraform-for-aws.md`

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
19. [Key Takeaways](#19-key-takeaways)
20. [Official References](#20-official-references)

## 1. Introduction

Terraform itself does not automatically know which cloud platform we want to manage.

To manage AWS infrastructure, we configure the **AWS provider**.

The provider acts as the integration layer between Terraform and the AWS APIs.

The overall relationship is:

```text
AWS Account
     │
     │
     ▼
AWS Authentication
     │
     ▼
AWS Credentials / Identity
     │
     ▼
Terraform AWS Provider
     │
     ▼
AWS APIs
     │
     ▼
AWS Infrastructure
```

There are two important concepts to understand before we begin:

1. **Authentication** — How Terraform proves who we are to AWS.
2. **Provider configuration** — How Terraform knows that AWS is the target platform and which region or other provider settings to use.

These concepts are related, but they are not the same.

## 2. AWS Authentication

Terraform needs permission to communicate with AWS.

AWS supports several authentication mechanisms, including:

* AWS CLI credential configuration
* Environment variables
* AWS IAM Identity Center
* IAM roles
* Instance roles
* Container/task roles
* Web identity / OIDC-based credentials
* Other credential mechanisms supported by the AWS SDK

For local learning environments, configuring AWS credentials through the AWS CLI is a straightforward starting point.

A simplified local development flow is:

```text
Developer
    │
    ▼
AWS CLI
    │
    ▼
AWS Credentials
    │
    ▼
Terraform AWS Provider
    │
    ▼
AWS APIs
```

However, we should understand that Terraform does **not** depend on the AWS CLI command itself for every AWS API request.

Terraform's AWS provider uses AWS's credential resolution mechanisms to obtain credentials.

The AWS CLI is simply one convenient way to configure or obtain those credentials.

## 3. Security Warning

AWS credentials are sensitive information.

Examples include:

```text
AWS Access Key ID
AWS Secret Access Key
Session Credentials
Private Keys
Passwords
Tokens
```

Never:

```text
Commit credentials to Git
Paste credentials into GitHub
Put credentials directly into main.tf
Put credentials directly into provider blocks
Share credentials in screenshots
Send credentials through chat
Store credentials in README.md
Publish credentials in a public repository
```

For example, we should **never** write:

```hcl
provider "aws" {
  region     = "us-east-1"
  access_key = "REAL_ACCESS_KEY"
  secret_key = "REAL_SECRET_KEY"
}
```

This creates a serious security risk because Terraform configuration files are normally stored in version control.

### Avoid the AWS Root User

The AWS root user should not be used for routine Terraform operations.

Instead, use an appropriately scoped identity with only the permissions required for the work being performed.

For learning environments, we should still follow the principle of least privilege whenever possible.

> **Security principle:** Credentials should be supplied through an approved authentication mechanism rather than hard-coded into Terraform configuration.

## 4. Configure AWS CLI

If we are using the AWS CLI for local authentication, we can configure it using:

```bash
aws configure
```

The CLI prompts for information such as:

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
Default region name:  <AWS-REGION>
Default output format: json
```

The values above are placeholders.

We must never replace them with real credentials in documentation, source code, screenshots, or Git commits.

### What Does `aws configure` Do?

The exact behavior depends on the credentials and configuration being supplied.

For a typical access-key-based setup, AWS CLI stores configuration and credentials in the user's AWS configuration directory.

Common files include:

```text
~/.aws/config
~/.aws/credentials
```

On Windows, the corresponding location is typically under:

```text
%USERPROFILE%\.aws\
```

The exact configuration can vary depending on the authentication method and profile being used.

### AWS Profiles

AWS CLI also supports named profiles.

For example:

```bash
aws configure --profile dev
```

We can then use:

```bash
aws sts get-caller-identity --profile dev
```

Profiles become especially useful when working with multiple AWS accounts or environments.

For example:

```text
AWS
├── dev
├── staging
└── production
```

Each profile can represent a different AWS identity or account configuration.

## 5. Verify AWS Authentication

Before involving Terraform, we should verify that AWS authentication works independently.

Run:

```bash
aws sts get-caller-identity
```

A successful response looks conceptually similar to:

```json
{
  "UserId": "...",
  "Account": "...",
  "Arn": "..."
}
```

The exact values depend on the AWS identity being used.

This command is important because it tells us which AWS principal is currently being used.

The flow is:

```text
AWS CLI
   │
   ▼
AWS Credential Resolution
   │
   ▼
AWS STS
   │
   ▼
GetCallerIdentity
   │
   ▼
Current AWS Identity
```

### Optional AWS Resource Test

We can also test an AWS service:

```bash
aws s3 ls
```

If the current identity has permission to list S3 buckets, the command will return the available buckets.

However, an `AccessDenied` response does **not necessarily mean authentication failed**.

It can mean:

```text
Authentication → Successful
Authorization   → Insufficient permission
```

This distinction is important.

### Authentication vs Authorization

```text
Authentication
     │
     └── Who are we?

Authorization
     │
     └── What are we allowed to do?
```

For example:

```text
aws sts get-caller-identity
        │
        └── Authentication / identity verification

aws s3 ls
        │
        └── Requires appropriate S3 permissions
```

Therefore, `aws sts get-caller-identity` is the preferred initial authentication check.

## 6. AWS Provider

Terraform uses providers to interact with external platforms and services.

For AWS infrastructure, we use the **AWS provider**.

A basic provider configuration is:

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

The AWS provider translates Terraform resource operations into AWS API operations.

Conceptually:

```text
Terraform Configuration
        │
        ▼
Terraform Core
        │
        ▼
AWS Provider
        │
        ▼
AWS API
        │
        ▼
AWS Resource
```

For example, if our Terraform configuration declares an AWS EC2 instance, the AWS provider communicates with AWS to create, modify, or delete that resource.

## 7. Provider vs Credentials

This distinction is extremely important.

Consider:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

The provider configuration primarily tells Terraform:

```text
Use AWS
Use the us-east-1 region
```

It does **not** mean that credentials should be hard-coded into the Terraform configuration.

We should not confuse:

```text
Provider Configuration
```

with:

```text
Authentication Credentials
```

### Provider Configuration

Example:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

### Authentication

Authentication can come from mechanisms such as:

```text
AWS CLI profile
Environment variables
IAM Identity Center
IAM role
Instance role
Container role
OIDC / web identity
Other AWS-supported mechanisms
```

Conceptually:

```text
Terraform Configuration
        │
        ├── AWS Provider
        │      └── Region
        │
        └── AWS Credential Resolution
               └── Identity
```

This separation allows the same Terraform configuration to be used across different environments without embedding credentials into the code.

## 8. Recommended Authentication Flow

For a simple local learning environment, one possible approach is:

```text
AWS CLI
   │
   ▼
AWS Credential Configuration
   │
   ▼
AWS Credential Resolution
   │
   ▼
Terraform AWS Provider
   │
   ▼
AWS API
```

For example:

```bash
aws configure
```

followed by:

```bash
aws sts get-caller-identity
```

Then Terraform can use the AWS provider:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

The important point is that we do **not** place the actual credentials inside the provider block.

### What We Should Avoid

Do not use:

```hcl
provider "aws" {
  access_key = "REAL_ACCESS_KEY"
  secret_key = "REAL_SECRET_KEY"
  region     = "us-east-1"
}
```

Instead:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

and allow the AWS provider to obtain credentials through the configured AWS authentication mechanism.

## 9. Terraform Provider Configuration

Create a Terraform configuration file such as:

```text
main.tf
```

Add:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

At this stage, we have not created an AWS resource yet.

We have only told Terraform:

```text
Target Platform → AWS
Target Region   → us-east-1
```

A minimal project can look like:

```text
terraform-project/
└── main.tf
```

The configuration can later be expanded with Terraform resources.

For example:

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "example" {
  bucket = "example-terraform-bucket"
}
```

The resource itself is not the focus of this section. The important point is understanding how Terraform connects to AWS.

## 10. Terraform Initialization

Once the provider configuration exists, run:

```bash
terraform init
```

`terraform init` initializes the Terraform working directory.

Among other tasks, Terraform:

* Reads the configuration
* Identifies required providers
* Downloads required provider packages
* Installs provider dependencies
* Initializes the working directory
* Prepares the directory for subsequent Terraform commands

The simplified process is:

```text
main.tf
   │
   ▼
terraform init
   │
   ├── Read configuration
   │
   ├── Identify required providers
   │
   ├── Resolve provider version
   │
   ├── Download provider
   │
   └── Initialize working directory
```

### Why Is `terraform init` Required?

Terraform configuration may declare external dependencies such as providers and modules.

Terraform needs to obtain those dependencies before it can perform operations such as:

```bash
terraform plan
```

or:

```bash
terraform apply
```

Therefore, initialization is normally the first Terraform command we run inside a new working directory.

## 11. Verify Terraform Initialization

Run:

```bash
terraform init
```

A successful initialization generally produces output indicating that Terraform has been successfully initialized.

The exact output depends on the Terraform version and provider configuration.

We can then run:

```bash
terraform validate
```

A successful validation should indicate that the configuration is valid.

A useful basic workflow is:

```bash
terraform init
terraform validate
```

The distinction is:

```text
terraform init
        ↓
Prepare Terraform working directory

terraform validate
        ↓
Check Terraform configuration syntax and structure
```

Initialization also creates local working information.

## 12. `.terraform` Directory

After initialization, our project may look like:

```text
terraform-project/
│
├── main.tf
│
└── .terraform/
```

The `.terraform` directory contains Terraform's local working information, including downloaded provider-related data and other initialization artifacts.

We normally **do not commit this directory to Git**.

A typical `.gitignore` entry is:

```gitignore
.terraform/
```

The important distinction is:

```text
.terraform/
        ↓
Generated local working directory
        ↓
Do not normally commit
```

Terraform can recreate this directory by running:

```bash
terraform init
```

## 13. Terraform Lock File

Terraform may also create:

```text
.terraform.lock.hcl
```

The lock file is different from the `.terraform` directory.

The lock file records provider dependency selections and checksums so that Terraform can consistently use the selected provider versions.

For example:

```text
terraform-project/
│
├── main.tf
├── .terraform/
└── .terraform.lock.hcl
```

### Should We Commit the Lock File?

Yes.

For most Terraform projects, the provider lock file should be committed to version control.

The recommended distinction is:

```text
.terraform/
        → Do not normally commit

.terraform.lock.hcl
        → Commit to version control
```

This helps maintain consistent provider dependency selections across development environments and CI/CD systems.

## 14. AWS Region

AWS infrastructure is generally associated with an AWS region.

Examples include:

```text
us-east-1
us-west-2
ap-south-1
eu-west-1
```

For example:

```text
ap-south-1
```

is the AWS Mumbai region.

We can specify the region in the provider:

```hcl
provider "aws" {
  region = "ap-south-1"
}
```

Or:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

The appropriate region depends on project requirements.

### Why Does Region Matter?

Different AWS resources may exist in different regions.

For example:

```text
AWS Account
    │
    ├── us-east-1
    │      ├── EC2
    │      └── S3
    │
    ├── ap-south-1
    │      ├── EC2
    │      └── S3
    │
    └── eu-west-1
           ├── EC2
           └── S3
```

Therefore, we should deliberately choose the region instead of assuming that every AWS resource exists globally or in the same location.

### Region Is Not the Same as Account

These are separate concepts:

```text
AWS Account
     │
     ├── Region A
     ├── Region B
     └── Region C
```

An AWS account can use multiple regions.

The provider configuration determines the region in which regional resources are managed unless other provider configurations or mechanisms are used.

## 15. Understanding the Authentication Boundary

At this stage, we should clearly understand the boundary between AWS authentication and Terraform configuration.

### AWS Authentication

For example:

```bash
aws configure
```

This can configure AWS CLI credentials.

We can verify the identity with:

```bash
aws sts get-caller-identity
```

### Terraform Provider Configuration

Terraform can use:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

This identifies AWS as the provider and specifies the region.

The complete relationship is:

```text
AWS Identity / Credentials
          │
          │
          ▼
AWS Credential Resolution
          │
          │
          ▼
Terraform AWS Provider
          │
          │
          ├── Provider = AWS
          │
          └── Region = us-east-1
          │
          ▼
       AWS APIs
```

Therefore:

```text
Authentication
      +
Provider Configuration
      ↓
Terraform → AWS
```

### Important Concept

Installing AWS CLI does not automatically mean that Terraform has been explicitly configured with credentials.

Likewise, defining an AWS provider does not mean that credentials have been hard-coded into Terraform.

The provider uses the AWS credential mechanisms available to it.

## 16. Recommended Enterprise Approach

The `aws configure` approach is useful for learning and certain local development scenarios, but production environments should generally prefer stronger identity and credential-management mechanisms.

Examples include:

```text
IAM Identity Center
Temporary Credentials
IAM Roles
OIDC / Web Identity
Instance Roles
Container Roles
Federated Identity
Organization-approved credential providers
```

### Developer Authentication

A modern developer workflow may look like:

```text
Developer
    │
    ▼
AWS IAM Identity Center
    │
    ▼
Temporary Credentials
    │
    ▼
Terraform
    │
    ▼
AWS
```

### CI/CD Authentication

A CI/CD pipeline can use a role-based or OIDC-based model:

```text
GitHub Actions / CI Pipeline
          │
          ▼
    OIDC Identity
          │
          ▼
    AWS IAM Role
          │
          ▼
Temporary Credentials
          │
          ▼
      Terraform
          │
          ▼
         AWS
```

### AWS Compute Authentication

Applications running inside AWS can often use workload identities or IAM roles:

```text
EC2 / ECS / EKS
      │
      ▼
IAM Role / Workload Identity
      │
      ▼
Temporary Credentials
      │
      ▼
AWS APIs
```

This is preferable to distributing permanent access keys.

### Principle of Least Privilege

The identity used by Terraform should receive only the permissions required for the intended operations.

For example:

```text
Developer
   │
   ▼
Required AWS Permissions
   │
   ├── Read resources
   ├── Create resources
   ├── Modify resources
   └── Delete resources
```

We should avoid granting unrestricted permissions unless there is a justified requirement.

## 17. Security Checklist

Before running Terraform against AWS, verify the following:

```text
[ ] AWS account is available

[ ] Appropriate AWS identity exists

[ ] Required IAM permissions exist

[ ] AWS CLI is installed

[ ] AWS authentication is configured

[ ] aws sts get-caller-identity works

[ ] AWS region is selected

[ ] Terraform is installed

[ ] AWS provider is configured

[ ] terraform init succeeds

[ ] .terraform/ is not committed

[ ] .terraform.lock.hcl is committed

[ ] Credentials are not stored in Terraform source code

[ ] Credentials are not committed to Git

[ ] AWS root user is not being used for routine work
```

A basic `.gitignore` should normally contain:

```gitignore
.terraform/
```

We should **not** add the lock file to `.gitignore`:

```text
.terraform.lock.hcl
```

because the lock file should normally be tracked.

## 18. Outcome

At the end of this section, we should understand how Terraform connects to AWS.

The overall flow is:

```text
AWS Account
     │
     ▼
AWS Identity
     │
     ▼
AWS Credential Resolution
     │
     ▼
Terraform AWS Provider
     │
     ▼
AWS API
     │
     ▼
AWS Infrastructure
```

Our basic Terraform project can now look like:

```text
terraform-project/
│
├── main.tf
├── .terraform/
├── .terraform.lock.hcl
└── .gitignore
```

Where:

```text
main.tf
    → Terraform configuration

.terraform/
    → Local generated working directory

.terraform.lock.hcl
    → Provider dependency lock file

.gitignore
    → Prevents generated/sensitive files from being committed
```

A basic provider configuration is:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

We can initialize the project with:

```bash
terraform init
```

Then validate it with:

```bash
terraform validate
```

At this point, Terraform is prepared to work with AWS.

## 19. Key Takeaways

We learned:

1. Terraform requires a provider to interact with AWS.
2. The AWS provider acts as the integration layer between Terraform and AWS APIs.
3. AWS authentication and Terraform provider configuration are separate concepts.
4. AWS CLI configuration is one possible authentication mechanism for local development.
5. `aws sts get-caller-identity` is a useful way to verify the current AWS identity.
6. An authentication failure and an authorization failure are different problems.
7. We should never hard-code AWS credentials into Terraform configuration.
8. AWS regions determine where many AWS resources are managed.
9. `terraform init` initializes a Terraform working directory and installs required provider dependencies.
10. The `.terraform/` directory contains generated local Terraform working information and should not normally be committed.
11. `.terraform.lock.hcl` records provider selections and checksums and should normally be committed.
12. The same Terraform configuration can be used across environments when authentication is kept outside the source code.
13. Production environments should prefer temporary, role-based, federated, or otherwise organization-approved authentication mechanisms.
14. Least privilege should be applied to Terraform identities.
15. AWS authentication must be treated as a security boundary.

The resulting mental model is:

```text
                 Terraform
                     │
                     ▼
              AWS Provider
                     │
          ┌──────────┴──────────┐
          │                     │
       Region              Credentials
          │                     │
          │              AWS Credential
          │                Resolution
          │                     │
          └──────────┬──────────┘
                     ▼
                  AWS API
                     │
                     ▼
             AWS Infrastructure
```

We are now ready to move from **Terraform environment setup** to writing and managing actual AWS infrastructure with Terraform.

## 20. Official References

* [HashiCorp — AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
* [HashiCorp — Terraform CLI `init`](https://developer.hashicorp.com/terraform/cli/commands/init)
* [HashiCorp — Terraform Provider Requirements](https://developer.hashicorp.com/terraform/language/providers/requirements)
* [HashiCorp — Dependency Lock File](https://developer.hashicorp.com/terraform/language/files/dependency-lock)
* [AWS — Configure the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
* [AWS — AWS CLI Configuration and Credential Files](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
* [AWS — `get-caller-identity`](https://docs.aws.amazon.com/cli/latest/reference/sts/get-caller-identity.html)
* [AWS — IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
* [AWS — IAM Identity Center](https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html)
