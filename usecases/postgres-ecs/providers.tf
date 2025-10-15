terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "~> 6"
    }
    platform-orchestrator = {
      source = "humanitec/platform-orchestrator"
      version = "~> 2"
    }
  }
}

# aws provider obtains authentication from local CLI
provider "aws" {
  region = var.aws_region
}

# Configure the Platform Orchestrator provider from a service user token
provider "platform-orchestrator" {
  org_id     = var.orchestrator_org
  auth_token = var.orchestrator_auth_token
  api_url    = "https://api.humanitec.dev"
}
