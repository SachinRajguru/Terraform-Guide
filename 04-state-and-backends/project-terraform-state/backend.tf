terraform {
  backend "s3" {
    # Existing S3 bucket used to store Terraform State.
    bucket = "REPLACE-WITH-YOUR-UNIQUE-STATE-BUCKET"

    # S3 object path where Terraform State is stored.
    key = "terraform-state-demo/terraform.tfstate"

    # AWS region containing the S3 bucket.
    region = "us-east-1"

    # Enable native S3 State locking.
    use_lockfile = true

    # Enable server-side encryption.
    encrypt = true
  }
}