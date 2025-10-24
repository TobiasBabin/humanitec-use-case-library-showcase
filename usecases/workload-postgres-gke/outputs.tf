output "project_id" {
  value       = module.project.project_id
  description = "The Orchestrator project ID that was created"
}
output "k8s_connect_command" {
  value = "gcloud container clusters get-credentials ${module.gke.name} --region ${var.gcp_region} --project ${var.gcp_project_id}"
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