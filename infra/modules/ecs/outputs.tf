output "cluster_name" {
  value = aws_ecs_cluster.ecs-cluster.name
}

output "service_name" {
  value = aws_ecs_service.ecs-service.name
}

output "container_name" {
  value = local.container_name
}