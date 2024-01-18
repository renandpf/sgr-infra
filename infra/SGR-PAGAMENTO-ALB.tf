resource "aws_lb" "alb-sgr-pagamento" {
  name               = "ECS-SGR-PAGAMENTO-SERVICE"
  internal           = false
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_listener" "alb-sgr-pagamento-http" {
  load_balancer_arn = aws_lb.alb-sgr-pagamento.arn
  port              = "8080"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-sgr-pagamento-alvo.arn
  }
}

resource "aws_lb_target_group" "alb-sgr-pagamento-alvo" {
  name        = "ECS-SGR-PAGAMENTO-SERVICE"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id
  health_check {
    path = "/actuator/health"
    healthy_threshold = "3"
    unhealthy_threshold = "10"
    timeout = "30"
    interval = "60"
  }
}