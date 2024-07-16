data "aws_ssm_parameter" "database_username" {
  name = "/${var.env}/database-username"
}

data "aws_ssm_parameter" "database_password" {
  name            = "/${var.env}/database-password"
  with_decryption = true
}

resource "aws_security_group" "aurora_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}-aurora-sg"
  }
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "${var.project}-${var.env}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project}-${var.env}-db-subnet-group"
  }
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "${var.project}-${var.env}-aurora-cluster"
  engine                  = "aurora-postgresql"
  engine_version          = "16.1"
  engine_mode             = "serverless"
  database_name           = var.database_name
  master_username         = data.aws_ssm_parameter.database_username.value
  master_password         = data.aws_ssm_parameter.database_password.value
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.aurora_sg.id]

  scaling_configuration {
    auto_pause               = true
    max_capacity             = 2
    min_capacity             = 1
    seconds_until_auto_pause = 300
  }

  tags = {
    Name = "${var.project}-${var.env}-aurora-cluster"
  }
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  identifier           = "${var.project}-${var.env}-aurora-instance"
  cluster_identifier   = aws_rds_cluster.aurora.id
  instance_class       = "db.serverless"
  engine               = aws_rds_cluster.aurora.engine
  engine_version       = aws_rds_cluster.aurora.engine_version
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name
  apply_immediately    = true

  tags = {
    Name = "${var.project}-${var.env}-aurora-instance"
  }
}
