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

resource "aws_ecs_task_definition" "sgr-service-spring-td" {
  depends_on = [aws_db_instance.sgr-service-database]
  family                   = "sgr-service-spring-td"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.cargo.arn
  container_definitions = jsonencode(
    [
      {
        "name"      = "sgr-service"
        "image"     = "057028502056.dkr.ecr.us-west-2.amazonaws.com/sgr-service-spring:latest"
        "cpu"       = 256
        "memory"    = 512
        "essential" = true
        "portMappings" = [
          {
            "containerPort" = 8080
            "hostPort"      = 8080
          }
        ]
        "environment"= [
            {"name": "SPRING_DATASOURCE_URL", "value": join("", ["jdbc:mysql://",aws_db_instance.sgr-service-database.endpoint,"/sgr_database"])},
            {"name": "SPRING_DATASOURCE_USERNAME", "value": var.sgr-service-db-username},
            {"name": "SPRING_DATASOURCE_PASSWORD", "value": var.sgr-service-db-password}
        ]
        # "logConfiguration": {
        #   "logDriver": "awslogs",
        #   "options": {
        #     "awslogs-group": "sgr-service",
        #     "awslogs-region": "us-west-2",
        #     "awslogs-stream-prefix": "ecs"
        #   }
        # }
      }
    ]
  )
}

resource "aws_ecs_service" "sgr-service-spring" {
  name            = "sgr-service-spring"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.sgr-service-spring-td.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.alvo.arn
    container_name   = "sgr-service"
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