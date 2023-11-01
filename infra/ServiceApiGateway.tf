resource "aws_api_gateway_rest_api" "sgr-service-api" {
  name        = "sgr-service-api"
  description = "SGR Service API"
}

resource "aws_api_gateway_resource" "sgr-service" {
  rest_api_id = aws_api_gateway_rest_api.sgr-service-api.id
  parent_id   = aws_api_gateway_rest_api.sgr-service-api.root_resource_id
  path_part   = "sgr"
}

resource "aws_api_gateway_resource" "gerencial" {
  rest_api_id = aws_api_gateway_rest_api.sgr-service-api.id
  parent_id   = aws_api_gateway_resource.sgr-service.id
  path_part   = "gerencial"
}

resource "aws_api_gateway_resource" "produtos" {
  rest_api_id   = aws_api_gateway_rest_api.sgr-service-api.id
  parent_id   = aws_api_gateway_resource.gerencial.id
  path_part   = "produtos"
}

resource "aws_api_gateway_resource" "produtoId" {
  rest_api_id   = aws_api_gateway_rest_api.sgr-service-api.id
  parent_id   = aws_api_gateway_resource.produtos.id
  path_part   = "{produtoId}"
}

resource "aws_api_gateway_method" "get-produto" {
  rest_api_id   = aws_api_gateway_rest_api.sgr-service-api.id
  resource_id   = aws_api_gateway_resource.produtoId.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.produtoId" = true
  }
}

resource "aws_api_gateway_authorizer" "authorizer" {
  name                   = "sgr-security-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.sgr-service-api.id
  authorizer_uri         = aws_lambda_function.sgr-security-validate-token.invoke_arn
  authorizer_credentials = aws_iam_role.invocation_role.arn
}

resource "aws_api_gateway_integration" "sgr-service-integration" {
  rest_api_id             = aws_api_gateway_rest_api.sgr-service-api.id
  resource_id             = aws_api_gateway_resource.produtoId.id
  http_method             = aws_api_gateway_method.get-produto.http_method
  
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = join("", ["http://",aws_lb.alb.dns_name,":8080/sgr/gerencial/produtos/{produtoId}"])
  request_parameters      = {
    "integration.request.path.produtoId" = "method.request.path.produtoId"
  }
}

resource "aws_api_gateway_deployment" "sgr-service-api" {
  depends_on = [aws_api_gateway_integration.sgr-service-integration]
  rest_api_id = aws_api_gateway_rest_api.sgr-service-api.id
  stage_name  = "prod"
}