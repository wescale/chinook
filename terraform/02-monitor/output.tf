data "template_file" "inventory" {
  template = "${file("${path.module}/templates/inventory.tpl")}"

  vars {
    monitor = "${join(",", aws_instance.monitor.*.private_ip)}"
  }
}

resource "null_resource" "monitor_inventory" {
  triggers {
    monitor = "${join(",", aws_instance.monitor.*.private_ip)}"
  }

  provisioner "local-exec" {
    command = "echo '${data.template_file.inventory.rendered}' > ${path.module}/../../inventories/monitor"
  }
}
