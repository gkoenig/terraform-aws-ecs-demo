resource "aws_ecs_cluster" "default" {
  name = "${var.namespace}${var.delimiter}${var.stage}${var.delimiter}-ecs-democluster"
  tags = var.tags
}

resource "aws_security_group" "task-sg" {
  name   = "${var.namespace}${var.delimiter}${var.stage}${var.delimiter}-task-secgroup"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol         = "tcp"
    from_port        = var.app_port
    to_port          = var.app_port
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
  }
}


module "container_definition" {
  source                       = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git?ref=tags/0.21.0"
  container_name               = var.container_name
  container_image              = var.container_image
  container_memory             = var.container_memory
  container_memory_reservation = var.container_memory_reservation
  container_cpu                = var.container_cpu
  essential                    = var.container_essential
  readonly_root_filesystem     = var.container_readonly_root_filesystem
  environment                  = var.container_environment
  port_mappings                = var.container_port_mappings
}

module "ecs_alb_service_task" {
  source                             = "git::https://github.com/cloudposse/terraform-aws-ecs-alb-service-task.git?ref=tags/0.32.0"
  namespace                          = var.namespace
  stage                              = var.stage
  name                               = "cicd-demo-task"
  delimiter                          = var.delimiter
  alb_security_group                 = aws_security_group.task-sg.id
  container_definition_json          = module.container_definition.json
  ecs_cluster_arn                    = aws_ecs_cluster.default.arn
  launch_type                        = var.ecs_launch_type
  vpc_id                             = module.vpc.vpc_id
  security_group_ids                 = [aws_security_group.task-sg.id]
  subnet_ids                         = values(module.subnets.az_subnet_ids)
  tags                               = var.tags
  ignore_changes_task_definition     = var.ignore_changes_task_definition
  network_mode                       = var.network_mode
  assign_public_ip                   = var.assign_public_ip
  propagate_tags                     = var.propagate_tags
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_controller_type         = var.deployment_controller_type
  desired_count                      = var.desired_count
  task_memory                        = var.task_memory
  task_cpu                           = var.task_cpu
  ecs_load_balancers                 = [ {
      target_group_arn = length(module.alb.target_group_arns) == 0 ? "" : module.alb.target_group_arns[0]
      container_name = var.container_name
      container_port = var.app_port
      elb_name       = ""
    } 
  ]
}