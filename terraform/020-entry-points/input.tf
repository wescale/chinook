# =============================================================================

variable "project_name" {}

variable "project_region" {}

variable "public_key_path" {}

variable "route53_zone_id" {}

variable "route53_zone_domain" {}

variable "route53_internal_zone_id" {}

variable "route53_internal_zone_domain" {}

variable "entry_instance_type" {
  default = "t2.small"
}

variable "entry_instance_count" {
  default = "1"
}

# =============================================================================

provider "aws" {
  region = "${var.project_region}"
}

# =============================================================================

data "terraform_remote_state" "landscape" {
  backend = "local"

  config {
    path = "${path.module}/../01-landscape/terraform.tfstate"
  }
}

data "terraform_remote_state" "rights" {
  backend = "local"

  config {
    path = "${path.module}/../00-access-rights/terraform.tfstate"
  }
}

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
