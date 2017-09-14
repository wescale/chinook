# =============================================================================

resource "aws_key_pair" "masters_keypair" {
  key_name   = "${var.project_name}-${var.project_region}-masters"
  public_key = "${file(var.public_key_path)}"
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

  vpc_security_group_ids = [
    "${data.terraform_remote_state.landscape.bastion_realm_sg}",
    "${aws_security_group.nomad_realm.id}"
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
