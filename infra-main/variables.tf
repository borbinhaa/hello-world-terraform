variable "project_name" {
  type = string
  description = "Project Name"
}

variable "image_tag" {
  type = string
  description = "Docker image tag"
}

variable "github_connection_arn" {
  type = string
  description = "AWS CodestarConnection"
}

variable "github_repo" {
  type = string
  description = "Github Repository that codepipeline will look"
}

variable "github_branch" {
  type = string
  description = "Branch that will trigger codepipeline"
}

variable "app_port" {
  type        = number
  description = "Http port that your service will open to connect"
}

variable "public_subnets" {
  type = list(string)
  description = "List of public subnets"
}

variable "availability_zones" {
  type = list(string)
  description = "List of availability zones"
}