resource "aws_ecr_repository" "crawler_proxy" {
  name                 = "${var.project}-crawler-proxy-ecr"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project = var.project
    Name    = "${var.project}-crawler-proxy-ecr"
  }
}

resource "aws_ecr_repository" "crawler_app" {
  name                 = "${var.project}-crawler-app-ecr"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project = var.project
    Name    = "${var.project}-crawler-app-ecr"
  }
}

locals {
  lifecycle_policy = {
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 5 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  }
}

resource "aws_ecr_lifecycle_policy" "crawler_proxy" {
  repository = aws_ecr_repository.crawler_proxy.name

  policy = jsonencode(local.lifecycle_policy)
}

resource "aws_ecr_lifecycle_policy" "crawler_app" {
  repository = aws_ecr_repository.crawler_app.name

  policy = jsonencode(local.lifecycle_policy)
}

resource "aws_ecs_cluster" "this" {
  name = "${var.project}-${var.env}-ecs-cluster"

  tags = {
    Env     = var.env
    Project = var.project
    Name    = "${var.project}-ecs-cluster"
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name = "/ecs/${var.project}-${var.env}"
}

resource "aws_ecs_service" "crawler" {
  name                   = "${var.project}-${var.env}-crawler-ecs-service"
  cluster                = aws_ecs_cluster.this.id
  task_definition        = aws_ecs_task_definition.crawler.arn
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.crawler_security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.crawler_target_group_arn
    container_name   = "crawler-proxy"
    container_port   = 80
  }

  desired_count = 1

  tags = {
    Env     = var.env
    Project = var.project
    Name    = "${var.project}-${var.env}-crawler-ecs-service"
  }
}

resource "aws_ecs_task_definition" "crawler" {
  family                   = "${var.project}-${var.env}-crawler-ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.crawler_ecs_task_cpu
  memory                   = var.crawler_ecs_task_memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "crawler-proxy"
      image     = "nginx:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = "ap-northeast-1"
          awslogs-stream-prefix = "crawler-proxy"
        }
      }
    }
  ])
}
