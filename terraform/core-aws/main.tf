provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "scigility-terraform-remote-state"
    key            = "awscicddemo/core-aws/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "scigility-terraform-remote-state-locks"
    encrypt        = true
  }
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



