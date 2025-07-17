
# Creates an IAM Role that ECS tasks are allowed to assume
# Needed to give your containers permissions to do AWS stuff (like pull from ECR, log to CloudWatch)
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "flashmind-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      # Principal = "ecs-tasks.amazonaws.com" → only ECS can assume this role
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}
# Attaches the AWS-managed policy: AmazonECSTaskExecutionRolePolicy
# This gives the ECS task permission to:
# Pull container images from ECR
# Write logs to CloudWatch Logs
# (If needed) use Secrets Manager or SSM Parameters
resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "secretsmanager_get_firebase_admin" {
  name        = "secretsmanager-get-firebase-admin"
  description = "Allow ECS task to get firebase_admin_json secret"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = aws_secretsmanager_secret.firebase_admin.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_secretsmanager_firebase_admin" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.secretsmanager_get_firebase_admin.arn
}