variable "environment" {
  description = "The environment"
}

variable "app_name" {
  description = "Name of the application"
}

variable "aws_region" {
  description = "The AWS region things are created in"
}

variable "api_methods" {
  description = "Names of the lambda functions"
  type        = list
}

variable "api_execution_arn" {
  description = "ARN of the API Gateway deployment"
}
