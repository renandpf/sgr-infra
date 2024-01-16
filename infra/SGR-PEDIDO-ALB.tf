resource "aws_lb" "alb-sgr-pedido" {
  name               = "ECS-SGR-PEDIDO-SERVICE"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_listener" "alb-sgr-pedido-http" {
  load_balancer_arn = aws_lb.alb-sgr-pedido.arn
  port              = "8080"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-sgr-pedido-alvo.arn
  }
}

resource "aws_lb_target_group" "alb-sgr-pedido-alvo" {
  name        = "ECS-SGR-PEDIDO-SERVICE"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id
  health_check {
    path = "/actuator/health"
  }
}