# =============================================================================

resource "aws_key_pair" "workers_keypair" {
  key_name   = "${var.project_name}-${var.project_region}-workers"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "workers" {

  ami = "${data.aws_ami.debian.id}"

  instance_type = "t2.micro"

  count = "${var.workers_number}"

  key_name = "${aws_key_pair.workers_keypair.key_name}"

  associate_public_ip_address = false

  subnet_id = "${
    element(
      data.terraform_remote_state.landscape.private_subnet_list,
      count.index % length(data.terraform_remote_state.landscape.private_subnet_list)
    )
  }"

  vpc_security_group_ids = [
    "${data.terraform_remote_state.landscape.bastion_realm_sg}",
    "${data.terraform_remote_state.landscape.common_sg}",
    "${aws_security_group.workers.id}"
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
    Name = "${var.project_name}-${var.project_region}-worker-${count.index}"
  }
}

resource "aws_security_group" "workers" {
  name_prefix = "${var.project_name}-${var.project_region}-workers"

  vpc_id = "${data.terraform_remote_state.landscape.vpc_id}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
