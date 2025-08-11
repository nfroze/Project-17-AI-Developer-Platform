# ECS Cluster for Cost Tracker
resource "aws_ecs_cluster" "cost_tracker" {
  name = "${var.cluster_name}-ecs"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Service     = "gpu-cost-tracker"
    Platform    = "ecs-fargate"
    Environment = var.environment
  }
}

# Task Definition
resource "aws_ecs_task_definition" "cost_tracker" {
  family                   = "gpu-cost-tracker"
  network_mode            = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                     = "256"
  memory                  = "512"
  execution_role_arn      = aws_iam_role.ecs_execution.arn
  task_role_arn           = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name  = "cost-tracker"
      image = "${aws_ecr_repository.cost_tracker.repository_url}:latest"
      
      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]
      
      environment = [
        {
          name  = "NODE_ENV"
          value = "production"
        },
        {
          name  = "EKS_CLUSTER_NAME"
          value = var.cluster_name
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/gpu-cost-tracker"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "cost_tracker" {
  name            = "gpu-cost-tracker"
  cluster         = aws_ecs_cluster.cost_tracker.id
  task_definition = aws_ecs_task_definition.cost_tracker.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.cost_tracker.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.cost_tracker.arn
    container_name   = "cost-tracker"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.cost_tracker]
}

# Application Load Balancer
resource "aws_lb" "cost_tracker" {
  name               = "${var.cluster_name}-cost-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets           = module.vpc.public_subnets

  tags = {
    Service     = "gpu-cost-tracker"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "cost_tracker" {
  name        = "${var.cluster_name}-cost-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }
}

resource "aws_lb_listener" "cost_tracker" {
  load_balancer_arn = aws_lb.cost_tracker.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cost_tracker.arn
  }
}

# Security Groups
resource "aws_security_group" "cost_tracker" {
  name_prefix = "${var.cluster_name}-ecs-sg-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-ecs-sg"
  }
}

resource "aws_security_group" "alb" {
  name_prefix = "${var.cluster_name}-alb-sg-"
  vpc_id      = module.vpc.vpc_id

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
    Name = "${var.cluster_name}-alb-sg"
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "cost_tracker" {
  name              = "/ecs/gpu-cost-tracker"
  retention_in_days = 1  # Minimal for demo
}

# IAM Roles
resource "aws_iam_role" "ecs_execution" {
  name = "${var.cluster_name}-ecs-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_execution_ecr" {
  name = "ecr-access"
  role = aws_iam_role.ecs_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task" {
  name = "${var.cluster_name}-ecs-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "ecs_eks_access" {
  name = "eks-readonly"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "*"
      }
    ]
  })
}