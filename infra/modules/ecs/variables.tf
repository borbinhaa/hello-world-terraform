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

variable "vpc_id" {
  type        = string
  description = "VPC id to create the security group"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets to launch the container"
}

variable "image_tag" {
  type        = string
  description = "Docker image tag"
}

variable "repository_url" {
  type        = string
  description = "ECR Repository URL"
}
