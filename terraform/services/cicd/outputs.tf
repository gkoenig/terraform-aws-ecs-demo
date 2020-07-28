output "ECR_repo_URL" {
  value = aws_ecr_repository.ecr_repo.repository_url
}
output "ECR_repo_ARN" {
  value = aws_ecr_repository.ecr_repo.arn
}
output "ECR_registry_id" {
  value = aws_ecr_repository.ecr_repo.registry_id
}

output "CodeCommit_repo_id" {
  value = aws_codecommit_repository.code_repo.repository_id
}
output "CodeCommit_repo_arn" {
  value = aws_codecommit_repository.code_repo.arn
}
output "tags" {
  value = var.tags
}
