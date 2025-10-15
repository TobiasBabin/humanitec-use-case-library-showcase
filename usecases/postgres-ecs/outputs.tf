output "project_id" {
  value = module.project.project_id
  description = "The Orchestrator project ID that was created"
}
output "resource_type_postgres" {
  value       = module.postgres.resource_type_postgres_instance
  description = "The name of the postgres resource type"
}