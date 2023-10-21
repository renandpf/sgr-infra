module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "prd-sgr"

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 1
      }
    }
  }
}

resource "aws_ecs_task_definition" "sgr-service-api-td" {
  family                   = "sgr-service-api-td"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.cargo.arn
  container_definitions = jsonencode(
    [
      {
        "name"      = "sgr-service"
        "image"     = "962752222089.dkr.ecr.us-west-2.amazonaws.com/sgr-service:v1"
        "cpu"       = 256
        "memory"    = 512
        "essential" = true
        "portMappings" = [
          {
            "containerPort" = 8080
            "hostPort"      = 8080
          }
        ]
      }
    ]
  )
}

resource "aws_ecs_service" "sgr-service-api" {
  name            = "sgr-service-api"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.sgr-service-api-td.arn
  desired_count   = 3

  load_balancer {
    target_group_arn = aws_lb_target_group.alvo.arn
    container_name   = "producao"
    container_port   = 8080
  }

  network_configuration {
      subnets = module.vpc.private_subnets
      security_groups = [aws_security_group.privado.id]
  }

  capacity_provider_strategy {
      capacity_provider = "FARGATE"
      weight = 1 #100/100
  }
}