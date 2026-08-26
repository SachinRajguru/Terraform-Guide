variable "project_name" {
  type        = string
  description = "Name of the Terraform project."
  default     = "terraform-advanced-configuration"
}

variable "environment" {
  type        = string
  description = "Deployment environment."
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "primary_region" {
  type        = string
  description = "Primary AWS region."
  default     = "us-east-1"
}

variable "secondary_region" {
  type        = string
  description = "Secondary AWS region."
  default     = "us-west-2"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type."
  default     = "t3.micro"
}

variable "primary_ami_id" {
  type        = string
  description = "AMI ID for the primary AWS region."
}

variable "secondary_ami_id" {
  type        = string
  description = "AMI ID for the secondary AWS region."
}

variable "create_secondary_instance" {
  type        = bool
  description = "Whether to create the secondary-region EC2 instance."
  default     = true
}