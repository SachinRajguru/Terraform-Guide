
## 02 — Installing Terraform on Windows, Linux, macOS and GitHub Codespaces

**File:** 📄 `02-installing-terraform.md`

## Table of Contents

1. [Introduction](#1-introduction)
2. [Local Terraform Installation](#2-local-terraform-installation)
3. [Installing Terraform on Windows](#3-installing-terraform-on-windows)
4. [Installing Terraform on Linux](#4-installing-terraform-on-linux)
5. [Installing Terraform on macOS](#5-installing-terraform-on-macos)
6. [Installing Git](#6-installing-git)
7. [Installing Visual Studio Code](#7-installing-visual-studio-code)
8. [Installing the Terraform VS Code Extension](#8-installing-the-terraform-vs-code-extension)
9. [GitHub Codespaces](#9-github-codespaces)
10. [Fork or Use Our Existing Repository](#10-fork-or-use-our-existing-repository)
11. [Create a GitHub Codespace](#11-create-a-github-codespace)
12. [Wait for Codespace Creation](#12-wait-for-codespace-creation)
13. [Open the Codespace](#13-open-the-codespace)
14. [Open the Terminal](#14-open-the-terminal)
15. [Configure the Dev Container](#15-configure-the-dev-container)
16. [Open the Command Palette](#16-open-the-command-palette)
17. [Select "Modify Your Active Configuration"](#17-select-modify-your-active-configuration)
18. [Add Terraform](#18-add-terraform)
19. [Click OK](#19-click-ok)
20. [Add AWS CLI](#20-add-aws-cli)
21. [Search for AWS CLI](#21-search-for-aws-cli)
22. [Click OK](#22-click-ok)
23. [Important — Configuration Has Changed](#23-important--configuration-has-changed)
24. [Rebuild the Container](#24-rebuild-the-container)
25. [Alternative — Rebuild Using Command Palette](#25-alternative--rebuild-using-command-palette)
26. [What Happens During the Rebuild?](#26-what-happens-during-the-rebuild)
27. [Wait for the Rebuild](#27-wait-for-the-rebuild)
28. [Verify Terraform](#28-verify-terraform)
29. [Verify AWS CLI](#29-verify-aws-cli)
30. [Verify Git](#30-verify-git)
31. [Final Codespaces Verification](#31-final-codespaces-verification)
32. [Complete Codespaces Setup Flow](#32-complete-codespaces-setup-flow)
33. [Visual Codespaces Architecture](#33-visual-codespaces-architecture)
34. [Fork vs Existing Repository](#34-fork-vs-existing-repository)
35. [Why We Use `devcontainer.json`](#35-why-we-use-devcontainerjson)
36. [Reopening an Existing Codespace](#36-reopening-an-existing-codespace)
37. [Important Rebuild Concept](#37-important-rebuild-concept)
38. [Repository Files During Rebuild](#38-repository-files-during-rebuild)
39. [Terraform Project Inside Codespaces](#39-terraform-project-inside-codespaces)
40. [Configure AWS Authentication](#40-configure-aws-authentication)
41. [Important Security Rules](#41-important-security-rules)
42. [Codespaces Usage and Billing](#42-codespaces-usage-and-billing)
43. [Codespaces Troubleshooting](#43-codespaces-troubleshooting)
44. [Recommended Development Environment](#44-recommended-development-environment)
45. [Installation Verification Checklist](#45-installation-verification-checklist)
46. [Common Local Installation Problems](#46-common-local-installation-problems)
47. [Installation Outcome](#47-installation-outcome)
48. [Key Takeaways](#48-key-takeaways)

## 1. Introduction

Before writing and executing Terraform configurations, we need a working Terraform development environment.

Terraform can be used in two primary ways:

1. **Local Development Environment**
2. **Cloud-Based Development Environment using GitHub Codespaces**

For this Terraform learning series, both approaches are useful.

### Option 1 — Local Development Environment

Terraform can be installed directly on:

* Windows
* Linux
* macOS

A typical Terraform development environment consists of:

```text
Visual Studio Code
Terraform CLI
AWS CLI
Git
Terraform VS Code Extension
```

This approach is suitable when we have administrative access to our computer and are allowed to install development tools.

### Option 2 — GitHub Codespaces

GitHub Codespaces provides a cloud-hosted development environment that we can access through a browser or VS Code.

It is particularly useful when:

* Terraform cannot be installed locally.
* The laptop has corporate restrictions.
* Administrator privileges are unavailable.
* Software installation is restricted.
* The local machine has limited resources.
* We want a portable development environment.
* We want to access our development environment from different computers.

GitHub Codespaces runs the development environment in a container on a virtual machine. ([GitHub Docs](https://docs.github.com/en/codespaces/developing-in-a-codespace/rebuilding-the-container-in-a-codespace))

The simplified architecture is:

```text
Laptop / Browser
       ↓
    GitHub
       ↓
   Codespace
       ↓
Virtual Machine
       ↓
Development Container
       ↓
VS Code Environment
       ↓
Terraform + AWS CLI + Git
```

## 2. Local Terraform Installation

### 2.1 Identify the Operating System and Architecture

Before installing Terraform, identify:

* Operating system
* CPU architecture

Common architectures are:

```text
AMD64 / x86_64
ARM64
```

For example, many Intel and AMD Windows laptops use:

```text
AMD64
```

Apple Silicon Macs generally use:

```text
ARM64
```

HashiCorp provides Terraform packages for multiple operating systems and architectures. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/install))

## 3. Installing Terraform on Windows

### 3.1 Download Terraform

Terraform can be installed on Windows using the official Terraform distribution.

The manual installation provides a ZIP archive containing the Terraform executable.

The executable is:

```text
terraform.exe
```

Download the appropriate Windows architecture from the official HashiCorp Terraform installation page. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/install))

### 3.2 Extract Terraform

Extract the downloaded archive.

For example:

```text
C:\Terraform\
```

The directory should contain:

```text
C:\Terraform\
└── terraform.exe
```

### 3.3 Configure PATH

Terraform needs to be available from the terminal.

Add:

```text
C:\Terraform
```

to the Windows `PATH`.

After modifying the `PATH`, close the existing terminal and open a new terminal.

### 3.4 Verify Terraform

Run:

```bash
terraform version
```

Example:

```text
Terraform v1.x.x
on windows_amd64
```

The exact version will depend on the version currently installed.

### 3.5 Windows Package Manager Option

Terraform can also be installed using package managers such as Chocolatey.

For example:

```bash
choco install terraform
```

However, Chocolatey and its Terraform package are not maintained by HashiCorp. The official Terraform binary remains the authoritative distribution. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli))

### 3.6 Recommended Windows Terminals

We can use:

* PowerShell
* Git Bash
* Windows Terminal

For this learning series, **Git Bash** is particularly convenient because many Linux-style commands can be used.

For example:

```bash
terraform version
```

## 4. Installing Terraform on Linux

Terraform installation depends on the Linux distribution.

HashiCorp provides official installation instructions for distributions including:

* Ubuntu/Debian
* RHEL/CentOS
* Fedora
* Amazon Linux

For Ubuntu/Debian, HashiCorp provides an official APT repository. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/install))

### 4.1 Ubuntu/Debian Installation

Install the required packages:

```bash
sudo apt-get update
sudo apt-get install -y gnupg software-properties-common
```

Add the HashiCorp signing key:

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
```

Add the HashiCorp repository:

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
```

Update the package information:

```bash
sudo apt update
```

Install Terraform:

```bash
sudo apt-get install terraform
```

Verify:

```bash
terraform version
```

These commands follow HashiCorp's current Ubuntu/Debian installation procedure. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli))

### 4.2 Other Linux Distributions

For other distributions, use the appropriate package repository or the official Terraform binary.

HashiCorp currently provides installation instructions for:

```text
RHEL / CentOS
Fedora
Amazon Linux
Ubuntu / Debian
Other Linux distributions
```

Refer to the official installation documentation when working with a different distribution. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/install))

## 5. Installing Terraform on macOS

Terraform can be installed on macOS using Homebrew.

First, add the HashiCorp tap:

```bash
brew tap hashicorp/tap
```

Then install Terraform:

```bash
brew install hashicorp/tap/terraform
```

Verify:

```bash
terraform version
```

HashiCorp officially documents Homebrew as a supported installation method for macOS. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/install))

## 6. Installing Git

[Git](https://git-scm.com/install/) is strongly recommended for Terraform development.

Terraform configurations should normally be maintained in version control.

Verify Git:

```bash
git --version
```

Expected output:

```text
git version 2.x.x
```

## 7. Installing Visual Studio Code

[Visual Studio Code](https://code.visualstudio.com/download?_exp_download=fb315fc982) provides a convenient environment for Terraform development.

Useful capabilities include:

* Syntax highlighting
* Terraform formatting
* Autocomplete
* Integrated terminal
* Git integration
* Extension support
* Code navigation

For this learning series, VS Code is the recommended IDE.

## 8. Installing the Terraform VS Code Extension

Open VS Code:

```text
Extensions
    ↓
Search: Terraform
    ↓
HashiCorp Terraform
    ↓
Install
```

The official HashiCorp Terraform extension improves the Terraform authoring experience.

## 9. GitHub Codespaces

### 9.1 Why GitHub Codespaces?

A local installation is not always possible.

For example, an organization may provide a laptop where:

```text
Terraform installation → Restricted
AWS CLI installation   → Restricted
Administrator access   → Unavailable
```

Instead of spending time modifying the corporate laptop, we can use GitHub Codespaces.

The architecture becomes:

```text
Laptop / Browser
       ↓
    GitHub
       ↓
GitHub Codespaces
       ↓
Development Container
       ↓
Terraform + AWS CLI + Git
```

GitHub provides Dev Container configuration mechanisms specifically for customizing the tools available inside a Codespace. ([GitHub Docs](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers))

## 10. Fork or Use Our Existing Repository

Before creating a Codespace, we need a GitHub repository.

There are two scenarios.

### 10.1 Scenario A — Following Someone Else's Repository

If we are following an existing Terraform course repository:

```text
Original Repository
       ↓
      Fork
       ↓
Our GitHub Repository
       ↓
   Codespaces
```

Forking creates our own copy of the repository.

This is useful when we want to experiment without modifying the original repository.

### 10.2 Scenario B — Using Our Existing Repository

If we already have our own repository, such as:

```text
Terraform-Guide
```

we do **not** need to fork it.

We can directly create a Codespace from:

```text
Terraform-Guide
```

The flow is:

```text
Terraform-Guide
       ↓
     Code
       ↓
   Codespaces
       ↓
Create Codespace
```

## 11. Create a GitHub Codespace

Open our repository on GitHub.

For example:

```text
GitHub
   ↓
Terraform-Guide
```

Then select:

```text
Code
   ↓
Codespaces
   ↓
Create codespace
```

GitHub may display additional configuration options depending on the repository and account, such as:

* Branch
* Dev Container configuration
* Region
* Machine type

The available options can vary.

## 12. Wait for Codespace Creation

GitHub performs several operations while creating the Codespace.

Conceptually:

```text
Create Codespace
       ↓
Virtual Machine Assigned
       ↓
Storage Assigned
       ↓
Development Container Created
       ↓
Repository Cloned
       ↓
VS Code Connected
       ↓
Codespace Ready
```

The development container runs on a virtual machine. ([GitHub Docs](https://docs.github.com/en/codespaces/developing-in-a-codespace/rebuilding-the-container-in-a-codespace))

## 13. Open the Codespace

Once creation is complete, the browser opens a VS Code-like environment.

We should see:

```text
Explorer
Source Control
Extensions
Terminal
Editor
```

At this point, we have a cloud-based development environment.

## 14. Open the Terminal

Open:

```text
Terminal
    ↓
New Terminal
```

Check whether Terraform is already available:

```bash
terraform version
```

Also check AWS CLI:

```bash
aws --version
```

And Git:

```bash
git --version
```

Depending on the selected Codespace image/configuration, some tools may already be available.

However, for this Terraform Guide, we want to explicitly configure the development environment.

## 15. Configure the Dev Container

> This is the **important Codespaces setup**.

We are going to configure the development container so that Terraform and AWS CLI are installed automatically.

The configuration is stored under:

```text
.devcontainer/
└── devcontainer.json
```

GitHub documents `.devcontainer` as the location for Dev Container configuration files. ([GitHub Docs](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers))

## 16. Open the Command Palette

Open the VS Code Command Palette.

### Windows/Linux

```text
Ctrl + Shift + P
```

### macOS

```text
Command + Shift + P
```

Then search for:

```text
Add Dev Container Configuration Files
```

Select:

```text
Codespaces: Add Dev Container Configuration Files
```

This is the current GitHub workflow for adding Dev Container configuration from VS Code. ([GitHub Docs](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/configuring-dev-containers/adding-features-to-a-devcontainer-file))

## 17. Select "Modify Your Active Configuration"

Because we are already inside a Codespace, select:

```text
Modify your active configuration
```

This allows us to modify the Dev Container configuration currently used by the Codespace. ([GitHub Docs](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/configuring-dev-containers/adding-features-to-a-devcontainer-file))

## 18. Add Terraform

The feature selection screen will appear.

Search for:

```text
Terraform
```

Select the appropriate Terraform Dev Container Feature.

Conceptually:

```text
Modify your active configuration
             ↓
          Search
             ↓
         Terraform
             ↓
       Select Feature
```

The Dev Container feature installs Terraform into the development container.

GitHub supports adding Features to `devcontainer.json`, and the Dev Container ecosystem provides a Terraform feature. ([GitHub Docs](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/configuring-dev-containers/adding-features-to-a-devcontainer-file))

## 19. Click OK

After selecting Terraform:

```text
Terraform
    ↓
Select
    ↓
Click OK
```

VS Code updates:

```text
.devcontainer/devcontainer.json
```

The configuration now contains the Terraform tooling.

## 20. Add AWS CLI

Now we also need AWS CLI.

Open the Command Palette again:

```text
Ctrl + Shift + P
```

Search:

```text
Add Dev Container Configuration Files
```

Select:

```text
Codespaces: Add Dev Container Configuration Files
```

Then:

```text
Modify your active configuration
```

## 21. Search for AWS CLI

Search for:

```text
AWS CLI
```

Select the AWS CLI Dev Container Feature.

The official Dev Container Feature reference is:

```text
ghcr.io/devcontainers/features/aws-cli:1
```

The Dev Container project currently publishes an AWS CLI feature under this reference. ([GitHub](https://github.com/devcontainers/features/pkgs/container/features%2Faws-cli))

## 22. Click OK

After selecting AWS CLI:

```text
AWS CLI
   ↓
Select
   ↓
Click OK
```

The active Dev Container configuration now contains the required tooling.

Conceptually:

```text
.devcontainer/
└── devcontainer.json

        ↓

Development Container
        │
        ├── Terraform
        └── AWS CLI
```

## 23. Important — Configuration Has Changed

At this point, the configuration has changed.

However, the currently running container has not necessarily been rebuilt yet.

Think of it as:

```text
devcontainer.json
       ↓
Configuration Updated
       ↓
Current Container
       ↓
Still Running
```

Therefore, we need to rebuild the container.

> GitHub explicitly requires rebuilding an existing Codespace for changes to Dev Container configuration to take effect. ([GitHub Docs](https://docs.github.com/en/codespaces/reference/using-the-vs-code-command-palette-in-codespaces))

## 24. Rebuild the Container

After changing the configuration, VS Code should display a notification.

It will indicate that the Dev Container configuration has changed.

Select:

```text
Rebuild Now
```

This is the easiest method.

The flow is:

```text
Terraform Feature
       ↓
Click OK

AWS CLI Feature
       ↓
Click OK

Configuration Changed
       ↓
Rebuild Now
```

GitHub documents this exact workflow. ([GitHub Docs](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/configuring-dev-containers/adding-features-to-a-devcontainer-file))

## 25. Alternative — Rebuild Using Command Palette

If the **Rebuild Now** notification does not appear:

Open:

```text
Ctrl + Shift + P
```

Search:

```text
Rebuild
```

Select:

```text
Codespaces: Rebuild Container
```

Then confirm:

```text
Rebuild
```

> GitHub currently documents **Codespaces: Rebuild Container** as the Command Palette method. ([GitHub Docs](https://docs.github.com/en/codespaces/reference/using-the-vs-code-command-palette-in-codespaces))

## 26. What Happens During the Rebuild?

The conceptual process is:

```text
devcontainer.json
        ↓
Rebuild Container
        ↓
Read Configuration
        ↓
Install Features
        ↓
Create Development Container
        ↓
Start Container
        ↓
Connect VS Code
```

> Terraform and AWS CLI are installed as part of the configured development environment.

## 27. Wait for the Rebuild

The rebuild can take several minutes.

> Do not close the browser or interrupt the process unnecessarily.

Once the rebuild completes, the Codespace becomes available again.

## 28. Verify Terraform

Open a new terminal.

Run:

```bash
terraform version
```

Expected output:

```text
Terraform v1.x.x
```

The exact version depends on the feature/version selected.

## 29. Verify AWS CLI

Run:

```bash
aws --version
```

Expected output will be similar to:

```text
aws-cli/2.x.x
```

The exact version depends on the current feature version.

## 30. Verify Git

Run:

```bash
git --version
```

Expected output:

```text
git version 2.x.x
```

## 31. Final Codespaces Verification

Run:

```bash
terraform version
aws --version
git --version
```

Expected environment:

```text
Terraform  ✓
AWS CLI    ✓
Git        ✓
VS Code    ✓
```

The Codespace is now ready for Terraform development.

## 32. Complete Codespaces Setup Flow

The complete process is:

```text
GitHub Repository
       ↓
┌─────────────────────────┐
│ Fork Repository         │
│ OR                      │
│ Use Existing Repository │
└─────────────────────────┘
       ↓
     Code
       ↓
   Codespaces
       ↓
Create Codespace
       ↓
Codespace Opens
       ↓
Open Terminal
       ↓
Check Terraform / AWS CLI
       ↓
Ctrl + Shift + P
       ↓
Codespaces: Add Dev Container Configuration Files
       ↓
Modify Your Active Configuration
       ↓
Search Terraform
       ↓
Select Terraform
       ↓
Click OK
       ↓
Ctrl + Shift + P
       ↓
Codespaces: Add Dev Container Configuration Files
       ↓
Modify Your Active Configuration
       ↓
Search AWS CLI
       ↓
Select AWS CLI
       ↓
Click OK
       ↓
Rebuild Now
       ↓
Wait for Rebuild
       ↓
terraform version
       ↓
aws --version
       ↓
git --version
       ↓
READY
```

## 33. Visual Codespaces Architecture

```text
                    GitHub Repository
                           │
                ┌──────────┴──────────┐
                ↓                     ↓
         Fork Repository      Existing Repository
                │                     │
                └──────────┬──────────┘
                           ↓
                       Code Button
                           ↓
                       Codespaces
                           ↓
                    Create Codespace
                           ↓
                      VS Code Opens
                           ↓
          Add Dev Container Configuration Files
                           ↓
               Modify Active Configuration
                           ↓
                       Terraform
                           ↓
                          OK
                           ↓
          Add Dev Container Configuration Files
                           ↓
               Modify Active Configuration
                           ↓
                        AWS CLI
                           ↓
                          OK
                           ↓
                      Rebuild Now
                           ↓
                 Development Container
                           ↓
              ┌────────────┴────────────┐
              ↓                         ↓
     Terraform Installed        AWS CLI Installed
              │                         │
              └────────────┬────────────┘
                           ↓
                    Verify Versions
                           ↓
                         READY
```

## 34. Fork vs Existing Repository

This distinction is important.

### 34.1 Following Someone Else's Repository

Use:

```text
Original Repository
       ↓
     Fork
       ↓
Your Repository
       ↓
   Codespace
```

This gives us our own copy.

### 34.2 Working on Our Own Repository

For example:

```text
Terraform-Guide
```

Use:

```text
Terraform-Guide
       ↓
     Code
       ↓
   Codespaces
       ↓
Create Codespace
```

There is no need to fork our own repository.

## 35. Why We Use `devcontainer.json`

The `devcontainer.json` file defines the development environment.

Conceptually:

```text
devcontainer.json
        ↓
Development Environment Definition
        ↓
Tools
Features
Extensions
Configuration
```

This provides a reproducible environment.

For example:

```text
Developer A
     ↓
 Codespace
     ↓
Terraform + AWS CLI

Developer B
     ↓
 Codespace
     ↓
Terraform + AWS CLI
```

Both developers can work with a consistently configured environment.

> GitHub documents `devcontainer.json` as the main configuration mechanism for Dev Containers. ([GitHub Docs](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers))

## 36. Reopening an Existing Codespace

After the initial configuration, we do not need to repeat the entire setup every time.

We can open an existing Codespace:

```text
GitHub Repository
       ↓
     Code
       ↓
   Codespaces
       ↓
Existing Codespace
```

The configured development environment can then be reopened.

## 37. Important Rebuild Concept

Remember this rule:

```text
Modify devcontainer.json
          ↓
Configuration Changed
          ↓
Rebuild Container
          ↓
Configuration Applied
```

> Simply editing `devcontainer.json` does not automatically modify the already-running container.

The container must be rebuilt for the configuration changes to take effect. ([GitHub Docs](https://docs.github.com/en/codespaces/reference/using-the-vs-code-command-palette-in-codespaces))

### 38. Repository Files During Rebuild

The Terraform project is stored under the Codespace workspace, typically:

```text
/workspaces/
```

Files inside the workspace are preserved during a container rebuild.

Therefore, our repository files such as:

```text
main.tf
README.md
```

remain available after the rebuild. ([GitHub Docs](https://docs.github.com/en/codespaces/developing-in-a-codespace/rebuilding-the-container-in-a-codespace))

## 39. Terraform Project Inside Codespaces

Once the Codespace is ready, our repository may look like:

```text
Terraform-Guide
│
├── .devcontainer
│   └── devcontainer.json
│
├── 01-getting-started
│   └── project-ec2-instance
│       ├── main.tf
│       └── README.md
│
└── README.md
```

We can navigate to the project:

```bash
cd 01-getting-started/project-ec2-instance
```

Then initialize Terraform:

```bash
terraform init
```

Followed by:

```bash
terraform validate
terraform plan
terraform apply
```

`terraform init` initializes the working directory and installs required provider plugins/modules; it prepares the configuration for subsequent Terraform operations. ([HashiCorp Developer](https://developer.hashicorp.com/terraform/cli/init))

## 40. Configure AWS Authentication

Installing AWS CLI does **not** automatically authenticate us to AWS.

After installing the AWS CLI, configure the credentials using an approved authentication method.

For a beginner environment, one common approach is:

```bash
aws configure
```

We can then verify the current AWS identity:

```bash
aws sts get-caller-identity
```

If successful, the AWS CLI can communicate with AWS using the configured credentials.

> For production environments, organizations should prefer appropriate identity mechanisms such as IAM roles, federation, or temporary credentials rather than long-lived access keys.

## 41. Important Security Rules

Never place credentials inside:

```text
main.tf
devcontainer.json
README.md
GitHub commits
Screenshots
```

Never commit:

```text
AWS Access Key
AWS Secret Access Key
Private SSH Key
Passwords
Tokens
API Keys
```

Never share AWS credentials in:

```text
GitHub
Slack
Email
Screenshots
Chat
Public repositories
```

> For professional environments, use temporary credentials, IAM roles, federation, or another organization-approved authentication mechanism.

## 42. Codespaces Usage and Billing

Codespaces availability and included usage depend on the current GitHub account, plan, organization configuration, and machine type.

Therefore, we should **not hard-code a statement such as "GitHub Codespaces provides 60 free hours every month" into this guide as a permanent rule**.

Instead:

> Before using Codespaces extensively, check the current Codespaces usage and billing information for the GitHub account being used.

This prevents the documentation from becoming outdated if GitHub changes its pricing or included usage.

## 43. Codespaces Troubleshooting

### 43.1 Terraform Command Not Found

Run:

```bash
terraform version
```

If Terraform is unavailable:

```text
Check devcontainer.json
        ↓
Confirm Terraform Feature
        ↓
Rebuild Container
        ↓
Open New Terminal
        ↓
terraform version
```

### 43.2 AWS CLI Command Not Found

Run:

```bash
aws --version
```

If AWS CLI is unavailable:

```text
Check devcontainer.json
        ↓
Confirm AWS CLI Feature
        ↓
Rebuild Container
        ↓
Open New Terminal
        ↓
aws --version
```

### 43.3 "Rebuild Now" Is Not Visible

Open:

```text
Ctrl + Shift + P
```

Search:

```text
Rebuild
```

Select:

```text
Codespaces: Rebuild Container
```

Then confirm the rebuild. ([GitHub Docs](https://docs.github.com/en/codespaces/reference/using-the-vs-code-command-palette-in-codespaces))

### 43.4 Container Rebuild Fails

If the Dev Container configuration contains an error, the Codespace can enter recovery mode.

Use:

```text
View Creation Log
```

Review the error.

Then:

```text
Fix devcontainer.json
        ↓
Save
        ↓
Rebuild Container
```

GitHub documents the creation logs and recovery workflow for Dev Container failures. ([GitHub Docs](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers))

## 44. Recommended Development Environment

For this Terraform learning series, our recommended environment is:

```text
Visual Studio Code
        +
Terraform CLI
        +
AWS CLI
        +
Git
        +
HashiCorp Terraform Extension
```

For local development:

```text
Laptop
   ↓
VS Code
   ↓
Terraform CLI
   ↓
AWS CLI
   ↓
AWS
```

For restricted environments:

```text
Laptop / Browser
       ↓
GitHub
       ↓
Codespaces
       ↓
Dev Container
       ↓
Terraform CLI
       ↓
AWS CLI
       ↓
AWS
```

## 45. Installation Verification Checklist

### Local Environment

Run:

```bash
terraform version
aws --version
git --version
code --version
```

Then verify that the Terraform extension is installed in VS Code.

Expected:

```text
Terraform  ✓
AWS CLI    ✓
Git        ✓
VS Code    ✓
Terraform  ✓
Extension
```

### Codespaces Environment

Run:

```bash
terraform version
aws --version
git --version
```

Expected:

```text
Terraform  ✓
AWS CLI    ✓
Git        ✓
VS Code    ✓
```

## 46. Common Local Installation Problems

### 46.1 `terraform: command not found`

Possible cause:

```text
Terraform is not in PATH
```

Resolution:

```text
Add Terraform installation directory to PATH
        ↓
Close terminal
        ↓
Open new terminal
        ↓
terraform version
```

### 46.2 Old Terminal Session

Environment variables may not be refreshed in an existing terminal.

Solution:

```text
Close terminal
       ↓
Open new terminal
       ↓
terraform version
```

### 46.3 Incorrect Architecture

Make sure the downloaded Terraform package matches the system architecture.

For example:

```text
Windows AMD64
macOS ARM64
Linux AMD64
```

## 47. Installation Outcome

At the end of this section, we should have a working development environment.

### Local Environment

```text
Terraform
   ✓ Installed

AWS CLI
   ✓ Installed

Git
   ✓ Installed

VS Code
   ✓ Installed

Terraform Extension
   ✓ Installed
```

### GitHub Codespaces

```text
GitHub Repository
       ✓

Codespace
       ✓

Dev Container
       ✓

Terraform
       ✓

AWS CLI
       ✓

Git
       ✓

VS Code Environment
       ✓
```

We are now ready to move to the next section and configure Terraform for AWS.

## 48. Key Takeaways

We learned:

1. Terraform can be installed locally on Windows, Linux, and macOS.
2. Git, VS Code, and the Terraform extension provide a professional development environment.
3. GitHub Codespaces provides an alternative when local installation is restricted.
4. We can either **fork an external repository** or use **our existing repository**.
5. A Codespace uses a development container running on a virtual machine.
6. `devcontainer.json` defines the development environment.
7. We can add Terraform using a Dev Container Feature.
8. We can add AWS CLI using the AWS CLI Dev Container Feature.
9. After changing the Dev Container configuration, we must **Rebuild Now**.
10. We can alternatively use **Codespaces: Rebuild Container** from the Command Palette.
11. Repository files in the workspace are preserved during a container rebuild.
12. AWS authentication is a separate step from installing Terraform and AWS CLI.
13. We should never commit or expose AWS credentials.

The result is a reproducible Terraform development environment suitable for both learning and professional infrastructure development.

## Official References

* [HashiCorp — Install Terraform](https://developer.hashicorp.com/terraform/install)
* [HashiCorp — Install Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* [GitHub — Introduction to Dev Containers](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers)
* [GitHub — Adding Features to a devcontainer.json File](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/configuring-dev-containers/adding-features-to-a-devcontainer-file)
* [GitHub — Rebuilding the Container in a Codespace](https://docs.github.com/en/codespaces/developing-in-a-codespace/rebuilding-the-container-in-a-codespace)
* [Dev Container Features — AWS CLI](https://github.com/devcontainers/features/tree/main/src/aws-cli)
