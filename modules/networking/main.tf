resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Env     = var.env
    Project = var.project
    Name    = "${var.project}-${var.env}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Env     = var.env
    Project = var.project
    Name    = "${var.project}-${var.env}-igw"
  }
}

resource "aws_subnet" "public" {
  for_each          = var.availability_zones
  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 8, 0 + each.value.order)

  tags = {
    Env     = var.env
    Project = var.project
    Name    = "${var.project}-${var.env}-public-${each.value.id}"
  }
}

resource "aws_subnet" "private" {
  for_each          = var.availability_zones
  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 8, 100 + each.value.order)

  tags = {
    Env     = var.env
    Project = var.project
    Name    = "${var.project}-${var.env}-private-${each.value.id}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Env     = var.env
    Project = var.project
    Name    = "${var.project}-${var.env}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element([for nat in aws_nat_gateway.nat : nat.id], 0)
  }

  tags = {
    Env     = var.env
    Project = var.project
    Name    = "${var.project}-${var.env}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_eip" "nat" {
  for_each = var.availability_zones
  domain   = "vpc"

  tags = {
    Env     = var.env
    Project = var.project
    Name    = "${var.project}-${var.env}-eip-${each.value.id}"
  }
}

resource "aws_nat_gateway" "nat" {
  for_each      = var.availability_zones
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = {
    Env     = var.env
    Project = var.project
    Name    = "${var.project}-${var.env}-nat-${each.value.id}"
  }
}

resource "aws_security_group" "aurora" {
  vpc_id = aws_vpc.this.id

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
    Env     = var.env
    Project = var.project
    Name    = "${var.project}-${var.env}-aurora-sg"
  }
}

resource "aws_security_group" "alb" {
  vpc_id = aws_vpc.this.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Env     = var.env
    Project = var.project
    Name    = "${var.project}-${var.env}-alb-sg"
  }
}

resource "aws_security_group" "crawler" {
  name        = "${var.project}-crawler"
  description = "Security group for Frontend Fargate tasks"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    from_port   = 5555
    to_port     = 5555
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Env     = var.env
    Project = var.project
    Name    = "${var.project}-${var.env}-crawler-sg"
  }
}
