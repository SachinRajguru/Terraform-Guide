# Primary-region EC2 instance.

resource "aws_instance" "primary" {
  ami           = var.primary_ami_id
  instance_type = var.instance_type

  tags = {
    Name = "${var.project_name}-primary"
  }
}

# Secondary-region EC2 instance.
#
# The conditional expression controls whether this resource exists.

resource "aws_instance" "secondary" {
  count = var.create_secondary_instance ? 1 : 0

  provider = aws.secondary

  ami           = var.secondary_ami_id
  instance_type = var.instance_type

  tags = {
    Name = "${var.project_name}-secondary"
  }
}