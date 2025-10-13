# Create a resource type
resource "platform-orchestrator_resource_type" "postgres_instance" {
  id                      = "${var.prefix}-postgres-instance"
  description             = "Postgres instance for the temporary use case ${var.prefix}"
  is_developer_accessible = true
  output_schema = jsonencode({
    type = "object"
    properties = {
      host = {
        type = "string"
      }
      port = {
        type = "integer"
      }
      database = {
        type = "string"
      }
      username = {
        type = "string"
      }
      password = {
        type = "string"
      }
    }
  })
}

# Create a provider
resource "platform-orchestrator_provider" "aws" {
  id                 = "${var.prefix}-aws"
  description        = "aws provider for the temporary use case ${var.prefix}"
  provider_type      = "aws"
  source             = "hashicorp/aws"
  version_constraint = "~> 6"
  configuration      = var.provider_configuration
}

# Create a module
resource "platform-orchestrator_module" "postgres_instance" {
  id            = "${var.prefix}-postgres-instance"
  description   = "Simple cloud-based Postgres instance"
  resource_type = platform-orchestrator_resource_type.postgres_instance.id
  module_source = "git::https://github.com/humanitec-tutorials/get-started//modules/postgres/aws" # TODO - move into use case repo or make inline
  provider_mapping = {
    aws = "${platform-orchestrator_provider.aws.provider_type}.${platform-orchestrator_provider.aws.id}"
  }
}

# Create a module rule making the module applicable to the demo project
resource "platform-orchestrator_module_rule" "postgres_instance" {
  module_id  = platform-orchestrator_module.postgres_instance.id
  project_id = var.project_id
}