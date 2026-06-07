variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Root domain name for the static frontend (e.g. encrypto.link). The API backend is served from api.<domain_name>"
  type        = string
  default     = "encrypto.link"
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID that owns domain_name"
  type        = string
}

variable "ecr_repo_name" {
  description = "Name of the ECR repository that stores the encrypto backend image"
  type        = string
  default     = "encrypto_repository"
}

variable "ec2_ami" {
  description = "AMI ID for the backend EC2 instance"
  type        = string
  default     = "ami-03c7d01cf4dedc891"
}

variable "ec2_instance_type" {
  description = "Instance type for the backend EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "ec2_key_pair_name" {
  description = "Name of an existing EC2 key pair used for SSH access to the backend instance"
  type        = string
  default     = "encrypto-ed.pem"
}

variable "vpc_id" {
  description = "VPC ID to deploy the backend instance into. Leave empty to use the account's default VPC"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet ID to deploy the backend instance into. Leave empty to use a subnet from the default VPC"
  type        = string
  default     = ""
}
