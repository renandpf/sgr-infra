resource "aws_security_group" "alb" {
  name        = "alb_ECS"
  vpc_id      = module.vpc.vpc_id
}

#Entrada Load Balancer
resource "aws_security_group_rule" "tcp_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] #0.0.0.0 até 255.255.255.255
  security_group_id = aws_security_group.alb.id
}

#Saída  Load Balancer
resource "aws_security_group_rule" "saida_alb" {
  type              = "egress"
  from_port         = 0 #Qualquer Porta
  to_port           = 0 #Qualquer Porta
  protocol          = "-1" #Qualquer Protocolo
  cidr_blocks       = ["0.0.0.0/0"] #0.0.0.0 até 255.255.255.255
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group" "privado" {
  name        = "privado_ECS"
  vpc_id      = module.vpc.vpc_id
}

#Entrada Serviço
resource "aws_security_group_rule" "entrada_ECS" {
  type              = "ingress"
  from_port         = 0 #Qualquer Porta
  to_port           = 0 #Qualquer Porta
  protocol          = "-1" #Qualquer Protocolo
  source_security_group_id = aws_security_group.alb.id #Entrada limitada somente aos recursos da nossa rede publica
  security_group_id = aws_security_group.privado.id
}

#Saida Serviço
resource "aws_security_group_rule" "saida_ECS" {
  type              = "egress"
  from_port         = 0 #Qualquer Porta
  to_port           = 0 #Qualquer Porta
  protocol          = "-1" #Qualquer Protocolo
  cidr_blocks       = ["0.0.0.0/0"] #0.0.0.0 até 255.255.255.255
  security_group_id = aws_security_group.privado.id
}