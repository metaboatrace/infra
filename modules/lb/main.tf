resource "aws_lb" "this" {
  name               = "${var.project}-${var.env}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  tags = {
    Env     = var.env
    Project = var.project
    Name    = "${var.project}-${var.env}-alb"
  }
}

resource "aws_lb_target_group" "crawler" {
  name     = "${var.project}-${var.env}-crawler-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Env     = var.env
    Project = var.project
    Name    = "${var.project}-${var.env}-tg"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.crawler.arn
  }

  tags = {
    Env     = var.env
    Project = var.project
    Name    = "${var.project}-${var.env}-crawler-http-listener"
  }
}
