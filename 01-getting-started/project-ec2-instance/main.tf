# Declare the AWS provider dependency
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Provision an EC2 instance
resource "aws_instance" "terraform_demo" {
  ami           = "REPLACE_WITH_VALID_AMI_ID"
  instance_type = "t3.micro"

  subnet_id = "REPLACE_WITH_VALID_SUBNET_ID"
  key_name  = "REPLACE_WITH_EXISTING_KEY_PAIR_NAME"

  tags = {
    Name        = "terraform-ec2-instance"
    Environment = "learning"
    ManagedBy   = "Terraform"
  }
}