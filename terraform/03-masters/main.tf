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
    "${aws_security_group.masters.id}"
  ]

  listener {
    instance_port     = 8300
    instance_protocol = "tcp"
    lb_port           = 8300
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 10
    timeout = 3
    target = "TCP:8300"
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
    "${aws_security_group.masters.id}"
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

resource "aws_security_group" "masters" {

  name_prefix = "${var.project_name}-${var.project_region}-masters"

  vpc_id = "${data.terraform_remote_state.landscape.vpc_id}"

  ingress {
    from_port = 8300
    to_port = 8302
    protocol = "TCP"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8500
    to_port = 8500
    protocol = "TCP"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8600
    to_port = 8600
    protocol = "TCP"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 4646
    to_port = 4648
    protocol = "TCP"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
