
/*
====
Auth
====
*/
resource "aws_api_gateway_authorizer" "api_auth" {
  name          = "${var.app_name}-${var.environment}"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = var.api
  provider_arns = [var.user_pool_arn]
  count         = var.user_pool_arn == "none" ? 0 : 1
}

/*
Methods to call one or more lambda functions
*/
// Resources
resource "aws_api_gateway_resource" "lambda" {
  count = length(var.api_methods)

  rest_api_id = var.api
  parent_id   = var.api_root_resource_id
  path_part   = var.api_methods[count.index]
}

// CORS (required for each resource)
module "cors" {
  source            = "../cors"
  rest_api_id       = var.api
  resource_ids      = aws_api_gateway_resource.lambda.*.id
  resource_id_count = length(var.api_methods)
  allowed_headers   = var.allowed_headers
  allowed_methods   = var.allowed_methods
  allowed_origin    = var.allowed_origin
}


// Methods
resource "aws_api_gateway_method" "lambda" {
  count = length(var.api_methods)

  rest_api_id   = var.api
  resource_id   = aws_api_gateway_resource.lambda.*.id[count.index]
  http_method   = "POST"
  authorization = var.user_pool_arn == "none" ? "NONE" : "COGNITO_USER_POOLS"
  authorizer_id = var.user_pool_arn == "none" ? "NONE" : aws_api_gateway_authorizer.api_auth[0].id
}

resource "aws_api_gateway_method_response" "lambda" {
  count      = length(var.api_methods)
  depends_on = [aws_api_gateway_method.lambda]

  rest_api_id = var.api
  resource_id = aws_api_gateway_resource.lambda.*.id[count.index]
  http_method = aws_api_gateway_method.lambda.*.http_method[count.index]
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

// Build the lambda functions
module "lambda" {
  source            = "./lambda"
  environment       = var.environment
  app_name          = var.app_name
  aws_region        = var.aws_region
  api_methods       = var.api_methods
  api_execution_arn = var.api_execution_arn
}

// Create roles for the methods to invoke the functions
data "aws_iam_policy_document" "lambda" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
    ]
    resources = module.lambda.lambda_arns
  }
}

// Create IAM Policy from the above document
resource "aws_iam_policy" "lambda" {
  name        = "${var.app_name}-${var.environment}-api-lambda-tf"
  description = "Allow API Gateway to collect invoke a function"
  path        = "/"
  policy      = data.aws_iam_policy_document.lambda.json
}

// IAM Role
resource "aws_iam_role" "lambda" {
  name               = "${var.app_name}-${var.environment}-api-lambda-tf"
  description        = "Allow API Gateway to invoke lambda functions"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

// Attach the role to the policy
resource "aws_iam_role_policy_attachment" "lambda" {
  depends_on = [aws_iam_policy.lambda, aws_iam_role.lambda]

  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

// Create the JSON required to cleanly pass methods through API Gateway
data "template_file" "lambda" {
  count    = length(var.api_methods)
  template = file("${path.root}/api/methods/lambda/${var.api_methods[count.index]}/parameters.json")
}

// Integrate with API Gateway
resource "aws_api_gateway_integration" "lambda" {
  count = length(var.api_methods)
  depends_on = [
    aws_api_gateway_method_response.lambda,
  ]

  rest_api_id = var.api
  resource_id = aws_api_gateway_resource.lambda.*.id[count.index]
  http_method = aws_api_gateway_method.lambda.*.http_method[count.index]

  integration_http_method = "POST"
  type                    = "AWS"

  uri         = module.lambda.lambda_invoke_arns[count.index]
  credentials = aws_iam_role.lambda.arn

  passthrough_behavior = "NEVER"
  request_templates = {
    "application/json" = data.template_file.lambda.*.rendered[count.index]
  }
}

resource "aws_api_gateway_integration_response" "lambda" {
  depends_on = [
    aws_api_gateway_integration.lambda,
  ]
  count = length(var.api_methods)

  rest_api_id = var.api
  resource_id = aws_api_gateway_resource.lambda.*.id[count.index]
  http_method = aws_api_gateway_method.lambda.*.http_method[count.index]
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

output "lambda" {
  value = aws_api_gateway_integration_response.lambda.*.id
}
