output "workers_instances" {
  value = ["${aws_instance.workers.*.private_ip}"]
}
