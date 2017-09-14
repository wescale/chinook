output "logstores_instances" {
  value = ["${aws_instance.logstores.*.private_ip}"]
}

output "logstore_realm_sg" {
  value = "${aws_security_group.logstore_realm.id}"
}