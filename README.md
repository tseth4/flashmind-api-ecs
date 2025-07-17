# FlashMind API Infrastructure

Terraform configuration for deploying FlashMind API on AWS ECS with RDS.

## Setup

1. Copy `terraform.tfvars.example` to `terraform.tfvars`
2. Fill in your actual values
3. Run `terraform init && terraform apply`

## Architecture

- ECS Fargate with ALB
- RDS PostgreSQL
- Secrets Manager for Firebase credentials
- VPC with public/private subnets