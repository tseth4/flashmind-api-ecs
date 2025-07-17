# resource "aws_security_group" "flashmind_mvp_sg" {
#   name        = "flashmind-mvp-sg"
#   description = "Allow SSH, HTTP, and HTTPS for Flashmind MVP"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     description = "Allow SSH from anywhere"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["172.56.106.190/32"]
#   }

#   ingress {
#     description = "Allow HTTP"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     description = "Allow HTTPS"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     description = "Allow all outbound"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "flashmind-mvp-sg"
#   }
# }
