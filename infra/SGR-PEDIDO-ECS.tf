resource "aws_ecs_task_definition" "sgr-pedido-service-td" {
  depends_on = [aws_db_instance.sgr-pedido-database, 
                aws_ecr_repository.sgr-pedido-repositorio, 
                aws_lb.alb-sgr-gerencial, 
                aws_lb.alb-sgr-pagamento]
  family                   = "sgr-pedido-service-td"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = "arn:aws:iam::552599229727:role/LabRole"
  container_definitions = jsonencode(
    [
      {
        "name"      = "sgr-pedido-service"
        "image"     = aws_ecr_repository.sgr-pedido-repositorio.repository_url
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
            {"name": "SPRING_DATASOURCE_URL", "value": join("", ["jdbc:mysql://",aws_db_instance.sgr-pedido-database.endpoint,"/sgr_pedido_database"])},
            {"name": "SPRING_DATASOURCE_USERNAME", "value": var.sgr-pedido-service-db-username},
            {"name": "SPRING_DATASOURCE_PASSWORD", "value": var.sgr-pedido-service-db-password},
            {"name": "SPRING_PROFILES_ACTIVE", "value": "prd"},
            {"name": "SGR_CLIENTE-SERVICE_URL", "value": join("", ["http://",aws_lb.alb-sgr-gerencial.dns_name,":8080"])},
            {"name": "SGR_PRODUTO-SERVICE_URL", "value": join("", ["http://",aws_lb.alb-sgr-gerencial.dns_name,":8080"])},
            {"name": "SGR_PAGAMENTO-SERVICE_URL", "value": join("", ["http://",aws_lb.alb-sgr-pagamento.dns_name,":8080"])},
        ]
        "logConfiguration": {
          "logDriver": "awslogs"
          "options": {
            "awslogs-create-group": "true"
            "awslogs-group": "sgr-pedido-service"
            "awslogs-region": "us-west-2"
            "awslogs-stream-prefix": "ecs"
          }
        }
      }
    ]
  )
}

resource "aws_ecs_service" "sgr-pedido-service" {
  name            = "sgr-pedido-service"
  cluster         = module.sgr-cluster.cluster_id
  task_definition = aws_ecs_task_definition.sgr-pedido-service-td.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.alb-sgr-pedido-alvo.arn
    container_name   = "sgr-pedido-service"
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