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
  description = "AWS Region"
}

variable "project_name" {
  type        = string
  description = "Project Name"
}

variable "environment" {
  type        = string
  description = "Environment"
}

variable "image_tag" {
  type        = string
  description = "Docker image tag"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnets"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}