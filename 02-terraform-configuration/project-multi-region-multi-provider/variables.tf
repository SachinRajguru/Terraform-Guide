variable "aws_region" {
  description = "Primary AWS region where the first EC2 instance will be deployed."
  type        = string
  default     = "us-east-1"
}

variable "aws_secondary_region" {
  description = "Secondary AWS region where the second EC2 instance will be deployed."
  type        = string
  default     = "us-west-2"
}

variable "azure_location" {
  description = "Azure region where the resource group will be created."
  type        = string
  default     = "East US"
}

variable "azure_subscription_id" {
  description = "Azure subscription ID used by the AzureRM provider."
  type        = string
}

variable "project_name" {
  description = "Base name used when generating resource names."
  type        = string
  default     = "terraform-demo"

  validation {
    condition     = trimspace(var.project_name) != ""
    error_message = "project_name must not be empty."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"

  validation {
    condition = contains(
      ["dev", "staging", "prod"],
      lower(trimspace(var.environment))
    )

    error_message = "environment must be one of: dev, staging, or prod."
  }
}

variable "aws_ami_id" {
  description = "AMI ID for the EC2 instance in the primary AWS region."
  type        = string
}

variable "aws_secondary_ami_id" {
  description = "AMI ID for the EC2 instance in the secondary AWS region."
  type        = string
}

variable "instance_type" {
  description = "Fallback EC2 instance type used when an environment-specific type is not selected."
  type        = string
  default     = "t3.micro"
}

variable "deploy_azure" {
  description = "Controls whether the Azure resource group is deployed."
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Additional tags that will be merged with the standard Terraform-managed tags."
  type        = map(string)
  default     = {}
}