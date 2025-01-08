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

module "vpc" {
  source      = "./vpc"
  vpc_cidr    = "10.0.0.0/16"
  subnet_cidr = "10.0.1.0/24"
}

module "security" {
  source = "./security"
  vpc_id = module.vpc.vpc_id
}

module "iam" {
  source = "./iam"
}

module "bastion" {
  source                   = "./bastion"
  ami_id                   = "ami-01816d07b1128cd2d"
  instance_type            = "t2.micro"
  security_group_id        = module.security.security_group_id
  subnet_id                = module.vpc.subnet_id
  iam_instance_profile_name = module.iam.instance_profile_name
}
