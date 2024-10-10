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

variable "access_key" {
  type        = string
  description = "AWS Access Key"
}

variable "secret_key" {
  type        = string
  description = "AWS Secret Key"
}

variable "region" {
  type        = string
  description = "AWS region that the resources will be created"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnets"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "image_tag" {
  type        = string
  description = "Docker image tag"
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