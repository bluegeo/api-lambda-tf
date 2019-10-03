/* Configure these variables in a `terraform.tfvars` file */
/* ====================================================== */

variable "app_name" {
  // Note: do not include spaces or special characters
  description = "Name of the application"
}

variable "app_version" {
  description = "Version of the application"
}

variable "environment" {
  description = "The environment of the application"
}

variable "aws_profile" {
  description = "The profile used by the AWS CLI"
}

variable "aws_region" {
  description = "The AWS region things are created in"
}

// Methods go here (each is associated with a different lambda call)
variable "api_methods" {
  description = "Names of different lambda functions to be called by the api"
  type = "list"
  default = [
    "invoke-default"
  ]
}
