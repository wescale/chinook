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

resource "aws_elb" "kube_masters" {
  name = "${data.terraform_remote_state.landscape.vpc}-kube-masters"

  subnets = [
    "${data.terraform_remote_state.landscape.public_subnet_list}"
  ]

  internal = false

  instances = ["${aws_instance.kube_masters.*.id}"]

  security_groups = [
    "${aws_security_group.temporary.id}"
  ]

  listener {
    instance_port     = 8080
    instance_protocol = "tcp"
    lb_port           = 8080
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = 80
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = 4001
    instance_protocol = "tcp"
    lb_port           = 4001
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 10
    timeout = 3
    target = "TCP:80"
    interval = 30
  }
}

resource "aws_instance" "kube_masters" {

  ami = "${data.aws_ami.debian.id}"
  instance_type = "t2.micro"

  count = "${var.kube_masters_number}"

  key_name = "${aws_key_pair.kube_masters_keypair.key_name}"

  associate_public_ip_address = false

  subnet_id = "${element(
      data.terraform_remote_state.landscape.private_subnet_list,
      count.index % length(data.terraform_remote_state.landscape.private_subnet_list)
    )}"

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
  - 'apt-get install -y curl apache2'
  - 'pip install awscli boto3'

EOF

  tags {
    Name = "kube-master-${count.index}"
  }
}

resource "aws_security_group" "temporary" {

  name_prefix = "${data.terraform_remote_state.landscape.vpc}-elb-kube-masters"

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

data "template_file" "inventory" {
  template = "${file("${path.module}/templates/inventory.tpl")}"

  vars {
    masters = "${join(",", aws_instance.kube_masters.*.private_ip)}"
  }
}

resource "null_resource" "master_inventory" {
  triggers {
    masters = "${join(",", aws_instance.kube_masters.*.private_ip)}"
  }

  provisioner "local-exec" {
    command = "echo '${data.template_file.inventory.rendered}' > ${path.module}/../../inventories/masters"
  }
}

