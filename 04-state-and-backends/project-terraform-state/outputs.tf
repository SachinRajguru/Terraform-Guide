output "instance_id" {
  description = "ID of the EC2 instance created by Terraform."
  value       = aws_instance.demo.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance."
  value       = aws_instance.demo.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance."
  value       = aws_instance.demo.private_ip
}

output "instance_name" {
  description = "Name of the EC2 instance."
  value       = aws_instance.demo.tags["Name"]
}