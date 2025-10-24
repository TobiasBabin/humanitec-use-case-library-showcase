variable "gcp_project_id" {
  description = "GCP project ID"
  nullable    = false
}
variable "gcp_region" {
  description = "GCP region"
  nullable    = false
}
variable "orchestrator_org" {
  description = "Platform Orchestrator organization ID"
  nullable    = false
}
variable "orchestrator_auth_token" {
  description = "Platform Orchestrator auth token"
  sensitive   = true
}
