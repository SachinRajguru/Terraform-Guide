output "primary_instance_id" {
  type        = string
  description = "ID of the primary EC2 instance."

  value = aws_instance.primary.id
}

output "primary_public_ip" {
  type        = string
  description = "Public IP of the primary EC2 instance."

  value = aws_instance.primary.public_ip
}

output "secondary_instance_id" {
  type        = string
  description = "ID of the secondary EC2 instance."

  value = try(aws_instance.secondary[0].id, null)
}

output "secondary_public_ip" {
  type        = string
  description = "Public IP of the secondary EC2 instance."

  value = try(aws_instance.secondary[0].public_ip, null)
}

output "project_summary" {
  type        = string
  description = "Human-readable project summary."

  value = format(
    "%s infrastructure deployed in %s and %s",
    var.project_name,
    var.primary_region,
    var.secondary_region
  )
}