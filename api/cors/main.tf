/*
CORS
*/
resource "aws_api_gateway_method" "_" {
  count = var.resource_id_count

  rest_api_id   = var.rest_api_id
  resource_id   = var.resource_ids[count.index]
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "_" {
  count      = var.resource_id_count
  depends_on = [aws_api_gateway_method._]

  rest_api_id = var.rest_api_id
  resource_id = var.resource_ids[count.index]
  http_method = aws_api_gateway_method._.*.http_method[count.index]

  type = "MOCK"

  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

resource "aws_api_gateway_integration_response" "_" {
  count = var.resource_id_count

  rest_api_id = var.rest_api_id
  resource_id = var.resource_ids[count.index]
  http_method = aws_api_gateway_method._.*.http_method[count.index]
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = "'${join(",", var.allowed_headers)}'"
    "method.response.header.Access-Control-Allow-Methods"     = "'${join(",", var.allowed_methods)}'"
    "method.response.header.Access-Control-Allow-Origin"      = "'${var.allowed_origin}'"
    "method.response.header.Access-Control-Allow-Credentials" = "'*'"
  }

  depends_on = [
    aws_api_gateway_integration._,
  ]
}

resource "aws_api_gateway_method_response" "_" {
  count = var.resource_id_count

  rest_api_id = var.rest_api_id
  resource_id = var.resource_ids[count.index]
  http_method = aws_api_gateway_method._.*.http_method[count.index]
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true
    "method.response.header.Access-Control-Allow-Methods"     = true
    "method.response.header.Access-Control-Allow-Origin"      = true
    "method.response.header.Access-Control-Allow-Credentials" = true
  }

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    aws_api_gateway_method._,
  ]
}
