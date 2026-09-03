provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "west"
  region = var.aws_secondary_region
}

provider "azurerm" {
  features {}

  subscription_id = var.azure_subscription_id
}