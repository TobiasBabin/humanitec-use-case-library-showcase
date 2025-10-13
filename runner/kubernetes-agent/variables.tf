variable "prefix" {
  description = "Naming prefix for all resources"
  nullable    = false
}
variable "cloud_provider" {
  description = "The cloud provider for the target cluster"
  nullable    = false
  validation {
    condition     = contains(["aws", "gcp"], var.cloud_provider)
    error_message = "Cloud provider must be one of: aws, gcp"
  }
}
variable "orchestrator_org" {
  description = "Platform Orchestrator organization ID"
  nullable    = false
}
variable "eks_oidc_provider" {
  description = "OIDC provider when using EKS"
  default     = null
  nullable    = true
}
