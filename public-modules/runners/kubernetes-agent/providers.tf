terraform {
  required_providers {
    # Platform Orchestrator provider for registering the runner
    platform-orchestrator = {
      source  = "humanitec/platform-orchestrator"
      version = "~> 2"
    }
    # Provider for installing the runner Helm chart
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3"
    }
    # Provider for installing K8s objects for the runner
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2"
    }
  }
}