terraform {
  # Terraform version constraint for this project.
  required_version = "~> 1.15.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"

      # Allow compatible AWS provider 6.x releases.
      version = "~> 6.0"
    }
  }
}