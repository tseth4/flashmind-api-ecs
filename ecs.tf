# Creates an ECS Cluster named flashmind-cluster.
resource "aws_ecs_cluster" "flashmind" {
  name = "flashmind-cluster"
}

resource "aws_ecs_task_definition" "flashmind" {
  # family = name of the task definition family (a way to group versions)
  family                   = "flashmind-task"
  requires_compatibilities = ["FARGATE"]
  # awsvpc = each task gets its own ENI (Elastic Network Interface) → needs subnet + SG
  network_mode       = "awsvpc"
  cpu                = "512"
  memory             = "1024"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn

  # You're running your own Docker image (tristansetha/flashmind:ecs), likely from Docker Hub.
  container_definitions = jsonencode([
    {
      name      = "flashmind"
      image     = "tristansetha/flashmind:ecs"
      essential = true
      # Because you're using awsvpc mode:
      # hostPort = containerPort is required
      # Port 8000 is exposed so the ALB can reach it
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]
      # You're injecting secrets and config values:
      # Django admin setup
      # Database connection details
      environment = [
        { name = "ENV", value = "production" },
        { name = "DJANGO_SECRET_KEY", value = var.django_secret_key },
        { name = "DJANGO_DEBUG", value = "True" },
        { name = "DJANGO_ALLOWED_HOSTS", value = var.django_allowed_hosts },
        { name = "FIREBASE_CRED", value = "secrets/firebase_admin.json" },
        { name = "DJANGO_SUPERUSER_USERNAME", value = var.django_superuser_username },
        { name = "DJANGO_SUPERUSER_EMAIL", value = var.django_superuser_email },
        { name = "DJANGO_SUPERUSER_PASSWORD", value = var.django_superuser_password },
        { name = "CORS_ALLOWED_ORIGINS", value = var.cors_allowed_origins },
        { name = "DATABASE_ENGINE", value = "django.db.backends.postgresql" },
        { name = "DATABASE_NAME", value = var.db_name },
        { name = "DATABASE_USER", value = var.db_user },
        { name = "DATABASE_PASSWORD", value = var.db_password },
        { name = "DATABASE_HOST", value = aws_db_instance.flashmind.address },
        { name = "DATABASE_PORT", value = "5432" },
        { name = "RUNNING_IN_ECS", value = "true" }
      ]
      secrets = [
        {
          name      = "FIREBASE_ADMIN_JSON"
          valueFrom = aws_secretsmanager_secret.firebase_admin.arn
        }
      ]
      # At container startup, write $FIREBASE_ADMIN_JSON to /app/secrets/firebase_admin.json
      # ... your environment and secrets blocks ...
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/flashmind"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
# This SG is attached to your ECS tasks via aws_ecs_service, and it controls:
# ingress/inbound and egress/outbound traffic
resource "aws_security_group" "ecs" {
  name        = "flashmind-ecs-sg"
  description = "Allow ECS to access RDS and ALB"
  vpc_id      = aws_vpc.main.id

  # Allow inbound traffic from ALB on port 8000
  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Allow all outbound (so ECS can reach RDS etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "flashmind-ecs"
  }
}

resource "aws_secretsmanager_secret" "firebase_admin" {
  name = "firebase_admin_json"
}

resource "aws_secretsmanager_secret_version" "firebase_admin" {
  secret_id     = aws_secretsmanager_secret.firebase_admin.id
  secret_string = file(var.firebase_admin_json_path)
}

resource "aws_ecs_service" "flashmind" {
  name            = "flashmind-service"
  cluster         = aws_ecs_cluster.flashmind.id
  task_definition = aws_ecs_task_definition.flashmind.arn
  launch_type     = "FARGATE"
  desired_count   = 2

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.flashmind_tg.arn
    container_name   = "flashmind"
    container_port   = 8000
  }

  depends_on = [
    aws_lb_listener.flashmind_http
  ]
}

resource "aws_cloudwatch_log_group" "ecs_flashmind" {
  name              = "/ecs/flashmind"
  retention_in_days = 14
}
