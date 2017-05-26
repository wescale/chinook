#
# VARIABLES
#
variable "aws_region" {
  default = "eu-west-1"
}

variable "project_name" {
  default = "CHINOOK"
}

variable "masters_default_public_key" {}

variable "masters_number" {}

#
# DATASOURCES
#
data "terraform_remote_state" "landscape" {
  backend = "local"
  config {
    path = "${path.module}/../00-landscape/terraform.tfstate"
  }
}

data "terraform_remote_state" "rights" {
  backend = "local"
  config {
    path = "${path.module}/../00-iam/terraform.tfstate"
  }
}

data "aws_ami" "debian" {
  most_recent = true

  filter {
    name   = "name"
    values = ["debian-jessie-amd64-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["379101102735"] # Debian Project
}