# =============================================================================

resource "aws_key_pair" "workers_keypair" {
  key_name   = "${var.project_name}-${var.project_region}-entry"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "entry_instance" {

  ami = "${data.aws_ami.debian.id}"

  instance_type = "t2.micro"

  key_name = "${aws_key_pair.workers_keypair.key_name}"

  subnet_id = "${
    element(
      data.terraform_remote_state.landscape.private_subnet_list,
      0
    )
  }"

  vpc_security_group_ids = [
    "${data.terraform_remote_state.landscape.bastion_realm_sg}",
    "${data.terraform_remote_state.landscape.common_sg}",
    "${aws_security_group.elb_back.id}"
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
    Name = "${var.project_name}-${var.project_region}-entry"
  }
}

resource "aws_security_group" "elb_front" {
  name_prefix = "${var.project_name}-web-elb"
  vpc_id = "${data.terraform_remote_state.landscape.vpc_id}"
}

resource "aws_security_group_rule" "on_elb_front" {
  security_group_id = "${aws_security_group.elb_front.id}"
  type            = "ingress"
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "on_elb_front_out" {
  type            = "egress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.elb_front.id}"
}

resource "aws_security_group_rule" "on_elb_back_out" {
type            = "egress"
from_port       = 0
to_port         = 0
protocol        = "-1"
cidr_blocks     = ["0.0.0.0/0"]
security_group_id = "${aws_security_group.elb_back.id}"
}

resource "aws_security_group" "elb_back" {
  name_prefix = "${var.project_name}-web-elb"
  vpc_id = "${data.terraform_remote_state.landscape.vpc_id}"
}

resource "aws_security_group_rule" "on_elb_back" {
  type            = "ingress"
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  source_security_group_id     = "${aws_security_group.elb_front.id}"
  security_group_id = "${aws_security_group.elb_back.id}"
}

resource "aws_elb" "bar" {
  name               = "${var.project_name}-traefik"
  subnets = ["${data.terraform_remote_state.landscape.public_subnet_list}"]

  listener {
    instance_port      = 80
    instance_protocol  = "tcp"
    lb_port            = 80
    lb_protocol        = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 8
    timeout             = 3
    target              = "TCP:80"
    interval            = 60
  }

  instances                   = ["${aws_instance.entry_instance.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  security_groups = [
        "${aws_security_group.elb_front.id}"
  ]
  tags {
    Name = "${var.project_name}-terraform-elb"
  }
}

resource "aws_route53_record" "www" {
  zone_id = "Z3SI64X4SFQ59L"
  name    = "*.chinook.aws.wescale.fr"
  type    = "A"

  alias {
    name                   = "${lower(aws_elb.bar.dns_name)}"
    zone_id                = "${aws_elb.bar.zone_id}"
    evaluate_target_health = true
  }
}

