
resource "aws_security_group" "nomad_realm" {
  name_prefix         = "${var.project_name}-nomad-realm"
  vpc_id              = "${data.terraform_remote_state.landscape.vpc_id}"
}

resource "aws_security_group_rule" "sgri_nomad_realm_backbone" {
  security_group_id   = "${aws_security_group.nomad_realm.id}"
  type                = "ingress"
  from_port           = 4646
  to_port             = 4648
  protocol            = "tcp"
  source_security_group_id          = "${aws_security_group.nomad_realm.id}"
}

resource "aws_security_group_rule" "sgri_nomad_realm_containers" {
  security_group_id   = "${aws_security_group.nomad_realm.id}"
  type                = "ingress"
  from_port           = 40000
  to_port             = 60000
  protocol            = "tcp"
  source_security_group_id = "${aws_security_group.nomad_realm.id}"
}
