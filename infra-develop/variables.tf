variable "project_name" {
  type = string
  description = "Project Name"
}

variable "environment" {
  type = string
  description = "Environment"
}

variable "image_tag" {
  type = string
  description = "Docker image tag"
}

variable "public_subnets" {
  type = list(string)
  description = "List of public subnets"
}

variable "availability_zones" {
  type = list(string)
  description = "List of availability zones"
}