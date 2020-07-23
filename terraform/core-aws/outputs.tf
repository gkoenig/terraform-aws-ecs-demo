
output "public_az_subnet_ids" {
  value = module.subnets.az_subnet_ids
}
output "vpc_id" {
  value = module.vpc.vpc_id
}
output "internetgateway_id" {
  value = module.vpc.igw_id
}
output "tags" {
  value = var.tags
}


