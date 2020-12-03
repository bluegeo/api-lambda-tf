/* Always change the environment for development */
/* ============================================= */
variable "environment" {
  description = "The environment"
}

variable "app_name" {
  description = "Name of the application"
}

variable "aws_region" {
  description = "The AWS region things are created in"
}

variable "app_version" {
  description = "Version of the application"
}

variable "api_methods" {
  description = "Names of the API methods"
  type        = list
}

variable "user_pool_arn" {
  description = "ARN for the Cognito user pool if using authentication for API calls"
}

variable "allowed_headers" {
  description = "Allowed headers"
  type        = list

  default = [
    "Content-Type",
    "X-Amz-Date",
    "Authorization",
    "X-Api-Key",
    "X-Amz-Security-Token",
  ]
}

variable "allowed_methods" {
  description = "Allowed methods"
  type        = list

  default = [
    "POST"
  ]
}

variable "allowed_origin" {
  description = "Allowed origin"
  type        = string
  default     = "*"
}
