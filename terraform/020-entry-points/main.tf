# =============================================================================

resource "aws_key_pair" "workers_keypair" {
  key_name   = "${var.project_name}-${var.project_region}-entry"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "entry_instance" {
  ami                  = "${data.aws_ami.debian.id}"
  instance_type        = "${var.entry_instance_type}"
  key_name             = "${aws_key_pair.workers_keypair.key_name}"
  iam_instance_profile = "${data.terraform_remote_state.rights.masters_profile}"
  ebs_optimized        = false

  count = "${var.entry_instance_count}"

  subnet_id = "${
    element(
      data.terraform_remote_state.landscape.private_subnet_list,
      count.index % length(data.terraform_remote_state.landscape.private_subnet_list)
    )
  }"

  vpc_security_group_ids = [
    "${data.terraform_remote_state.landscape.bastion_realm_sg}",
    "${aws_security_group.elb_back.id}",
  ]

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

resource "aws_elb" "entry" {
  name = "${var.project_name}-traefik"

  idle_timeout                = 30
  connection_draining         = true
  connection_draining_timeout = 30
  cross_zone_load_balancing   = true

  subnets = [
    "${data.terraform_remote_state.landscape.public_subnet_list}",
  ]

  instances = [
    "${aws_instance.entry_instance.id}",
  ]

  security_groups = [
    "${aws_security_group.elb_front.id}",
  ]

  listener {
    instance_port     = 80
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    target              = "TCP:80"
    interval            = 10
  }

  tags {
    Name = "${var.project_name}-terraform-elb"
  }
}

resource "aws_route53_record" "www" {
  zone_id = "${var.route53_zone_id}"
  name    = "*.${var.route53_zone_domain}"
  type    = "A"

  alias {
    name                   = "${lower(aws_elb.entry.dns_name)}"
    zone_id                = "${aws_elb.entry.zone_id}"
    evaluate_target_health = true
  }
}

# =============================================================================
# =============================================================================
# =============================================================================

resource "aws_instance" "monitor_entry_instance" {
  ami                  = "${data.aws_ami.debian.id}"
  instance_type        = "${var.entry_instance_type}"
  key_name             = "${aws_key_pair.workers_keypair.key_name}"
  iam_instance_profile = "${data.terraform_remote_state.rights.masters_profile}"
  ebs_optimized        = false

  count = "${var.entry_instance_count}"

  subnet_id = "${
    element(
    data.terraform_remote_state.landscape.private_subnet_list,
    count.index % length(data.terraform_remote_state.landscape.private_subnet_list)
    )
}"

  vpc_security_group_ids = [
    "${data.terraform_remote_state.landscape.bastion_realm_sg}",
    "${aws_security_group.elb_back.id}",
  ]

  user_data = <<EOF
#cloud-config
runcmd:
  - 'wget https://raw.githubusercontent.com/aurelienmaury/ansible-role-seed/master/files/seed-debian-8.sh'
  - 'chmod u+x ./seed-debian-8.sh'
  - 'for i in 1 2 3 4 5; do ./seed-debian-8.sh && break || sleep 2; done'
  - 'pip install awscli boto3'
EOF

  tags {
    Name = "${var.project_name}-${var.project_region}-monitor-entry"
  }
}

resource "aws_elb" "monitor_entry" {
  name = "${var.project_name}-monitor-traefik"

  idle_timeout                = 30
  connection_draining         = true
  connection_draining_timeout = 30
  cross_zone_load_balancing   = true

  subnets = [
    "${data.terraform_remote_state.landscape.public_subnet_list}",
  ]

  instances = [
    "${aws_instance.entry_instance.id}",
  ]

  security_groups = [
    "${aws_security_group.elb_front.id}",
  ]

  listener {
    instance_port     = 80
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    target              = "TCP:80"
    interval            = 10
  }

  tags {
    Name = "${var.project_name}-terraform-elb"
  }
}

resource "aws_route53_record" "www-mon" {
  zone_id = "${var.route53_internal_zone_id}"
  name    = "*.${var.route53_internal_zone_domain}"
  type    = "A"

  alias {
    name                   = "${lower(aws_elb.entry.dns_name)}"
    zone_id                = "${aws_elb.monitor_entry.zone_id}"
    evaluate_target_health = true
  }
}
