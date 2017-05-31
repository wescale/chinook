resource "aws_key_pair" "monitor_keypair" {
  key_name   = "${var.project_name}-${var.project_region}-monitor"
  public_key = "${var.monitor_default_public_key}"
}

resource "aws_instance" "monitor" {

  ami = "${data.aws_ami.debian.id}"

  instance_type = "m3.medium"

  count = "${var.monitor_number}"

  key_name = "${aws_key_pair.monitor_keypair.key_name}"

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
    Name = "${var.project_name}-${var.project_region}-monitor"
  }
}
