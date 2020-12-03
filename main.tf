/*
Provider
========

Configure your AWS Credentials in advance using the aws-cli
(see https://aws.amazon.com/cli/)
*/

provider "aws" {
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = var.aws_profile
  region                  = var.aws_region
}

/*
API and compute infrastructure
*/
module "api" {
  source        = "./api"
  environment   = var.environment
  app_name      = var.app_name
  aws_region    = var.aws_region
  app_version   = var.app_version
  user_pool_arn = var.user_pool_arn
  api_methods   = var.api_methods
}

/*
Output the API invoke URL
*/
output "invoke_url" {
  value = module.api.api_endpoint
}
