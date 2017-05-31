output "monitor_instances" {
  value = ["${aws_instance.monitor.*.private_ip}"]
}
