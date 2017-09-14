output "entry_instance" {
  value = ["${aws_instance.entry_instance.private_ip}"]
}

output "entry_public" {
  value = "${aws_instance.entry_instance.public_ip}"
}

output "entry_mon_instance" {
  value = ["${aws_instance.monitor_entry_instance.private_ip}"]
}

output "entry_mon_public" {
  value = "${aws_instance.monitor_entry_instance.public_ip}"
}
