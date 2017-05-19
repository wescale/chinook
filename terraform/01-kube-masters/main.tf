provider "aws" {}

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

resource "aws_key_pair" "kube_masters_keypair" {
  key_name   = "${data.terraform_remote_state.landscape.vpc}-kube-masters"
  public_key = "${var.kube_masters_default_public_key}"
}

resource "aws_launch_configuration" "kube_masters" {

  name_prefix = "${data.terraform_remote_state.landscape.vpc}"

  image_id = "${data.aws_ami.debian.id}"

  instance_type = "t2.micro"

  key_name = "${aws_key_pair.kube_masters_keypair.key_name}"

  associate_public_ip_address = false

  security_groups = [
    "${data.terraform_remote_state.landscape.bastion_realm_sg}",
    "${aws_security_group.temporary.id}"
  ]

  iam_instance_profile = "${data.terraform_remote_state.rights.kube_masters_profile}"

  ebs_optimized = false

  user_data = <<EOF
#cloud-config
runcmd:
  - 'wget https://raw.githubusercontent.com/aurelienmaury/ansible-role-seed/master/files/seed-debian-8.sh'
  - 'chmod u+x ./seed-debian-8.sh'
  - 'for i in 1 2 3 4 5; do ./seed-debian-8.sh && break || sleep 2; done'
  - 'apt-get install -y curl'
  - 'pip install awscli boto3'
EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "kube_masters" {
  name = "${data.terraform_remote_state.landscape.vpc}-kube-masters"

  subnets = [
    "${data.terraform_remote_state.landscape.private_subnet_list}"
  ]

  internal = true

  security_groups = [
    "${aws_security_group.temporary.id}"
  ]

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 8080
    lb_protocol       = "http"
  }

  listener {
    instance_port     = 4001
    instance_protocol = "http"
    lb_port           = 4001
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 10
    timeout = 3
    target = "HTTP:4001/"
    interval = 10
  }
}

resource "aws_autoscaling_group" "kube_masters" {

  name_prefix = "${data.terraform_remote_state.landscape.vpc}-kube-masters"

  min_size = "${var.kube_masters_number}"
  max_size = "${var.kube_masters_number}"
  desired_capacity = "${var.kube_masters_number}"

  health_check_grace_period = 1200
  health_check_type = "ELB"
  force_delete = true

  load_balancers = [
    "${aws_elb.kube_masters.id}"
  ]

  vpc_zone_identifier = [
    "${data.terraform_remote_state.landscape.private_subnet_list}"
  ]

  launch_configuration = "${aws_launch_configuration.kube_masters.name}"

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key = "Name"
    value = "${data.terraform_remote_state.landscape.vpc}-kube-master"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "temporary" {

  name_prefix = "${data.terraform_remote_state.landscape.vpc}-elb-kube-masters"

  vpc_id = "${data.terraform_remote_state.landscape.vpc_id}"

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "TCP"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

