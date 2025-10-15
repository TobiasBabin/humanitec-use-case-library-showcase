data "aws_caller_identity" "current" {
  count = local.create_aws ? 1 : 0
}

# AWS only: policy document for Pod Identity role
data "aws_iam_policy_document" "assume_role" {
  count = local.create_aws ? 1 : 0

  lifecycle {
    precondition {
      condition = var.eks_oidc_provider != null
      error_message = "EKS OIDC provider must be set when using AWS"
    }
  }

  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current[0].account_id}:oidc-provider/${var.eks_oidc_provider}"]
    }
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]
    condition {
      test     = "StringEquals"
      variable = "${var.eks_oidc_provider}:aud"
      values = [
        "sts.amazonaws.com"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "${var.eks_oidc_provider}:sub"
      values = [
        "system:serviceaccount:${kubernetes_namespace.humanitec_kubernetes_agent_runner.metadata[0].name}:${local.runner_k8s_service_account}"
      ]
    }
  }
}

# AWS only: IAM role for the runner
resource "aws_iam_role" "agent_runner_irsa_role" {
  count = local.create_aws ? 1 : 0

  name               = "${var.prefix}-kubernetes-agent-runner"
  description        = "EKS workload identity for the Humanitec Orchestrator K8s agent runner"
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
}
