variable "project_name" {}

variable "project_region" {}

provider "aws" {
  region = "${var.project_region}"
}