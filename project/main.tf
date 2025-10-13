# Create a project
resource "platform-orchestrator_project" "project" {
  id = var.prefix
}

# Create a runner rule
resource "platform-orchestrator_runner_rule" "runner_rule" {
  runner_id  = var.runner_id
  project_id = platform-orchestrator_project.project.id
}

# Create an environment type
resource "platform-orchestrator_environment_type" "development" {
  id = "${var.prefix}-development"
}

# Create an environment "development" in the project
resource "platform-orchestrator_environment" "development" {
  id          = "development"
  project_id  = platform-orchestrator_project.project.id
  env_type_id = platform-orchestrator_environment_type.development.id

  # Ensure the runner rule is in place so that the Orchestrator may assign a runner to the environment
  depends_on = [platform-orchestrator_runner_rule.runner_rule]
}
