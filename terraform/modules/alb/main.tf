# -------------------------------------------------------
# ALB security group
#
# Allows users on the internet to connect to the
# Application Load Balancer using HTTP.
# -------------------------------------------------------

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Controls traffic for the Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP from the internet"

    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow traffic from the ALB to the application"

    from_port = var.application_port
    to_port   = var.application_port
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-alb-sg"
  }
}


# -------------------------------------------------------
# Application Load Balancer
#
# The ALB is internet-facing and runs across the two
# public subnets created by the VPC module.
# -------------------------------------------------------

resource "aws_lb" "main" {
  name = "${var.project_name}-${var.environment}-alb"

  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = var.public_subnet_ids

  # This is false for a portfolio/dev environment so the
  # ALB can be destroyed easily using Terraform.
  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-${var.environment}-alb"
  }
}


# -------------------------------------------------------
# Target group
#
# The target group tells the ALB where to send requests.
# ECS Fargate tasks will register with this target group.
# -------------------------------------------------------

resource "aws_lb_target_group" "main" {
  name = "${var.project_name}-${var.environment}-tg"

  port     = var.application_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  # Fargate tasks use their own private IP addresses.
  target_type = "ip"

  health_check {
    enabled = true

    path     = "/health"
    port     = "traffic-port"
    protocol = "HTTP"

    healthy_threshold   = 2
    unhealthy_threshold = 3

    interval = 30
    timeout  = 5

    matcher = "200"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-tg"
  }
}


# -------------------------------------------------------
# HTTP listener
#
# The listener receives requests on port 80 and forwards
# them to the target group.
# -------------------------------------------------------

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"

  certificate_arn = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}