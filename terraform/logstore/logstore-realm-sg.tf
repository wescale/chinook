
resource "aws_security_group" "logstore_realm" {
  name_prefix         = "${var.project_name}-logstore-realm"
  vpc_id              = "${data.terraform_remote_state.landscape.vpc_id}"
}

resource "aws_security_group_rule" "sgri_logstore_realm_backbone" {
  security_group_id   = "${aws_security_group.logstore_realm.id}"
  type                = "ingress"
  from_port           = 9300
  to_port             = 9300
  protocol            = "tcp"
  source_security_group_id          = "${aws_security_group.logstore_realm.id}"
}

resource "aws_security_group_rule" "sgri_logstore_realm_input" {
  security_group_id   = "${aws_security_group.logstore_realm.id}"
  type                = "ingress"
  from_port           = 9200
  to_port             = 9200
  protocol            = "tcp"
  source_security_group_id          = "${data.terraform_remote_state.landscape.bastion_realm_sg}"
}

resource "aws_security_group_rule" "sgri_logstore_realm_graylog_inputs" {
  security_group_id   = "${aws_security_group.logstore_realm.id}"
  type                = "ingress"
  from_port           = 5000
  to_port             = 5999
  protocol            = "tcp"
  source_security_group_id          = "${data.terraform_remote_state.landscape.bastion_realm_sg}"
}
