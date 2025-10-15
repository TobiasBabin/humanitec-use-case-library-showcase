data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  region               = var.aws_region

  tags = {
    Name = "${var.prefix}-vpc"
  }
}

# Subnet
resource "aws_subnet" "subnet" {
  count = var.num_subnets

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.10.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  region            = var.aws_region

  tags = {
    Name = "${var.prefix}-subnet-${count.index + 1}"
  }
}
