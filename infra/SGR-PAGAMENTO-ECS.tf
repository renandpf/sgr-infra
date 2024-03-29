resource "aws_ecs_task_definition" "sgr-pagamento-service-td" {
  depends_on = [aws_db_instance.sgr-pagamento-database, 
                aws_ecr_repository.sgr-pagamento-repositorio,
                aws_lb.alb-sgr-gerencial,
                aws_lb.alb-sgr-pedido]
  family                   = "sgr-pagamento-service-td"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = "arn:aws:iam::992382745295:role/LabRole"
  container_definitions = jsonencode(
    [
      {
        "name"      = "sgr-pagamento-service"
        "image"     = aws_ecr_repository.sgr-pagamento-repositorio.repository_url
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
            {"name": "SPRING_DATASOURCE_PASSWORD", "value": var.sgr-pagamento-service-db-password},
            {"name": "SPRING_PROFILES_ACTIVE", "value": "prd"},
            {"name": "SGR_CLIENTE-SERVICE_URL", "value": join("", ["http://",aws_lb.alb-sgr-gerencial.dns_name,":8080"])},
            {"name": "SGR_PEDIDO-SERVICE_URL", "value": join("", ["http://",aws_lb.alb-sgr-pedido.dns_name,":8080"])},
            {"name": "CLOUD_SQS_STATUS-PEDIDO_ENDPOINT", "value": aws_sqs_queue.atualiza_status_pedido_qeue.url},
            {"name": "CLOUD_SQS_NOTIFICAR-CLIENTE_ENDPOINT", "value": aws_sqs_queue.notificar_qeue.url},
            {"name": "CLOUD_SQS.EFETUAR-PAGAMENTO_ENDPOINT", "value": aws_sqs_queue.efetuar_pagamento_qeue.url},
            {"name": "AWS_ACCESS_KEY_ID", "value": var.aws-access-key-id},
            {"name": "AWS_SECRET_ACCESS_KEY", "value": var.aws-secret-access-key},
            {"name": "AWS_SESSION_TOKEN", "value": var.aws-session-token},
        ]
        "logConfiguration": {
          "logDriver": "awslogs"
          "options": {
            "awslogs-create-group": "true"
            "awslogs-group": "sgr-pagamento-service"
            "awslogs-region": "us-west-2"
            "awslogs-stream-prefix": "ecs"
          }
        }
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