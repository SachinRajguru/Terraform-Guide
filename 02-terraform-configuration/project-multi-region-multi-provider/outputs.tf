output "aws_east_instance_id" {
  description = "Instance ID of the EC2 instance deployed in the primary AWS region."
  value       = aws_instance.east.id
}

output "aws_west_instance_id" {
  description = "Instance ID of the EC2 instance deployed in the secondary AWS region."
  value       = aws_instance.west.id
}

output "aws_east_instance_type" {
  description = "Instance type of the EC2 instance deployed in the primary AWS region."
  value       = aws_instance.east.instance_type
}

output "aws_west_instance_type" {
  description = "Instance type of the EC2 instance deployed in the secondary AWS region."
  value       = aws_instance.west.instance_type
}

output "aws_east_public_ip" {
  description = "Public IPv4 address of the EC2 instance deployed in the primary AWS region."
  value       = aws_instance.east.public_ip
}

output "aws_west_public_ip" {
  description = "Public IPv4 address of the EC2 instance deployed in the secondary AWS region."
  value       = aws_instance.west.public_ip
}

output "azure_resource_group_name" {
  description = "Name of the Azure resource group when Azure deployment is enabled."
  value       = try(azurerm_resource_group.this[0].name, null)
}

output "resource_name_prefix" {
  description = "Generated resource name prefix based on project name and environment."
  value       = local.name_prefix
}

output "selected_instance_type" {
  description = "EC2 instance type selected based on the deployment environment."
  value       = local.selected_instance_type
}