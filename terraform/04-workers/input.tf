# =============================================================================

variable "project_name" {}
variable "project_region" {}

variable "public_key_path" {}

variable "workers_number" {}

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
    values = ["debian-jessie-amd64-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["379101102735"] # Debian Project
}
