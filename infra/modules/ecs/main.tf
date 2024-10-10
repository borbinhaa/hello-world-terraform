locals {
  container_name = "${var.app_name}-${var.environment}-container"
}

resource "aws_iam_policy" "ecs-task-execution-policy" {
  name   = "ecs-task-execution-${var.app_name}-${var.environment}-policy"
  path   = "/"
  policy = file("${path.module}/config/ecs-task-execution-policy.json")
}

resource "aws_iam_role" "ecs-task-execution-role" {
  name               = "ecs-task-execution-${var.app_name}-${var.environment}-role"
  assume_role_policy = file("${path.module}/config/trust-policy.json")
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-policy-attachment" {
  policy_arn = aws_iam_policy.ecs-task-execution-policy.arn
  role       = aws_iam_role.ecs-task-execution-role.id
}

resource "aws_cloudwatch_log_group" "log-group" {
  name = "/ecs/${var.app_name}-${var.environment}-logs"
}

resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.app_name}-${var.environment}-cluster"
}

resource "aws_ecs_task_definition" "ecs-task" {
  family                   = "${var.app_name}-${var.environment}-family"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  container_definitions = templatefile("${path.module}/config/container.json", {
    container_name = local.container_name
    container_port = var.app_port
    repository_url = var.repository_url
    image_tag      = var.image_tag
    log_group_name = aws_cloudwatch_log_group.log-group.id
    region         = var.region
  })
  execution_role_arn = aws_iam_role.ecs-task-execution-role.arn
  task_role_arn      = aws_iam_role.ecs-task-execution-role.arn
}

data "aws_ecs_task_definition" "task_definion" {
  task_definition = aws_ecs_task_definition.ecs-task.family
}

resource "aws_security_group" "security_group" {
  name        = "${var.app_name}-${var.environment}-sg"
  description = "Allow Http in port 8080"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_tcp_ipv4" {
  security_group_id = aws_security_group.security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_ecs_service" "ecs-service" {
  name                 = "${var.app_name}-${var.environment}-service"
  cluster              = aws_ecs_cluster.ecs-cluster.id
  task_definition      = "${aws_ecs_task_definition.ecs-task.family}:${max(aws_ecs_task_definition.ecs-task.revision, data.aws_ecs_task_definition.task_definion.revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = true
    security_groups  = [aws_security_group.security_group.id]
  }
}