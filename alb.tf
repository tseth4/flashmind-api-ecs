# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "flashmind-alb-sg"
  description = "Allow HTTP and HTTPS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

# ALB
resource "aws_lb" "flashmind" {
  name               = "flashmind-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id
}

# Target group for ECS
resource "aws_lb_target_group" "flashmind_tg" {
  name     = "flashmind-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }

  target_type = "ip"
}

# HTTP Listener
resource "aws_lb_listener" "flashmind_http" {
  load_balancer_arn = aws_lb.flashmind.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flashmind_tg.arn
  }
}
