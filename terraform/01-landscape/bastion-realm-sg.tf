##
# BASTION REALM - Every server should be part of this security group.
##
resource "aws_security_group" "bastion_realm" {
  name_prefix         = "${var.project_name}-bastion-realm"
  vpc_id              = "${aws_vpc.vpc.id}"
}

##
# OUT - Outgoing traffic to anywhere
##
resource "aws_security_group_rule" "sgro_bastion_realm_ssh" {
  security_group_id   = "${aws_security_group.bastion_realm.id}"
  type                = "egress"
  from_port           = 0
  to_port             = 0
  protocol            = "-1"
  cidr_blocks         = ["0.0.0.0/0"]
}

##
# SSH - Incoming ssh from any bastion host
##
resource "aws_security_group_rule" "sgri_bastion_realm_ssh_a" {
  security_group_id   = "${aws_security_group.bastion_realm.id}"
  type                = "ingress"
  from_port           = 22
  to_port             = 22
  protocol            = "tcp"
  source_security_group_id          = "${module.zone_a.bastion_sg}"
}

resource "aws_security_group_rule" "sgri_bastion_realm_ssh_b" {
  security_group_id   = "${aws_security_group.bastion_realm.id}"
  type                = "ingress"
  from_port           = 22
  to_port             = 22
  protocol            = "tcp"
  source_security_group_id          = "${module.zone_b.bastion_sg}"
}

resource "aws_security_group_rule" "sgri_bastion_realm_ssh_c" {
  security_group_id   = "${aws_security_group.bastion_realm.id}"
  type                = "ingress"
  from_port           = 22
  to_port             = 22
  protocol            = "tcp"
  source_security_group_id          = "${module.zone_c.bastion_sg}"
}


##
# CONSUL - Every port used by Consul agents to communicate.
##
resource "aws_security_group_rule" "sgri_bastion_realm_consul" {
  security_group_id   = "${aws_security_group.bastion_realm.id}"
  type                = "ingress"
  from_port           = 8300
  to_port             = 8302
  protocol            = "tcp"
  source_security_group_id          = "${aws_security_group.bastion_realm.id}"
}

##
# MONITORING - Port range reserved for monitoring agent and interfaces.
##
resource "aws_security_group_rule" "sgri_bastion_realm_monitoring" {
  security_group_id   = "${aws_security_group.bastion_realm.id}"
  type                = "ingress"
  from_port           = 9000
  to_port             = 9500
  protocol            = "tcp"
  source_security_group_id          = "${aws_security_group.bastion_realm.id}"
}

resource "aws_security_group_rule" "sgri_bastion_realm_yolo" {
  security_group_id   = "${aws_security_group.bastion_realm.id}"
  type                = "ingress"
  from_port           = 0
  to_port             = 0
  protocol            = "-1"
  source_security_group_id          = "${aws_security_group.bastion_realm.id}"
}
