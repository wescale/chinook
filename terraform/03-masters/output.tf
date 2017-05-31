output "masters_instances" {
  value = ["${aws_instance.masters.*.private_ip}"]
}
