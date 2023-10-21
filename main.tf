provider "aws" {
  region = "us-east-1" # Substitua pela região desejada
}

#LAMBDA - sgr-security - START

resource "aws_lambda_function" "sgr-security-generate-token" {
  depends_on = [aws_db_instance.sgr-database]
  function_name = "sgr-security-generate-token"
  handler      = "br.com.pupposoft.fiap.sgr.security.gateway.entrypoint.GenerateTokenEntrypoint::handleRequest"
  runtime      = "java17"
  role         = aws_iam_role.iam_for_lambda.arn
  timeout      = 60

  filename = "./sgr-security/sgr-security-1.0.0-RELEASE.jar"

  environment {
        variables = {
            DATABASE_URL = join("", ["jdbc:mysql://",aws_db_instance.sgr-database.endpoint,"/sgrDbSecurity"])
            DATABASE_USERNAME = "root",
            DATABASE_PASSWORD = "senha123",
            TOKEN_SECRET_KEY = "5Evk0PWG3Xb81q0fP3Q6zb5pTs0VOScDkoE28qjG4UbzHgp7v64lI5NXzVZeJxBdWF4yZ1LQSiaX3IGcDxua2BcfxV9tmWbSrCov",
            TOKEN_EXPIRATION_TIME_IN_SECOND = "1200",
        }
  }

}

resource "aws_lambda_function" "sgr-security-validate-token" {
  depends_on = [aws_db_instance.sgr-database]
  function_name = "sgr-security-validate-token"
  handler      = "br.com.pupposoft.fiap.sgr.security.gateway.entrypoint.ValidateTokenEntrypoint::handleRequest"
  runtime      = "java17"
  role         = aws_iam_role.iam_for_lambda.arn
  timeout      = 60

  filename = "./sgr-security/sgr-security-1.0.0-RELEASE.jar"

  environment {
        variables = {
            TOKEN_SECRET_KEY = "5Evk0PWG3Xb81q0fP3Q6zb5pTs0VOScDkoE28qjG4UbzHgp7v64lI5NXzVZeJxBdWF4yZ1LQSiaX3IGcDxua2BcfxV9tmWbSrCov",
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
#LAMBDA - sgr-security - END

# ******************

#API GATEWAY - SGR SECURITY - START
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
#API GATEWAY - SGR SECURITY - END

# ******************

#DATABASE - START

resource "aws_db_instance" "sgr-database" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  db_name              = "sgrDbSecurity"
  username             = "root"
  password             = "senha123"
  parameter_group_name = "default.mysql5.7"
  publicly_accessible    = true #Deve ser false por segurança (está publica para testes didáticos)
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.sgr-database-sg.id]
  #db_subnet_group_name  = aws_db_subnet_group.example.name
}

resource "aws_security_group" "sgr-database-sg" {
  name        = "sgr-database-sg"
  description = "Database security group"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "rds_endpoint" {
  value = aws_db_instance.sgr-database.endpoint
}

#DATABASE - END