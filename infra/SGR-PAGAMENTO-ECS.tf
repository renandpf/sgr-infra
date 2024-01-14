resource "aws_ecs_task_definition" "sgr-pagamento-service-td" {
  depends_on = [aws_db_instance.sgr-pagamento-database]
  family                   = "sgr-pagamento-service-td"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = "arn:aws:iam::552599229727:role/LabRole"
  container_definitions = jsonencode(
    [
      {
        "name"      = "sgr-pagamento-service"
        "image"     = "552599229727.dkr.ecr.us-west-2.amazonaws.com/sgr-pagamento-service:latest"
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
            {"name": "SPRING_DATASOURCE_URL", "value": join("", ["jdbc:mysql://",aws_db_instance.sgr-pagamento-database.endpoint,"/sgr_pagamento_database"])},
            {"name": "SPRING_DATASOURCE_USERNAME", "value": var.sgr-pagamento-service-db-username},
            {"name": "SPRING_DATASOURCE_PASSWORD", "value": var.sgr-pagamento-service-db-password}
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

resource "aws_ecs_service" "sgr-pagamento-service" {
  name            = "sgr-pagamento-service"
  cluster         = module.sgr-cluster.cluster_id
  task_definition = aws_ecs_task_definition.sgr-pagamento-service-td.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.alb-sgr-pagamento-alvo.arn
    container_name   = "sgr-pagamento-service"
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