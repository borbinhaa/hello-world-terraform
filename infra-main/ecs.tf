resource "aws_iam_policy" "ecs-task-execution-policy" {
  name   = "ecs-task-execution-${var.project_name}-policy"
  path   = "/"
  policy = file("iam/ecs/ecs-task-execution-policy.json")
}

resource "aws_iam_role" "ecs-task-execution-role" {
  name               = "ecs-task-execution-${var.project_name}-role"
  assume_role_policy = file("iam/ecs/trust-policy.json")
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-policy-attachment" {
  policy_arn = aws_iam_policy.ecs-task-execution-policy.arn
  role       = aws_iam_role.ecs-task-execution-role.id
}

resource "aws_cloudwatch_log_group" "log-group" {
  name = "/ecs/${var.project_name}-logs"
}

resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.project_name}-cluster"
}

resource "aws_ecs_task_definition" "ecs-task" {
  family                   = "${var.project_name}-family"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  container_definitions = templatefile("ecs/container.json", {
    project_name   = var.project_name
    repository_url = aws_ecr_repository.repository.repository_url
    image_tag      = var.image_tag
    log_group_name = aws_cloudwatch_log_group.log-group.id
    region         = local.region
    container_port = var.app_port
  })
  execution_role_arn = aws_iam_role.ecs-task-execution-role.arn
  task_role_arn      = aws_iam_role.ecs-task-execution-role.arn
}

data "aws_ecs_task_definition" "task_definion" {
  task_definition = aws_ecs_task_definition.ecs-task.family
}

resource "aws_security_group" "security_group" {
  name        = "${var.project_name}-sg"
  description = "Allow Http"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_tcp_ipv4" {
  security_group_id = aws_security_group.security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.app_port
  to_port           = var.app_port
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_ecs_service" "ecs-service" {
  name                 = "${var.project_name}-service"
  cluster              = aws_ecs_cluster.ecs-cluster.id
  task_definition      = "${aws_ecs_task_definition.ecs-task.family}:${max(aws_ecs_task_definition.ecs-task.revision, data.aws_ecs_task_definition.task_definion.revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = aws_subnet.public.*.id
    assign_public_ip = true
    security_groups  = [aws_security_group.security_group.id]
  }
}