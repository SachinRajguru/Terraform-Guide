
## Required Providers

**File:** 📄 `04-required-providers.md`

## Table of Contents

1. [Introduction](#1-introduction)
2. [Source Address](#2-source-address)
3. [Version Constraints](#3-version-constraints)
4. [Dependency Lock File](#4-dependency-lock-file)
5. [Recommended Structure](#5-recommended-structure)
6. [Important Distinction](#6-important-distinction)

## 1. Introduction

The `required_providers` block declares the providers required by a Terraform module.

It normally specifies:

* Local provider name
* Source address
* Version constraint

Example:

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

Terraform uses this information during initialization to determine which provider plugin must be installed. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/providers/requirements))

## 2. Source Address

The source:

```hcl
source = "hashicorp/aws"
```

identifies the provider.

The structure is generally:

```text
hostname/namespace/type
```

For the public Terraform Registry, the hostname can normally be omitted.

Therefore:

```text
hashicorp/aws
```

is the common form.

## 3. Version Constraints

> Provider versions evolve independently from Terraform versions.

We should therefore define a version constraint.

Example:

```hcl
version = "~> 6.0"
```

This prevents Terraform from automatically selecting an incompatible major release.

> HashiCorp recommends provider version constraints and a dependency lock file for consistent provider installation. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/language/providers/requirements))

## 4. Dependency Lock File

After:

```bash
terraform init
```

Terraform creates:

```text
.terraform.lock.hcl
```

This file records selected provider versions and checksums.

It should normally be committed to version control.

```text
Terraform Configuration
        │
        ▼
required_providers
        │
        ▼
terraform init
        │
        ▼
.terraform.lock.hcl
```

## 5. Recommended Structure

A professional Terraform project may use:

```text
terraform {
  required_version = ">= 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
```

The exact version constraint should be selected based on the versions tested by the project.

## 6. Important Distinction

```text
required_providers
        ↓
Which provider?
Which source?
Which versions?

provider
        ↓
How should that provider operate?
Which region?
Which endpoint?
Which configuration?
```
