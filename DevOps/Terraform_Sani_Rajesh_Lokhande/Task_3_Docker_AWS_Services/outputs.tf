
output "vpc_id" {
  value       = aws_vpc.test_sani_vpc.id
  description = "The ID of the custom VPC"
}

output "subnet_id" {
  value       = aws_subnet.public_subnet.id
  description = "The ID of the public subnet"
}

output "ecr_backend_repository_url" {
  value       = aws_ecr_repository.backend_repo.repository_url
  description = "The registry URL to push your Docker container images to"
}

output "ecr_frontend_repository_url" {
  value       = aws_ecr_repository.frontend_repo.repository_url
  description = "The registry URL to push your Docker container images to"
}

output "ecs_cluster_name" {
  value       = aws_ecs_cluster.app_cluster.name
  description = "The name of the provisioned ECS cluster"
}

output "backend_service_name" {
  value       = aws_ecs_service.backend_service.name
  description = "The active Fargate service running the Flask application"
}

output "frontend_service_name" {
  value       = aws_ecs_service.frontend_service.name
  description = "The active Fargate service running the Express application"
}

output "backend_url" {
  value       = "http://${aws_lb.student_LB.dns_name}:5000"
  description = "The public URL to access your live Flask Backend application"
}

output "frontend_url" {
  value       = "http://${aws_lb.student_LB.dns_name}:3000"
  description = "The public URL to access your live Express Frontend application"
}