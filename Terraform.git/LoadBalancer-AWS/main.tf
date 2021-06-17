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

resource "aws_security_group" "http-sg" {
  name = "HTTP"
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

resource "aws_instance" "elb_instance1" {
  ami                    = "ami-0d8d212151031f51c"
  instance_type          = "t2.micro"
  availability_zone      = "us-east-2a"
  vpc_security_group_ids = [aws_security_group.http-sg.id]
  user_data              = file("deploy-site-httpd-1.sh")

  tags = {
    Name = "ELB-Web server-1"
  }
}

resource "aws_instance" "elb_instance2" {
  ami                    = "ami-0d8d212151031f51c"
  instance_type          = "t2.micro"
  availability_zone      = "us-east-2b"
  vpc_security_group_ids = [aws_security_group.http-sg.id]
  user_data              = file("deploy-site-httpd-2.sh")

  tags = {
    Name = "ELB-Web server-2"
  }
}

resource "aws_elb" "elb_webservers" {
  name               = "ELB-WebServers"
  availability_zones = ["us-east-2a", "us-east-2b"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  instances                   = [aws_instance.elb_instance1.id, aws_instance.elb_instance2.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "ELB-WebServers"
  }
}

