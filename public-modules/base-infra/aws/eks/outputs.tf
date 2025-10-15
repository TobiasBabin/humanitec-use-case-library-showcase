output "k8s_connect_command" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.cluster.name}"
}
output "k8s_cluster_name" {
  value = aws_eks_cluster.cluster.name
}
output "k8s_cluster_endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}
output "k8s_cluster_ca_certificate" {
  value     = aws_eks_cluster.cluster.certificate_authority[0].data
  sensitive = true
}
output "k8s_oidc_provider" {
  value = trimprefix(aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://")
}
output "subnet_ids" {
  value = aws_subnet.subnet[*].id
}