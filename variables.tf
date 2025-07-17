variable "db_name" {
  description = "The name of the Postgres database"
  type        = string
}

variable "db_user" {
  description = "The master username for RDS"
  type        = string
}

variable "db_password" {
  description = "The master password for RDS"
  type        = string
  sensitive   = true
}

variable "django_superuser_username" {
  type        = string
  description = "Username for the Django admin"
}

variable "django_superuser_email" {
  type        = string
  description = "Email for the Django admin"
}

variable "django_superuser_password" {
  type      = string
  sensitive = true
}

variable "django_secret_key" {
  description = "Django secret key for production."
  type        = string
  sensitive   = true
}

variable "django_allowed_hosts" {
  description = "Comma-separated list of allowed hosts for Django."
  type        = string
}

variable "cors_allowed_origins" {
  description = "Comma-separated list of allowed CORS origins."
  type        = string
}

variable "key_name" {
  description = "he name of the EC2 key pair (not needed for ECS Fargate)"
  type        = string
}

variable "firebase_admin_json_path" {
  description = "Path to the local firebase_admin.json file."
  type        = string
}


# variable "flashmind_mvp_instance_name" {
#   description = "Value of the EC2 instance's Name tag."
#   type        = string
#   default     = "flashmind-mvp"
# }

# variable "flashmind_mvp_instance_type" {
#   description = "The EC2 instance's type."
#   type        = string
#   default     = "t2.micro"
# }

# variable "key_name" {
#   description = "The name of the EC2 key pair to use for SSH"
#   type        = string
# }
