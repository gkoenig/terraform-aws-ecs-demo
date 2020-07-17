provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "scigility-terraform-remote-state"
    key            = "awscicddemo/ecs-services/cicd/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "scigility-terraform-remote-state-locks"
    encrypt        = true
  }
}

resource "aws_ecr_repository" "ecr_repo" {
  name                 = "${var.stage}${var.delimiter}container-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = var.tags
}

resource "aws_codecommit_repository" "code_repo" {
  repository_name = "${var.stage}${var.delimiter}code-repo"
  tags = var.tags
}
