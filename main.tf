terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}


provider "aws" {
  region = "us-east-1"
}

resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion_key_pair" {
  key_name   = "bastion_key_pair"
  public_key = tls_private_key.bastion_key.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.bastion_key.private_key_pem
  filename = "bastion_key.pem"
}


resource "aws_instance" "bastion" {
  ami           = "ami-01816d07b1128cd2d"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.bastion_key_pair.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  tags = {
    Name = "Bastion"
  }
}

resource "aws_iam_role" "ec2_instance_role" {
  name        = "EC2Instance"
  description = "Allows EC2 instances to call AWS services like CloudWatch and Systems Manager on your behalf."
  path        = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns   = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  max_session_duration  = 3600
  force_detach_policies = false
  permissions_boundary  = null

  tags = {}
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2InstanceProfile"
  role = aws_iam_role.ec2_instance_role.name
}


