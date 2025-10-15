output "runner_id" {
  value = platform-orchestrator_kubernetes_agent_runner.runner.id
}
output "runner_aws_iam_role_name" {
  value = aws_iam_role.agent_runner_irsa_role[0].name
  description = "Name of the IAM role created for the runner. Applies to AWS only"
}