locals {
  # Normalize the project name for consistent resource naming.
  normalized_project_name = replace(
    lower(trimspace(var.project_name)),
    " ",
    "-"
  )

  # Normalize the environment value.
  normalized_environment = lower(trimspace(var.environment))

  # Generate a reusable resource name prefix.
  name_prefix = format(
    "%s-%s",
    local.normalized_project_name,
    local.normalized_environment
  )

  # Define environment-specific EC2 instance types.
  instance_types = {
    dev     = "t3.micro"
    staging = "t3.small"
    prod    = "t3.large"
  }

  # Select the instance type based on the environment.
  selected_instance_type = lookup(
    local.instance_types,
    local.normalized_environment,
    var.instance_type
  )

  # Merge user-defined tags with standard project tags.
  common_tags = merge(
    var.common_tags,
    {
      Project     = local.normalized_project_name
      Environment = local.normalized_environment
      ManagedBy   = "Terraform"
    }
  )
}

# AWS - Primary Region

resource "aws_instance" "east" {
  provider = aws

  ami           = var.aws_ami_id
  instance_type = local.selected_instance_type

  # Explicitly request a public IPv4 address so the public IP
  # output documented in the README is available.
  associate_public_ip_address = true

  tags = merge(
    local.common_tags,
    {
      Name   = format("%s-east-ec2", local.name_prefix)
      Region = var.aws_region
    }
  )
}

# AWS - Secondary Region

resource "aws_instance" "west" {
  provider = aws.west

  ami           = var.aws_secondary_ami_id
  instance_type = local.selected_instance_type

  # Explicitly request a public IPv4 address so the public IP
  # output documented in the README is available.
  associate_public_ip_address = true

  tags = merge(
    local.common_tags,
    {
      Name   = format("%s-west-ec2", local.name_prefix)
      Region = var.aws_secondary_region
    }
  )
}

# Azure

resource "azurerm_resource_group" "this" {
  count = var.deploy_azure ? 1 : 0

  name     = format("%s-rg", local.name_prefix)
  location = var.azure_location

  tags = local.common_tags
}