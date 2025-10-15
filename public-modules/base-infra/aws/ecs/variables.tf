variable "aws_region" {
  description = "AWS region for resources"
  nullable = false
}
variable "prefix" {
  description = "Naming prefix for all resources"
  nullable = false
}
variable "num_subnets" {
  description = "The number of subnets to create. Defaults to 1"
  default = 1
}