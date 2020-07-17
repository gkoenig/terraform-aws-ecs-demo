region    = "eu-central-1"
namespace = "Scigility"
stage     = "aws-cicd-demo"
tags = {
  "Customer"  = "Scigility"
  "Requestor" = "gkoenig"
}
###
app_port = 8000
container_image = "gkoenig/simplehttp:latest"
container_name = "simplehttp"
ecs_launch_type = "FARGATE"
network_mode = "awsvpc"

ignore_changes_task_definition = true
assign_public_ip = true
propagate_tags = "TASK_DEFINITION"
deployment_minimum_healthy_percent = 100
deployment_maximum_percent = 200
deployment_controller_type = "ECS"
desired_count = 1
task_memory = 512
task_cpu = 256
container_memory = 256
container_memory_reservation = 128
container_cpu = 256
container_essential = true
container_readonly_root_filesystem = false

container_environment = [
  {
    name  = "message"
    value = "Hi from CI/CD demo"
  }
]

container_port_mappings = [
  {
    containerPort = 8000
    hostPort      = 8000
    protocol      = "tcp"
  }
]