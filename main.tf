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

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "my-route-table"
  }
}


resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Main VPC"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id  = aws_vpc.main.id

  tags = {
    Name = "my-internet-gateway"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Main Subnet"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
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

resource "aws_security_group" "allow_ssh" {
  name   = "Allow SSH"
  vpc_id = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


resource "aws_instance" "bastion" {
  ami                    = "ami-01816d07b1128cd2d"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  subnet_id              = aws_subnet.main.id
  key_name               = aws_key_pair.bastion_key_pair.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  associate_public_ip_address = true
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


