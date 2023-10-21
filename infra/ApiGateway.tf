resource "aws_api_gateway_rest_api" "sgr-security-api" {
  name        = "sgr-security-api"
  description = "SGR Security API"
}

resource "aws_api_gateway_resource" "sgr-security" {
  rest_api_id = aws_api_gateway_rest_api.sgr-security-api.id
  parent_id   = aws_api_gateway_rest_api.sgr-security-api.root_resource_id
  path_part   = "sgr"
}

resource "aws_api_gateway_resource" "login" {
  rest_api_id = aws_api_gateway_rest_api.sgr-security-api.id
  parent_id   = aws_api_gateway_resource.sgr-security.id
  path_part   = "login"
}

resource "aws_api_gateway_method" "login-post" {
  rest_api_id   = aws_api_gateway_rest_api.sgr-security-api.id
  resource_id   = aws_api_gateway_resource.login.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "sgr-security-integration" {
  rest_api_id             = aws_api_gateway_rest_api.sgr-security-api.id
  resource_id             = aws_api_gateway_resource.login.id
  http_method             = aws_api_gateway_method.login-post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.sgr-security-generate-token.invoke_arn
}

resource "aws_api_gateway_deployment" "sgr-security-api" {
  depends_on = [aws_api_gateway_integration.sgr-security-integration]
  rest_api_id = aws_api_gateway_rest_api.sgr-security-api.id
  stage_name  = "prod"
}