variable "environment" {
  description = "The environment"
}

variable "app_name" {
  description = "Name of the application"
}

variable "aws_region" {
  description = "The AWS region things are created in"
}

variable "api" {
  description = "The Root API Resource"
}

variable "api_execution_arn" {
  description = "ARN of the API Gateway deployment"
}

variable "api_root_resource_id" {
  description = "Root resource ID for the API"
}

variable "api_methods" {
  description = "list of API methods"
  type = "list"
}

variable "allowed_headers" {
  description = "CORS variables"
  type        = "list"
}
variable "allowed_methods" {
  description = "CORS variables"
  type        = "list"
}
variable "allowed_origin" {
  description = "CORS variables"
}
