variable "prefix" {
  description = "Naming prefix for all resources"
  nullable    = false
}
variable "runner_id" {
  description = "ID of the runner for which to create a runner rule"
  nullable = false
}