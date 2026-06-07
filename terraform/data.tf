data "aws_caller_identity" "current" {}

data "aws_vpc" "default" {
  count   = var.vpc_id == "" ? 1 : 0
  default = true
}

data "aws_subnets" "default" {
  count = var.subnet_id == "" ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}

locals {
  vpc_id    = var.vpc_id != "" ? var.vpc_id : data.aws_vpc.default[0].id
  subnet_id = var.subnet_id != "" ? var.subnet_id : data.aws_subnets.default[0].ids[0]
}
