provider "aws" {
  region = var.region
}

module "vpc" {
  source     = "git@github.com:scigility/tf-aws-core-infra.git//vpc"
  namespace  = var.namespace
  stage      = var.stage
  cidr_block = "172.16.0.0/16"
  tags       = var.tags
}

module "subnets" {
  source             = "git@github.com:scigility/tf-aws-core-infra.git//subnets"
  vpc_id             = module.vpc.vpc_id
  igw_id             = module.vpc.igw_id
  cidr_block         = module.vpc.vpc_cidr_block
  namespace          = var.namespace
  stage              = var.stage
  type               = "public"
  availability_zones = ["eu-central-1a", "eu-central-1b"]
  tags               = var.tags
}

resource "aws_security_group" "alb" {
  name   = "${var.namespace}${var.delimiter}${var.stage}${var.delimiter}-alb-secgroup"
  vpc_id = module.vpc.vpc_id

  # default: we only let http port 80 through the ALB
  ingress {
    protocol         = "tcp"
    from_port        = var.app_port
    to_port          = var.app_port
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

module "alb" {
  source = "git@github.com:scigility/tf-aws-core-infra.git//alb"

  namespace          = var.namespace
  stage              = var.stage
  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = values(module.subnets.az_subnet_ids)
  security_groups = [aws_security_group.alb.id]

  target_groups = [
    {
      backend_protocol = "HTTP"
      backend_port     = var.app_port
      target_type      = "ip"
    }
  ]

  http_tcp_listeners = [
    {
      port               = var.app_port
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = var.tags
}


