variable "aws_region" {
  description = "AWS region where the lab resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name used to identify the Terraform State lab resources."
  type        = string
  default     = "terraform-state-demo"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "ami_id" {
  description = "AMI ID used for the EC2 demonstration instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}