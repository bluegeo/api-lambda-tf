/*
================================
Lambda functions for each method
================================
*/
// Create a bucket for dumping all of the function packages
resource "aws_s3_bucket" "lambda" {
  bucket = "${lower(var.app_name)}-${lower(var.environment)}-api-lambda-tf"
  acl    = "private"

  force_destroy = true

  tags {
    Name        = "${var.app_name}-${var.environment}-lambda"
    Environment = "${var.app_name}-${var.environment}"
  }
}
/*
Build the lambda packages using docker
*/
resource "null_resource" "lambda" {
  count = "${length(var.api_methods)}"

  provisioner "local-exec" {
    command = "cd ${path.root}/api/methods/lambda/${var.api_methods[count.index]} && docker build -t package . && docker run --name package package /bin/true && docker cp package:/var/task/package.zip package.zip && docker rm package"
  }
}

// Upload the functions to the S3 bucket
resource "aws_s3_bucket_object" "lambda" {
  count = "${length(var.api_methods)}"
  depends_on = [
    "aws_s3_bucket.lambda",
    "null_resource.lambda"]

  bucket = "${lower(var.app_name)}-${lower(var.environment)}-api-lambda-tf"
  key    = "${var.api_methods[count.index]}.zip"
  source = "${path.root}/api/methods/lambda/${var.api_methods[count.index]}/package.zip"
}

// Create a role so lambda may access S3
// Lambda to access S3
data "aws_iam_policy_document" "lambda" {
  statement {
    effect = "Allow",
    actions   = [
      "s3:GetObject",
      "s3:GetObjectAcl"
    ]
    resources = [
      "arn:aws:s3:::${lower(var.app_name)}-${lower(var.environment)}-api-lambda-tf/*"
    ]
  }
}
// Create IAM Policy from the above document
resource "aws_iam_policy" "lambda" {
  name   = "${var.app_name}-${var.environment}-lambda"
  description = "Allow lambda to collect functions from a bucket"
  path   = "/"
  policy = "${data.aws_iam_policy_document.lambda.json}"
}

// IAM Role
resource "aws_iam_role" "lambda" {
  name = "${var.app_name}-${var.environment}-lambda"
  description = "Allow lambda to collect functions from a bucket"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

// Attach the role to the policy
resource "aws_iam_role_policy_attachment" "lambda" {
  depends_on = ["aws_iam_policy.lambda", "aws_iam_role.lambda"]

  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "${aws_iam_policy.lambda.arn}"
}

// Create the lambda function
resource "aws_lambda_function" "lambda" {
  count = "${length(var.api_methods)}"
  depends_on = [
    "aws_s3_bucket_object.lambda"
  ]
  function_name = "${var.app_name}-${var.environment}-${var.api_methods[count.index]}"

  s3_bucket = "${lower(var.app_name)}-${lower(var.environment)}-api-lambda-tf"
  s3_key    = "${var.api_methods[count.index]}.zip"
  timeout = "900"

  handler = "handler.handler"
  runtime = "python3.6"

  role = "${aws_iam_role.lambda.arn}"
}

// Allow API Gateway access to lambda
resource "aws_lambda_permission" "lambda" {
  count = "${length(var.api_methods)}"
  depends_on = ["aws_lambda_function.lambda"]

  statement_id  = "${var.app_name}-${var.environment}-api-lambda-tf"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.*.arn[count.index]}"
  principal     = "apigateway.amazonaws.com"

  # The /* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${var.api_execution_arn}/*"
}

output "lambda_arns" {
  value = ["${aws_lambda_function.lambda.*.arn}"]
}

output "lambda_invoke_arns" {
  value = ["${aws_lambda_function.lambda.*.invoke_arn}"]
}
