output "masters_instances" {
  value = ["${aws_instance.masters.*.private_ip}"]
}

output "nomad_realm_sg" {
  value = "${aws_security_group.nomad_realm.id}"
}