variable "project_name" {}

variable "project_region" {}

variable "terrabot_all_layers_dir" {}

provider "aws" {
  region = "${var.project_region}"
}