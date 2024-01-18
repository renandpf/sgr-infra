resource "aws_lb" "alb-sgr-gerencial" {
  name               = "ECS-SGR-GERENCIAL-SERVICE"
  internal           = false
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_listener" "alb-sgr-gerencial-http" {
  load_balancer_arn = aws_lb.alb-sgr-gerencial.arn
  port              = "8080"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-sgr-gerencial-alvo.arn
  }
}

resource "aws_lb_target_group" "alb-sgr-gerencial-alvo" {
  name        = "ECS-SGR-GERENCIAL-SERVICE"
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