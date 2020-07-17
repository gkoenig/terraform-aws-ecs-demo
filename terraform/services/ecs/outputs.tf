output "ecs_service" {
  value = module.ecs_alb_service_task.service_name
}
output "task_role" {
  value = module.ecs_alb_service_task.task_role_name
}
output "task_role_arn" {
  value = module.ecs_alb_service_task.task_role_arn
}
output "task_exec_role" {
  value = module.ecs_alb_service_task.task_exec_role_name
}
output "task_exec_role_arn" {
  value = module.ecs_alb_service_task.task_exec_role_arn
}

output "loadbalancer_dns" {
  value = module.alb.this_lb_dns_name
}

