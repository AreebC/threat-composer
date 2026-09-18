# ECS cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"

  tags = {
    Name = "${var.project_name}-${var.environment}-cluster"
  }
}

# ECS security group
# ECS accepts application traffic only from the
# Application Load Balancer security group.

resource "aws_security_group" "ecs" {
  name        = "${var.project_name}-${var.environment}-ecs-sg"
  description = "Controls traffic for ECS Fargate tasks"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow application traffic from the ALB"

    from_port = var.application_port
    to_port   = var.application_port
    protocol  = "tcp"

    security_groups = [
      var.alb_security_group_id
    ]
  }

  egress {
    description = "Allow outbound traffic from ECS tasks"

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ecs-sg"
  }
}

# CloudWatch log group
# Container logs will be sent here by the ECS task.

resource "aws_cloudwatch_log_group" "ecs" {
  name = "/ecs/${var.project_name}-${var.environment}"

  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-${var.environment}-logs"
  }
}

# ECS task execution role
# ECS uses this role to:
# - Pull the Docker image from ECR
# - Send container logs to CloudWatch
resource "aws_iam_role" "ecs_execution" {
  name = "${var.project_name}-${var.environment}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-ecs-execution-role"
  }
}

# Attach the standard AWS ECS execution policy
resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role = aws_iam_role.ecs_execution.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS task definition
# The task definition describes the container that Fargate should run.
resource "aws_ecs_task_definition" "main" {
  family = "${var.project_name}-${var.environment}"

  requires_compatibilities = [
    "FARGATE"
  ]

  network_mode = "awsvpc"

  cpu    = var.task_cpu
  memory = var.task_memory

  execution_role_arn = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([
    {
      name  = var.container_name
      image = var.container_image

      essential = true

      portMappings = [
        {
          containerPort = var.application_port
          hostPort      = var.application_port
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-${var.environment}-task"
  }
}

# ECS Fargate service
# The service keeps the requested number of application containers running.
resource "aws_ecs_service" "main" {
  name    = "${var.project_name}-${var.environment}-service"
  cluster = aws_ecs_cluster.main.id

  task_definition = aws_ecs_task_definition.main.arn

  desired_count = var.desired_task_count

  launch_type = "FARGATE"

  network_configuration {
    subnets = var.public_subnet_ids

    security_groups = [
      aws_security_group.ecs.id
    ]

    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_arn

    container_name = var.container_name
    container_port = var.application_port
  }

  health_check_grace_period_seconds = 60

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-service"
  }
}