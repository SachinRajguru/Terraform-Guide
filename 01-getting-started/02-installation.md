
## 02 — Terraform Installation

### Installing Terraform on Windows, Linux, macOS and GitHub Codespaces

> **Path:** `Terraform-Guide/01-getting-started/`

## Table of Contents

1. [Introduction](#1-introduction)
2. [Local Terraform Installation](#2-local-terraform-installation)
   * [2.1 Identify the Operating System and Architecture](#21-identify-the-operating-system-and-architecture)
3. [Installing Terraform on Windows](#3-installing-terraform-on-windows)
   * [3.1 Download Terraform](#31-download-terraform)
   * [3.2 Extract Terraform](#32-extract-terraform)
   * [3.3 Configure PATH](#33-configure-path)
   * [3.4 Verify Terraform](#34-verify-terraform)
   * [3.5 Windows Package Manager Options](#35-windows-package-manager-options)
   * [3.6 Recommended Windows Terminals](#36-recommended-windows-terminals)
4. [Installing Terraform on Linux](#4-installing-terraform-on-linux)
   * [4.1 Ubuntu/Debian Installation](#41-ubuntudebian-installation)
   * [4.2 Other Linux Distributions](#42-other-linux-distributions)
5. [Installing Terraform on macOS](#5-installing-terraform-on-macos)
6. [Installing Git](#6-installing-git)
7. [Installing Visual Studio Code](#7-installing-visual-studio-code)
8. [Installing the Terraform VS Code Extension](#8-installing-the-terraform-vs-code-extension)
9. [GitHub Codespaces](#9-github-codespaces)
   * [9.1 Why GitHub Codespaces?](#91-why-github-codespaces)
10. [Fork or Use an Existing Repository](#10-fork-or-use-an-existing-repository)
    * [10.1 Scenario A — Following Someone Else's Repository](#101-scenario-a--following-someone-elses-repository)
    * [10.2 Scenario B — Using Our Existing Repository](#102-scenario-b--using-our-existing-repository)
11. [Create a GitHub Codespace](#11-create-a-github-codespace)
12. [Wait for Codespace Creation](#12-wait-for-codespace-creation)
13. [Open the Codespace](#13-open-the-codespace)
14. [Open the Terminal](#14-open-the-terminal)
15. [Configure the Dev Container](#15-configure-the-dev-container)
16. [Open the Command Palette](#16-open-the-command-palette)
17. [Modify the Active Configuration](#17-modify-the-active-configuration)
18. [Add Terraform](#18-add-terraform)
19. [Save the Terraform Configuration](#19-save-the-terraform-configuration)
20. [Add AWS CLI](#20-add-aws-cli)
21. [Select the AWS CLI Feature](#21-select-the-aws-cli-feature)
22. [Save the AWS CLI Configuration](#22-save-the-aws-cli-configuration)
23. [Important — Configuration Has Changed](#23-important--configuration-has-changed)
24. [Rebuild the Container](#24-rebuild-the-container)
25. [Alternative — Rebuild Using the Command Palette](#25-alternative--rebuild-using-the-command-palette)
26. [What Happens During the Rebuild?](#26-what-happens-during-the-rebuild)
27. [Wait for the Rebuild](#27-wait-for-the-rebuild)
28. [Verify Terraform](#28-verify-terraform)
29. [Verify AWS CLI](#29-verify-aws-cli)
30. [Verify Git](#30-verify-git)
31. [Final Codespaces Verification](#31-final-codespaces-verification)
32. [Complete Codespaces Setup Flow](#32-complete-codespaces-setup-flow)
33. [Visual Codespaces Architecture](#33-visual-codespaces-architecture)
34. [Fork vs. Existing Repository](#34-fork-vs-existing-repository)
35. [Why We Use `devcontainer.json`](#35-why-we-use-devcontainerjson)
36. [Reopening an Existing Codespace](#36-reopening-an-existing-codespace)
37. [Important Rebuild Concept](#37-important-rebuild-concept)
38. [Repository Files During a Rebuild](#38-repository-files-during-a-rebuild)
39. [Terraform Project Inside Codespaces](#39-terraform-project-inside-codespaces)
40. [Configure AWS Authentication](#40-configure-aws-authentication)
41. [Important Security Rules](#41-important-security-rules)
42. [Codespaces Usage and Billing](#42-codespaces-usage-and-billing)
43. [Codespaces Troubleshooting](#43-codespaces-troubleshooting)
    * [43.1 `terraform` Command Not Found](#431-terraform-command-not-found)
    * [43.2 AWS CLI Command Not Found](#432-aws-cli-command-not-found)
    * [43.3 Rebuild Option Is Not Visible](#433-rebuild-option-is-not-visible)
    * [43.4 Container Rebuild Fails](#434-container-rebuild-fails)
44. [Recommended Development Environment](#44-recommended-development-environment)
45. [Installation Verification Checklist](#45-installation-verification-checklist)
46. [Common Local Installation Problems](#46-common-local-installation-problems)
    * [46.1 `terraform` Command Not Found](#461-terraform-command-not-found)
    * [46.2 Old Terminal Session](#462-old-terminal-session)
    * [46.3 Incorrect Architecture](#463-incorrect-architecture)
47. [Installation Outcome](#47-installation-outcome)
48. [Key Takeaways](#48-key-takeaways)
49. [Official References](#49-official-references)

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

GitHub Codespaces runs a development container on a virtual machine. The exact infrastructure behind a Codespace is managed by GitHub.

A simplified architecture is:

```text
Laptop / Browser
       ↓
    GitHub
       ↓
 GitHub Codespaces
       ↓
 Virtual Machine
       ↓
Development Container
       ↓
   VS Code
       ↓
Terraform + AWS CLI + Git
```

## 2. Local Terraform Installation

Terraform is distributed for multiple operating systems and CPU architectures.

Before installation, we should identify the operating system and architecture of the machine.

### 2.1 Identify the Operating System and Architecture

We need to identify:

* Operating system
* CPU architecture

Common architectures include:

```text
AMD64 / x86_64
ARM64
```

Examples:

```text
Intel/AMD systems
        ↓
      AMD64
```

```text
Apple Silicon
     ↓
   ARM64
```

The exact architecture depends on the operating system and hardware.

HashiCorp provides Terraform packages for supported operating systems and architectures.

Refer to the official installation documentation:

[HashiCorp — Install Terraform](https://developer.hashicorp.com/terraform/install?utm_source=chatgpt.com)

## 3. Installing Terraform on Windows

There are several ways to install Terraform on Windows.

For learning purposes, we can use the official Terraform ZIP archive or a package manager.

### 3.1 Download Terraform

Terraform can be installed manually from the official HashiCorp distribution.

The Windows package is provided as a ZIP archive containing:

```text
terraform.exe
```

Download the package appropriate for the system architecture.

For example:

```text
Windows
   ↓
AMD64 / ARM64
   ↓
Terraform ZIP
```

Use the official Terraform installation page:

[HashiCorp — Install Terraform](https://developer.hashicorp.com/terraform/install?utm_source=chatgpt.com)

### 3.2 Extract Terraform

Extract the downloaded ZIP archive.

For example:

```text
C:\Terraform\
```

The directory should contain:

```text
C:\Terraform\
└── terraform.exe
```

The important requirement is that the directory containing `terraform.exe` is known and can be added to the system `PATH`.

### 3.3 Configure PATH

Terraform needs to be available from the terminal.

Add the Terraform installation directory to the Windows `PATH`.

For example:

```text
C:\Terraform
```

Conceptually:

```text
C:\Terraform
      ↓
  terraform.exe
      ↓
    PATH
      ↓
Terminal
      ↓
terraform version
```

After modifying `PATH`, close the existing terminal and open a new terminal.

This is important because an already-running terminal may still have the old environment variables.

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

The exact version depends on the version currently installed.

We can also verify where Terraform is being resolved from:

#### PowerShell

```powershell
Get-Command terraform
```

#### Git Bash

```bash
which terraform
```

If Terraform is correctly configured, the command should point to the Terraform executable.

### 3.5 Windows Package Manager Options

Terraform can also be installed using package managers.

For example, if Chocolatey is already installed:

```bash
choco install terraform
```

However, package-manager distribution can be maintained independently from HashiCorp.

For professional environments, we should understand where the package comes from and follow the organization's software-management standards.

The official Terraform binary and installation documentation remain the authoritative references for Terraform installation.

[HashiCorp — Install Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli?utm_source=chatgpt.com)

### 3.6 Recommended Windows Terminals

We can use:

* PowerShell
* Git Bash
* Windows Terminal

For this learning series, **Git Bash** can be convenient because many Unix-style commands are available.

For example:

```bash
terraform version
```

The Terraform commands themselves are the same regardless of whether we use PowerShell, Git Bash, or another supported terminal.

## 4. Installing Terraform on Linux

Terraform installation depends on the Linux distribution.

HashiCorp provides installation instructions for distributions such as:

* Ubuntu
* Debian
* RHEL
* Fedora
* Amazon Linux
* Other supported Linux distributions

For Ubuntu/Debian systems, HashiCorp provides an official APT repository.

[HashiCorp — Install Terraform](https://developer.hashicorp.com/terraform/install?utm_source=chatgpt.com)

### 4.1 Ubuntu/Debian Installation

The following example uses the HashiCorp APT repository.

First, update the package index:

```bash
sudo apt-get update
```

Install the required packages:

```bash
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

Update the package index:

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

Example:

```text
Terraform v1.x.x
on linux_amd64
```

For the latest installation commands and supported distributions, always refer to the official HashiCorp documentation.

[HashiCorp — Install Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli?utm_source=chatgpt.com)

### 4.2 Other Linux Distributions

For other Linux distributions, use the appropriate package repository or the official Terraform binary.

Examples include:

```text
RHEL / CentOS
Fedora
Amazon Linux
Ubuntu / Debian
Other supported Linux distributions
```

The exact installation procedure varies by distribution.

Use the official Terraform installation documentation rather than copying an outdated command from an older tutorial.

[HashiCorp — Install Terraform](https://developer.hashicorp.com/terraform/install?utm_source=chatgpt.com)

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

Verify the installation:

```bash
terraform version
```

Example:

```text
Terraform v1.x.x
on darwin_arm64
```

The architecture may instead be `darwin_amd64` on Intel-based Macs.

The exact version depends on the version installed.

Refer to the official Terraform installation documentation for current instructions.

[HashiCorp — Install Terraform](https://developer.hashicorp.com/terraform/install?utm_source=chatgpt.com)

## 6. Installing Git

[Git](https://git-scm.com/install/?utm_source=chatgpt.com) is strongly recommended for Terraform development.

Terraform configurations should normally be maintained in version control.

Git allows us to:

* Track configuration changes.
* Create branches.
* Review changes.
* Collaborate with other developers.
* Maintain project history.
* Integrate Terraform projects with CI/CD systems.

Verify Git:

```bash
git --version
```

Example:

```text
git version 2.x.x
```

The exact version depends on the installed Git release.

## 7. Installing Visual Studio Code

[Visual Studio Code](https://code.visualstudio.com/download?utm_source=chatgpt.com) provides a convenient development environment for Terraform.

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

The official Terraform extension improves the Terraform authoring experience.

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

The extension provides capabilities such as:

* Terraform syntax highlighting
* Language support
* Validation support
* Formatting integration
* Code completion
* Terraform-aware editor functionality

After installation, we can open a `.tf` file and verify that VS Code recognizes Terraform syntax.

## 9. GitHub Codespaces

GitHub Codespaces provides a cloud-based development environment.

Instead of installing all development tools directly on our laptop, we can run them inside a Codespace.

Conceptually:

```text
Local Laptop
     ↓
Browser / VS Code
     ↓
GitHub Codespaces
     ↓
Development Container
     ↓
Terraform + AWS CLI + Git
```

### 9.1 Why GitHub Codespaces?

A local installation is not always possible.

For example:

```text
Terraform installation → Restricted
AWS CLI installation  → Restricted
Administrator access  → Unavailable
```

Instead of modifying a restricted corporate laptop, we can use GitHub Codespaces.

Codespaces can be useful when:

* Local software installation is restricted.
* Administrator privileges are unavailable.
* We want a reproducible development environment.
* We want to work from multiple computers.
* We want to isolate development tools from the host machine.
* We want a browser-based development environment.

GitHub uses Dev Containers to define and customize the development environment.

[GitHub — Introduction to Dev Containers](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers?utm_source=chatgpt.com)

## 10. Fork or Use an Existing Repository

Before creating a Codespace, we need a GitHub repository.

There are two common scenarios.

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

Forking creates our own copy of the repository under our GitHub account.

This is useful when we want to:

* Experiment independently.
* Modify files.
* Commit our changes.
* Push changes to our own repository.
* Keep the original repository unchanged.

### 10.2 Scenario B — Using Our Existing Repository

If we already have our own repository, such as:

```text
Terraform-Guide
```

we do **not** need to fork it.

We can directly create a Codespace from our repository:

```text
Terraform-Guide
       ↓
     Code
       ↓
   Codespaces
       ↓
Create Codespace
```

There is no need to fork a repository that we already own and intend to modify.

## 11. Create a GitHub Codespace

Open our repository on GitHub.

For example:

```text
GitHub
   ↓
Terraform-Guide
```

Select:

```text
Code
   ↓
Codespaces
   ↓
Create codespace
```

GitHub may display additional configuration options depending on the repository, organization, and account.

Possible options can include:

* Branch
* Dev Container configuration
* Region
* Machine type

The available options can change over time.

## 12. Wait for Codespace Creation

GitHub performs several operations while creating the Codespace.

Conceptually:

```text
Create Codespace
       ↓
Compute Environment Assigned
       ↓
Storage Assigned
       ↓
Development Container Created
       ↓
Repository Prepared
       ↓
VS Code Connected
       ↓
Codespace Ready
```

The exact provisioning process is managed by GitHub.

## 13. Open the Codespace

Once creation is complete, the browser opens a VS Code-like development environment.

We should see components such as:

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

Check AWS CLI:

```bash
aws --version
```

Check Git:

```bash
git --version
```

Depending on the selected Codespace image and repository configuration, some tools may already be available.

However, for this Terraform Guide, we want to explicitly configure the development environment.

## 15. Configure the Dev Container

> **Important:** The Dev Container configuration determines how the development environment is built.

The configuration is typically stored under:

```text
.devcontainer/
└── devcontainer.json
```

The `devcontainer.json` file can define or reference:

* Base image
* Features
* Extensions
* Environment settings
* Ports
* Commands
* Development-container configuration

GitHub documents Dev Container configuration as the mechanism for customizing Codespaces.

[GitHub — Introduction to Dev Containers](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers?utm_source=chatgpt.com)

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

Search for:

```text
Add Dev Container Configuration Files
```

Select the Codespaces/Dev Container configuration command presented by VS Code.

> **Note:** Command names and wording can change between VS Code and GitHub Codespaces releases. If the exact command is different, search the Command Palette for `Dev Container` or `container configuration`.

## 17. Modify the Active Configuration

Because we are already working inside a Codespace, the workflow can offer:

```text
Modify your active configuration
```

Select this option when available.

This allows us to modify the Dev Container configuration currently used by the Codespace.

GitHub documents adding Dev Container Features through the Dev Container configuration workflow.

[GitHub — Adding Features to a devcontainer.json File](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/configuring-dev-containers/adding-features-to-a-devcontainer-file?utm_source=chatgpt.com)

## 18. Add Terraform

The Feature selection screen should appear.

Search for:

```text
Terraform
```

Select the appropriate Terraform Dev Container Feature.

Conceptually:

```text
Modify Active Configuration
           ↓
         Search
           ↓
       Terraform
           ↓
    Select Feature
```

The Terraform Feature installs Terraform into the development container.

The exact Feature version or identifier can change, so we should use the Feature offered by the current Dev Container catalog rather than hard-coding an outdated version into the learning instructions.

## 19. Save the Terraform Configuration

After selecting the Terraform Feature, save or confirm the configuration.

The configuration should be updated under:

```text
.devcontainer/
└── devcontainer.json
```

Conceptually:

```text
.devcontainer/devcontainer.json
             ↓
     Terraform Feature
             ↓
   Development Container
             ↓
         Terraform
```

We should inspect the resulting `devcontainer.json` before rebuilding if we want to understand exactly what configuration was added.

## 20. Add AWS CLI

We also need AWS CLI for the AWS-based Terraform labs.

Open the Command Palette again:

```text
Ctrl + Shift + P
```

Search for:

```text
Add Dev Container Configuration Files
```

Select the relevant Dev Container configuration command.

Then select:

```text
Modify your active configuration
```

## 21. Select the AWS CLI Feature

Search for:

```text
AWS CLI
```

Select the AWS CLI Dev Container Feature.

A commonly used Dev Container Feature reference is:

```text
ghcr.io/devcontainers/features/aws-cli:1
```

The Dev Container Features project publishes an AWS CLI Feature under this namespace.

[Dev Container Features — AWS CLI](https://github.com/devcontainers/features/tree/main/src/aws-cli?utm_source=chatgpt.com)

> **Important:** Feature references and versions can change. We should use the current Feature reference presented by the Dev Container configuration UI or official Dev Container documentation.

## 22. Save the AWS CLI Configuration

After selecting AWS CLI, save or confirm the configuration.

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

At this point, the configuration describes the tools we want available inside the development container.

## 23. Important — Configuration Has Changed

The configuration has now changed.

However, changing `devcontainer.json` does not mean that the currently running container has immediately been rebuilt with the new configuration.

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

The rebuild causes the development container to be recreated using the updated configuration.

## 24. Rebuild the Container

After changing the configuration, VS Code/Codespaces may display a notification indicating that the Dev Container configuration has changed.

Select:

```text
Rebuild Now
```

The overall flow is:

```text
Terraform Feature
       ↓
Save Configuration
       ↓
AWS CLI Feature
       ↓
Save Configuration
       ↓
Configuration Changed
       ↓
Rebuild Now
```

GitHub documents rebuilding Codespace containers after Dev Container configuration changes.

[GitHub — Rebuilding the Container in a Codespace](https://docs.github.com/en/codespaces/developing-in-a-codespace/rebuilding-the-container-in-a-codespace?utm_source=chatgpt.com)

## 25. Alternative — Rebuild Using the Command Palette

If the **Rebuild Now** notification does not appear, we can rebuild manually.

Open:

```text
Ctrl + Shift + P
```

Search for:

```text
Rebuild
```

Select the Codespaces/Dev Container rebuild command presented by the environment.

In many current Codespaces environments, this appears as:

```text
Codespaces: Rebuild Container
```

Then confirm the rebuild.

> **Note:** Command names can change between VS Code and Codespaces releases. Search for `Rebuild Container` if the exact command differs.

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

The configured Features are applied during the container build.

Therefore:

```text
Terraform Feature
        ↓
Terraform installed
```

and:

```text
AWS CLI Feature
        ↓
AWS CLI installed
```

## 27. Wait for the Rebuild

The rebuild can take several minutes depending on:

* Codespace machine type
* Network conditions
* Feature downloads
* Container image
* Repository configuration

We should allow the rebuild to complete before running verification commands.

Once the rebuild finishes, the Codespace becomes available again.

## 28. Verify Terraform

Open a new terminal.

Run:

```bash
terraform version
```

Example:

```text
Terraform v1.x.x
```

The exact version depends on the Terraform Feature and configuration selected.

## 29. Verify AWS CLI

Run:

```bash
aws --version
```

Example:

```text
aws-cli/2.x.x
```

The exact version depends on the Feature version and current release.

## 30. Verify Git

Run:

```bash
git --version
```

Example:

```text
git version 2.x.x
```

## 31. Final Codespaces Verification

Run all three commands:

```bash
terraform version
aws --version
git --version
```

Expected environment:

```text
Terraform    ✓
AWS CLI      ✓
Git          ✓
VS Code      ✓
```

The Codespace is now ready for Terraform development.

## 32. Complete Codespaces Setup Flow

The complete setup process is:

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
Check Terraform / AWS CLI / Git
       ↓
Command Palette
       ↓
Dev Container Configuration
       ↓
Modify Active Configuration
       ↓
Add Terraform Feature
       ↓
Save Configuration
       ↓
Add AWS CLI Feature
       ↓
Save Configuration
       ↓
Configuration Changed
       ↓
Rebuild Container
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
             Dev Container Configuration
                           ↓
                  Modify Active Config
                           ↓
                 ┌─────────┴─────────┐
                 ↓                   ↓
             Terraform            AWS CLI
              Feature            Feature
                 │                   │
                 └─────────┬─────────┘
                           ↓
                    Rebuild Container
                           ↓
                 Development Container
                           ↓
              ┌────────────┴────────────┐
              ↓                         ↓
       Terraform Installed       AWS CLI Installed
              │                         │
              └────────────┬────────────┘
                           ↓
                    Verify Versions
                           ↓
                         READY
```

## 34. Fork vs. Existing Repository

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

We can then:

* Modify files.
* Commit changes.
* Push changes.
* Experiment independently.

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

The `devcontainer.json` file defines the development-container configuration.

Conceptually:

```text
devcontainer.json
        ↓
Development Environment Definition
        ↓
┌───────────────────────────┐
│ Base Image                │
│ Features                  │
│ Extensions                │
│ Configuration             │
│ Development Tools         │
└───────────────────────────┘
```

This helps us create a reproducible development environment.

For example:

```text
Developer A
     ↓
 Codespace
     ↓
Terraform + AWS CLI
```

and:

```text
Developer B
     ↓
 Codespace
     ↓
Terraform + AWS CLI
```

Both developers can work with a consistently defined environment.

GitHub documents `devcontainer.json` as a primary configuration mechanism for Dev Containers.

[GitHub — Introduction to Dev Containers](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers?utm_source=chatgpt.com)

## 36. Reopening an Existing Codespace

After the initial configuration, we do not need to repeat the entire setup every time.

We can reopen an existing Codespace:

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

If the Codespace was stopped, GitHub can start it again without requiring us to recreate the development environment from scratch.

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

Simply editing `devcontainer.json` does not mean that the already-running container has been rebuilt.

A rebuild is required when we need configuration changes to be applied to the development container.

## 38. Repository Files During a Rebuild

The repository workspace is typically mounted under:

```text
/workspaces/
```

For example:

```text
/workspaces/
└── Terraform-Guide/
```

Repository files stored in the workspace are designed to remain available when the development container is rebuilt.

For example:

```text
main.tf
README.md
variables.tf
outputs.tf
```

remain part of the repository workspace.

This is different from data stored only inside the disposable container filesystem.

Therefore, we should keep important project files in the repository workspace and commit them to Git.

[GitHub — Rebuilding the Container in a Codespace](https://docs.github.com/en/codespaces/developing-in-a-codespace/rebuilding-the-container-in-a-codespace?utm_source=chatgpt.com)

## 39. Terraform Project Inside Codespaces

Once the Codespace is ready, our repository may look like:

```text
Terraform-Guide/
│
├── .devcontainer/
│   └── devcontainer.json
│
├── 01-getting-started/
│   ├── 01-fundamentals.md
│   ├── 02-installation.md
│   └── project-ec2-instance/
│       ├── main.tf
│       └── README.md
│
└── README.md
```

We can navigate to the Terraform project:

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
```

```bash
terraform plan
```

```bash
terraform apply
```

The commands above assume that the project configuration and AWS authentication have already been configured appropriately.

`terraform init` initializes a Terraform working directory and prepares the required providers, modules, and related working-directory metadata.

[Terraform — `terraform init`](https://developer.hashicorp.com/terraform/cli/init?utm_source=chatgpt.com)

## 40. Configure AWS Authentication

Installing AWS CLI does **not** automatically authenticate us to AWS.

We need to configure an approved AWS authentication method.

For a beginner environment, one possible method is:

```bash
aws configure
```

This can configure credentials and a default region.

After configuration, verify the current AWS identity:

```bash
aws sts get-caller-identity
```

If authentication is configured correctly, AWS returns information identifying the principal making the request.

Example structure:

```json
{
  "UserId": "...",
  "Account": "...",
  "Arn": "..."
}
```

> **Important:** The values returned by AWS should be treated as sensitive information where appropriate.

For production environments, organizations should generally prefer appropriate identity mechanisms such as:

* IAM roles
* Federated identity
* Temporary credentials
* IAM Identity Center
* Workload identity
* Organization-approved credential mechanisms

Long-lived access keys should not be embedded into Terraform configuration files or committed to Git.

## 41. Important Security Rules

Never place credentials inside:

```text
main.tf
variables.tf
devcontainer.json
README.md
Git commits
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

Never share credentials through:

```text
GitHub
Slack
Email
Screenshots
Chat
Public repositories
```

A common security failure looks like:

```text
AWS Credential
      ↓
Terraform File
      ↓
Git Commit
      ↓
GitHub Repository
      ↓
Credential Exposure
```

A better approach is:

```text
Approved Authentication Method
          ↓
AWS CLI / Environment
          ↓
Temporary or Managed Credentials
          ↓
Terraform
```

If credentials are accidentally committed, simply deleting the file in a later commit is not sufficient. The exposed credential should be considered compromised and rotated or revoked according to the organization's security process.

## 42. Codespaces Usage and Billing

Codespaces availability and included usage depend on the current:

* GitHub account
* GitHub plan
* Organization configuration
* Machine type
* Usage

Therefore, we should **not hard-code a permanent statement such as "GitHub Codespaces provides 60 free hours every month"** into this guide.

Instead:

> Before using Codespaces extensively, check the current Codespaces usage and billing information for the GitHub account or organization being used.

This prevents the documentation from becoming outdated when GitHub changes pricing, included usage, or account policies.

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

Also inspect the container configuration to confirm that the Terraform Feature was actually added.

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

Also verify that the AWS CLI Feature was successfully installed during the container rebuild.

### 43.3 Rebuild Option Is Not Visible

If the **Rebuild Now** notification is not visible:

Open:

```text
Ctrl + Shift + P
```

Search:

```text
Rebuild Container
```

Select the appropriate Codespaces/Dev Container rebuild command presented by VS Code.

If the command name differs, search for:

```text
Rebuild
```

or:

```text
Dev Container
```

### 43.4 Container Rebuild Fails

If the Dev Container configuration contains an error, the Codespace may fail to rebuild or enter a recovery state.

Review the available creation or build logs.

Conceptually:

```text
Container Rebuild Fails
        ↓
Review Creation / Build Logs
        ↓
Identify Configuration Error
        ↓
Fix devcontainer.json
        ↓
Save
        ↓
Rebuild Container
```

Common causes include:

* Invalid JSON.
* Invalid Feature reference.
* Incorrect Feature configuration.
* Network or image download failure.
* Unsupported configuration.
* Temporary service issues.

GitHub provides troubleshooting guidance for Dev Container configuration and Codespaces.

[GitHub — Introduction to Dev Containers](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers?utm_source=chatgpt.com)

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

The important principle is that Terraform itself runs from the environment where the Terraform CLI is installed.

## 45. Installation Verification Checklist

### Local Environment

Run:

```bash
terraform version
aws --version
git --version
code --version
```

Then verify that the HashiCorp Terraform extension is installed in VS Code.

Expected:

```text
Terraform CLI             ✓
AWS CLI                   ✓
Git                       ✓
VS Code                   ✓
Terraform Extension       ✓
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
Terraform CLI             ✓
AWS CLI                   ✓
Git                       ✓
VS Code Environment       ✓
```

We should also verify AWS authentication separately before running Terraform against AWS:

```bash
aws sts get-caller-identity
```

### 46. Common Local Installation Problems

### 46.1 `terraform` Command Not Found

Possible cause:

```text
Terraform is not installed
OR
Terraform is not in PATH
```

Resolution:

```text
Verify Terraform Installation
        ↓
Verify Terraform Directory
        ↓
Add Directory to PATH
        ↓
Close Terminal
        ↓
Open New Terminal
        ↓
terraform version
```

On Windows, we can also check:

```powershell
Get-Command terraform
```

On Linux/macOS:

```bash
which terraform
```

### 46.2 Old Terminal Session

Environment variables may not be refreshed in an existing terminal.

Solution:

```text
Close Terminal
       ↓
Open New Terminal
       ↓
terraform version
```

If the command still fails, verify the `PATH` configuration.

### 46.3 Incorrect Architecture

Make sure the downloaded Terraform package matches the system architecture.

Examples:

```text
Windows AMD64
Windows ARM64

Linux AMD64
Linux ARM64

macOS AMD64
macOS ARM64
```

The architecture reported by Terraform should correspond to the environment in which it is running.

For example:

```text
Terraform v1.x.x
on darwin_arm64
```

indicates Terraform is running on an ARM64 macOS environment.

## 47. Installation Outcome

At the end of this section, we should have a working Terraform development environment.

### Local Environment

```text
Terraform CLI
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

We should also be able to verify the AWS identity when AWS authentication has been configured:

```bash
aws sts get-caller-identity
```

We are now ready to move to the next section and begin working with Terraform configurations and AWS infrastructure.

## 48. Key Takeaways

We learned:

1. Terraform can be installed locally on Windows, Linux, and macOS.
2. We should select the Terraform package appropriate for our operating system and CPU architecture.
3. Git, VS Code, and the Terraform extension provide a professional Terraform development environment.
4. GitHub Codespaces provides an alternative cloud-based development environment.
5. We can either **fork an external repository** or use **our existing repository**.
6. A Codespace uses a development container running on cloud infrastructure.
7. `devcontainer.json` defines the Dev Container configuration.
8. Dev Container Features can be used to add development tools such as Terraform and AWS CLI.
9. After changing the Dev Container configuration, we should **rebuild the container** so the configuration is applied.
10. We can use the Command Palette to rebuild the container if the **Rebuild Now** notification is unavailable.
11. Repository files in the workspace remain part of the repository when the container is rebuilt.
12. AWS authentication is a separate step from installing Terraform and AWS CLI.
13. `aws sts get-caller-identity` can be used to verify the authenticated AWS identity.
14. We should never commit or expose AWS credentials.
15. Codespaces usage and billing can change, so current GitHub account and pricing information should be checked before extensive use.

The result is a reproducible Terraform development environment suitable for learning, labs, collaboration, and professional infrastructure development.

## 49. Official References

* [HashiCorp — Install Terraform](https://developer.hashicorp.com/terraform/install?utm_source=chatgpt.com)
* [HashiCorp — Install Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli?utm_source=chatgpt.com)
* [Terraform CLI — `terraform init`](https://developer.hashicorp.com/terraform/cli/init?utm_source=chatgpt.com)
* [GitHub — Introduction to Dev Containers](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers?utm_source=chatgpt.com)
* [GitHub — Adding Features to a `devcontainer.json` File](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/configuring-dev-containers/adding-features-to-a-devcontainer-file?utm_source=chatgpt.com)
* [GitHub — Rebuilding the Container in a Codespace](https://docs.github.com/en/codespaces/developing-in-a-codespace/rebuilding-the-container-in-a-codespace?utm_source=chatgpt.com)
* [Dev Container Features — AWS CLI](https://github.com/devcontainers/features/tree/main/src/aws-cli?utm_source=chatgpt.com)
* [Git](https://git-scm.com/install/?utm_source=chatgpt.com)
* [Visual Studio Code](https://code.visualstudio.com/download?utm_source=chatgpt.com)
