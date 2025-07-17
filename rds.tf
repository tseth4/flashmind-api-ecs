# When I create my RDS database, use private subnets to place the DB
resource "aws_db_subnet_group" "flashmind" {
  name       = "flashmind-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "flashmind-db-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  name        = "flashmind-rds-sg"
  description = "Allow ECS access to RDS"
  vpc_id      = aws_vpc.main.id
  # Allows traffic on port 5432 (PostgreSQL default port)
  # Only from resources in the flashmind-ecs security group
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }
  # The DB instance is allowed to send outbound traffic anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "flashmind-rds-sg"
  }
}

resource "aws_db_instance" "flashmind" {
  identifier             = "flashmind-db"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16.6"
  instance_class         = "db.t3.micro"
  username               = var.db_user
  password               = var.db_password
  db_name                = var.db_name
  db_subnet_group_name   = aws_db_subnet_group.flashmind.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false
  storage_encrypted      = false

  tags = {
    Name = "flashmind-rds"
  }
}
