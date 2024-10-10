variable "app_name" {
  type        = string
  description = "Project Name"
}

variable "app_port" {
  type        = number
  description = "Http port that your service will open to connect"
}

variable "environment" {
  type        = string
  description = "Environment"
}

variable "region" {
  type        = string
  description = "AWS region that the resources will be created"
}

variable "image_tag" {
  type        = string
  description = "Docker image tag"
}

variable "cluster_name" {
  type        = string
  description = "ECS Cluster to deploy the app"
}

variable "service_name" {
  type        = string
  description = "ECS service to deploy the app"
}

variable "container_name" {
  type        = string
  description = "ECS container name to deploy the app"
}

variable "codestar_connection" {
  type        = string
  description = "AWS CodestarConnection"
}

variable "github_repo" {
  type        = string
  description = "Github Repository that codepipeline will look"
}

variable "github_branch" {
  type        = string
  description = "Branch that will trigger codepipeline"
}