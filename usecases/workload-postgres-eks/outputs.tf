output "project_id" {
  value       = module.project.project_id
  description = "The Orchestrator project ID that was created"
}
output "subnet_ids" {
  value       = module.base_infra.subnet_ids
  description = "The list of subnet IDs that were created"
}
output "k8s_connect_command" {
  value       = module.base_infra.k8s_connect_command
  description = "The command to obtain the kube context for the created K8s cluster"
}
output "resource_type_workload" {
  value       = module.workload.resource_type_workload
  description = "The name of the workload resource type"
}
output "resource_type_postgres" {
  value       = module.postgres.resource_type_postgres_instance
  description = "The name of the postgres resource type"
}
output "workload_name" {
  value = module.workload.workload_name
}