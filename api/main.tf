/*
====================
Application-wide API
====================
*/
resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.app_name} ${var.environment}"
  description = "${var.app_name} ${var.environment} ${var.aws_region} API infrastructure"
}

/*
-------
Methods
-------
*/
module "methods" {
  source               = "./methods"
  environment          = var.environment
  app_name             = var.app_name
  aws_region           = var.aws_region
  api                  = aws_api_gateway_rest_api.api.id
  user_pool_arn        = var.user_pool_arn
  api_execution_arn    = aws_api_gateway_deployment.api.execution_arn
  api_root_resource_id = aws_api_gateway_rest_api.api.root_resource_id
  api_methods          = var.api_methods
  allowed_headers      = var.allowed_headers
  allowed_methods      = var.allowed_methods
  allowed_origin       = var.allowed_origin
}

/*
==========
Deploy API
==========
*/
resource "aws_api_gateway_deployment" "api" {
  # Description includes module output for "depends on" functionality
  description = join("-", module.methods.lambda)

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "${var.app_name}-${var.environment}"
}

output "api_endpoint" {
  value = aws_api_gateway_deployment.api.invoke_url
}
