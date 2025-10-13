locals {
  workload_name = var.prefix
}

# Create a simple workload resource type with an empty output schema
resource "platform-orchestrator_resource_type" "k8s_workload" {
  id          = "${var.prefix}-k8s-workload"
  description = "Kubernetes workload for for the temporary use case ${var.prefix}"
  output_schema = jsonencode({
    type       = "object"
    properties = {}
  })
  is_developer_accessible = true
}

# Create a module, setting values for the module variables
resource "platform-orchestrator_module" "k8s_workload" {
  id            = "${var.prefix}-k8s-workload"
  description   = "Simple Kubernetes Deployment in default namespace"
  resource_type = platform-orchestrator_resource_type.k8s_workload.id
  module_source = "git::https://github.com/humanitec-tutorials/get-started//modules/workload/kubernetes" # TODO - move into use case repo or make inline

  module_params = {
    image = {
      type        = "string"
      description = "The image to use for the container"
    }
    variables = {
      type        = "map"
      is_optional = true
      description = "Container environment variables"
    }
  }
  module_inputs = jsonencode({
    name      = local.workload_name
    namespace = "default"
  })
}

# Create a module rule making the module applicable to the demo project
resource "platform-orchestrator_module_rule" "k8s_workload" {
  module_id  = platform-orchestrator_module.k8s_workload.id
  project_id = var.project_id
}
