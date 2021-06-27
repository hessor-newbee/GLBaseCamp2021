terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  profile = var.profile
  region  = var.region
}

resource "aws_instance" "base" {
  ami                    = "ami-0d8d212151031f51c"
  instance_type          = "t2.micro"
  count                  = 2
  vpc_security_group_ids = [aws_security_group.http-sg.id]
  user_data              = file("apache.sh")
  tags = {
    Name = "ALB-instance"
  }
}

resource "aws_security_group" "http-sg" {
  name   = "HTTP"
  vpc_id = aws_default_vpc.default.id
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
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

data "aws_subnet_ids" "subnet" {
  vpc_id = aws_default_vpc.default.id
}

resource "aws_alb_target_group" "alb-target-group" {
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
  name        = "alb-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_default_vpc.default.id
}

resource "aws_lb" "alb" {
  name            = "ALB"
  security_groups = ["${aws_security_group.http-sg.id}"]
  internal        = false
  tags = {
    Name = "ALB"
  }
  subnets            = data.aws_subnet_ids.subnet.ids
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
}

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.alb-target-group.arn
    type             = "forward"
  }
}

resource "aws_alb_target_group_attachment" "ec2_attach" {
  count            = length(aws_instance.base)
  target_group_arn = aws_alb_target_group.alb-target-group.arn
  target_id        = aws_instance.base[count.index].id
}

