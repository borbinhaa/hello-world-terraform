resource "aws_ecr_repository" "repository" {
  name                 = "${var.app_name}-${var.environment}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

module "my_vpc" {
  source = "../modules/vpc"

  app_name           = var.app_name
  environment        = var.environment
  public_subnets     = var.public_subnets
  availability_zones = var.availability_zones
}

module "my_ecs" {
  source = "../modules/ecs"

  app_name       = var.app_name
  app_port       = var.app_port
  region         = var.region
  environment    = var.environment
  repository_url = aws_ecr_repository.repository.repository_url
  image_tag      = var.image_tag
  vpc_id         = module.my_vpc.vpc_id
  subnet_ids     = module.my_vpc.subnet_ids
}

module "my_pipeline" {
  source = "../modules/codepipeline"
  count  = var.environment == "prod" ? 1 : 0

  app_name            = var.app_name
  app_port            = var.app_port
  environment         = var.environment
  region              = var.region
  image_tag           = var.image_tag
  cluster_name        = module.my_ecs.cluster_name
  service_name        = module.my_ecs.service_name
  container_name      = module.my_ecs.container_name
  codestar_connection = var.codestar_connection
  github_branch       = var.github_branch
  github_repo         = var.github_repo
}