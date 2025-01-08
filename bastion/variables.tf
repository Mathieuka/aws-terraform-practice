variable "ami_id" {
  type        = string
  description = "The ID of the AMI to use for the Bastion instance"
}

variable "instance_type" {
  type        = string
  description = "The EC2 instance type to use"
  default     = "t2.micro"
}

variable "security_group_id" {
  type        = string
  description = "The ID of the security group to associate with the Bastion instance"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet to deploy the Bastion instance in"
}

variable "iam_instance_profile_name" {
  type        = string
  description = "The name of the IAM instance profile to associate with the Bastion instance"
}
