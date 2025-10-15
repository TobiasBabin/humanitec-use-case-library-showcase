variable "prefix" {
  description = "Naming prefix for all resources"
  nullable    = false
}
variable "provider_configuration" {
  description = "JSON encoded aws provider configuration. Defaults to empty config"
  nullable    = false
}
variable "project_id" {
  description = "The Orchestrator project ID to which to map the module through a module rule"
  nullable    = false
}
variable "runner_iam_role_name" {
  description = "Name of the IAM role used by the runner. Required to set up proper permissions"
  nullable    = false
}
