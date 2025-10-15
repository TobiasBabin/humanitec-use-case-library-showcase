variable "aws_region" {
  description = "AWS region for resources"
  nullable    = false
}
variable "existing_oidc_provider_arn" {
  description = "The ARN of an existing OIDC provider to use"
  nullable    = true
}
variable "orchestrator_org" {
  description = "Platform Orchestrator organization ID"
  nullable    = false
}
variable "orchestrator_auth_token" {
  description = "Platform Orchestrator auth token"
}
