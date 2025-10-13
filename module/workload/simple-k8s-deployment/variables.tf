variable "prefix" {
  description = "Naming prefix for all resources"
  nullable    = false
}
variable "project_id" {
  description = "The Orchestrator project ID to which to map the module through a module rule"
  nullable    = false
}
