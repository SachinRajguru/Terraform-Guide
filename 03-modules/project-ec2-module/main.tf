# Configure the AWS provider for the root module.
provider "aws" {
  region = var.aws_region
}

# Call the reusable local EC2 child module.
module "ec2" {
  source = "./modules/ec2"

  ami_id        = var.ami_id
  instance_type = var.instance_type
  instance_name = var.instance_name
  environment   = var.environment
}