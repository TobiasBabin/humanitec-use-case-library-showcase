output "resource_type_workload" {
  value = platform-orchestrator_resource_type.k8s_workload.id
}
output "workload_name" {
  value = local.workload_name
}