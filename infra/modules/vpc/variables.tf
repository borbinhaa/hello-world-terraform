variable "app_name" {
  type        = string
  description = "Project Name"
}

variable "environment" {
  type        = string
  description = "Environment"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnets"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}