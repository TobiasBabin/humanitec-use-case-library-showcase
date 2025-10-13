output "project_id" {
  value = module.project.project_id
}
output "resource_type_workload" {
  value = module.workload.resource_type_workload
}
output "resource_type_postgres" {
  value = module.postgres.resource_type_postgres_instance
}
output "k8s_connect_command" {
  value = module.base_infra.k8s_connect_command
}
output "workload_name" {
  value = module.workload.workload_name
}