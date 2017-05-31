# =============================================================================

resource "aws_key_pair" "masters_keypair" {
  key_name   = "${var.project_name}-${var.project_region}-masters"
  public_key = "${var.masters_default_public_key}"
}

resource "aws_elb" "masters" {
  name = "${var.project_name}-${var.project_region}-masters"

  subnets = [
    "${data.terraform_remote_state.landscape.public_subnet_list}"
  ]

  internal = false

  instances = [
    "${aws_instance.masters.*.id}"
  ]

  security_groups = [
    "${data.terraform_remote_state.landscape.common_sg}"
  ]

  listener {
    instance_port     = 8500
    instance_protocol = "tcp"
    lb_port           = 8500
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 10
    timeout = 3
    target = "TCP:8500"
    interval = 30
  }
}

resource "aws_instance" "masters" {

  ami = "${data.aws_ami.debian.id}"

  instance_type = "t2.micro"

  count = "${var.masters_number}"

  key_name = "${aws_key_pair.masters_keypair.key_name}"

  associate_public_ip_address = false

  subnet_id = "${
    element(
      data.terraform_remote_state.landscape.private_subnet_list,
      count.index % length(data.terraform_remote_state.landscape.private_subnet_list)
    )
  }"

  security_groups = [
    "${data.terraform_remote_state.landscape.bastion_realm_sg}",
    "${data.terraform_remote_state.landscape.common_sg}"
  ]

  iam_instance_profile = "${data.terraform_remote_state.rights.masters_profile}"

  ebs_optimized = false

  user_data = <<EOF
#cloud-config
runcmd:
  - 'wget https://raw.githubusercontent.com/aurelienmaury/ansible-role-seed/master/files/seed-debian-8.sh'
  - 'chmod u+x ./seed-debian-8.sh'
  - 'for i in 1 2 3 4 5; do ./seed-debian-8.sh && break || sleep 2; done'
  - 'pip install awscli boto3'
EOF

  tags {
    Name = "${var.project_name}-${var.project_region}-master-${count.index}"
  }
}
