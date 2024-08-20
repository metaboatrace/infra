data "aws_ssm_parameter" "database_username" {
  name = "/${var.project}/origin-data/${var.env}/db/username"
}

data "aws_ssm_parameter" "database_password" {
  name            = "/${var.project}/origin-data/${var.env}/db/password"
  with_decryption = true
}

resource "aws_db_subnet_group" "aurora" {
  name       = "${var.project}-${var.env}-aurora-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Env     = var.env
    Project = var.project
    Name    = "${var.project}-${var.env}-aurora-subnet-group"
  }
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "${var.project}-${var.env}-aurora-cluster"
  availability_zones      = var.availability_zones
  engine                  = "aurora-postgresql"
  engine_version          = "16.1"
  engine_mode             = "serverless"
  database_name           = var.database_name
  master_username         = data.aws_ssm_parameter.database_username.value
  master_password         = data.aws_ssm_parameter.database_password.value
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  db_subnet_group_name    = aws_db_subnet_group.aurora.name
  vpc_security_group_ids  = [var.aurora_security_group_id]
  skip_final_snapshot     = true
  storage_encrypted       = false

  scaling_configuration {
    auto_pause               = true
    max_capacity             = 2
    min_capacity             = 1
    seconds_until_auto_pause = 300
  }

  tags = {
    Env     = var.env
    Project = var.project
    Name    = "${var.project}-${var.env}-aurora-cluster"
  }
}

resource "aws_rds_cluster_instance" "aurora" {
  count              = var.aurora_cluster_instance_size
  identifier         = "${var.project}-${var.env}-aurora-instance-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version
  apply_immediately  = true

  tags = {
    Env     = var.env
    Project = var.project
    Name    = "${var.project}-${var.env}-aurora-instance"
  }
}
