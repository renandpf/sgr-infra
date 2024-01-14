
resource "aws_db_instance" "sgr-pagamento-database" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  db_name              = "sgr_database"
  username             = var.sgr-pagamento-service-db-username
  password             = var.sgr-pagamento-service-db-password
  parameter_group_name = "default.mysql5.7"
  publicly_accessible    = true #Deve ser false por segurança (está publica para testes didáticos)
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.sgr-pagamento-database-sg.id]
  #db_subnet_group_name  = aws_db_subnet_group.example.name
}

resource "aws_security_group" "sgr-pagamento-database-sg" {
  name        = "sgr-pagamento-database-sg"
  description = "Sgr Pagamento Database Security Group"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "rds_sgr_pagamento_database_endpoint" {
  value = aws_db_instance.sgr-pagamento-database
}
