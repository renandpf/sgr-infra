resource "aws_ecs_task_definition" "sgr-gerencial-service-td" {
  depends_on = [aws_db_instance.sgr-gerencial-database, aws_ecr_repository.sgr-gerencial-repositorio]
  family                   = "sgr-gerencial-service-td"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = "arn:aws:iam::552599229727:role/LabRole"
  container_definitions = jsonencode(
    [
      {
        "name"      = "sgr-gerencial-service"
        "image"     = aws_ecr_repository.sgr-gerencial-repositorio.repository_url
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
            {"name": "SPRING_DATASOURCE_URL", "value": join("", ["jdbc:mysql://",aws_db_instance.sgr-gerencial-database.endpoint,"/sgr_gerencial_database"])},
            {"name": "SPRING_DATASOURCE_USERNAME", "value": var.sgr-gerencial-service-db-username},
            {"name": "SPRING_DATASOURCE_PASSWORD", "value": var.sgr-gerencial-service-db-password},
            {"name": "SPRING_PROFILES_ACTIVE", "value": "prd"},
        ]
        "logConfiguration": {
          "logDriver": "awslogs"
          "options": {
            "awslogs-create-group": "true"
            "awslogs-group": "sgr-gerencial-service"
            "awslogs-region": "us-west-2"
            "awslogs-stream-prefix": "ecs"
          }
        }
      }
    ]
  )
}

resource "aws_ecs_service" "sgr-gerencial-service" {
  name            = "sgr-gerencial-service"
  cluster         = module.sgr-cluster.cluster_id
  task_definition = aws_ecs_task_definition.sgr-gerencial-service-td.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.alb-sgr-gerencial-alvo.arn
    container_name   = "sgr-gerencial-service"
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