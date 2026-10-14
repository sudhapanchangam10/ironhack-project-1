
# Frontend EC2 instance
output "frontend_instance_id" {
  description = "ID of the frontend EC2 instance"
  value       = aws_instance.web_server.id
}

output "frontend_public_ip" {
  description = "Public IP address of the frontend EC2 instance"
  value       = aws_instance.web_server.public_ip
}

# Backend EC2 instance
output "backend_instance_id" {
  description = "ID of the backend EC2 instance"
  value       = aws_instance.backend_server.id
}

output "backend_private_ip" {
  description = "Private IP address of the backend EC2 instance"
  value       = aws_instance.backend_server.private_ip
}

# Database EC2 instance
output "database_instance_id" {
  description = "ID of the database EC2 instance"
  value       = aws_instance.database_server.id
}

output "database_private_ip" {
  description = "Private IP address of the database EC2 instance"
  value       = aws_instance.database_server.private_ip
}
