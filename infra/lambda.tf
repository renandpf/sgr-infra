resource "aws_lambda_function" "sgr-security-generate-token" {
  depends_on = [aws_db_instance.sgr-security-database]
  function_name = "sgr-security-generate-token"
  handler      = "br.com.pupposoft.fiap.sgr.security.gateway.entrypoint.GenerateTokenEntrypoint::handleRequest"
  runtime      = "java17"
  role         = aws_iam_role.iam_for_lambda.arn
  timeout      = 60

  filename = "./sgr-security/sgr-security-1.0.0-RELEASE.jar"

  environment {
        variables = {
            DATABASE_URL = join("", ["jdbc:mysql://",aws_db_instance.sgr-service-database.endpoint,"/sgrDbSecurity"])
            DATABASE_USERNAME = var.sgr-security-db-username
            DATABASE_PASSWORD = var.sgr-security-db-password,
            TOKEN_SECRET_KEY = var.secret-token,
            TOKEN_EXPIRATION_TIME_IN_SECOND = var.token-expiration-time-seconds,
        }
  }
}

resource "aws_lambda_function" "sgr-security-validate-token" {
  depends_on = [aws_db_instance.sgr-security-database]
  function_name = "sgr-security-validate-token"
  handler      = "br.com.pupposoft.fiap.sgr.security.gateway.entrypoint.ValidateTokenEntrypoint::handleRequest"
  runtime      = "java17"
  role         = aws_iam_role.iam_for_lambda.arn
  timeout      = 60

  filename = "../sgr-security/sgr-security-1.0.0-RELEASE.jar"

  environment {
        variables = {
            TOKEN_SECRET_KEY = var.secret-token,
        }
  }
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowSgrSecurityAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sgr-security-generate-token.function_name
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${aws_api_gateway_rest_api.sgr-security-api.execution_arn}/*"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}
