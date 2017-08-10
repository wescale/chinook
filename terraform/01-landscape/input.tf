# =============================================================================

variable "project_name" {}
variable "project_region" {}

variable "vpc_cidr" {}

variable "public_subnet_cidr_a" {}
variable "private_subnet_cidr_a" {}

variable "public_subnet_cidr_b" {}
variable "private_subnet_cidr_b" {}

variable "public_subnet_cidr_c" {}
variable "private_subnet_cidr_c" {}

variable "public_key_path" {}

# =============================================================================

provider "aws" {
  region = "${var.project_region}"
}

# =============================================================================

data "aws_ami" "debian" {
  most_recent = true

  filter {
    name   = "name"
    values = ["debian-stretch-hvm-x86_64-gp2*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["379101102735"] # Debian Project
}
