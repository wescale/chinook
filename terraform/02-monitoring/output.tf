data "template_file" "inventory" {
  template = "${file("${path.module}/templates/inventory.tpl")}"

  vars {
    masters = "${join(",", aws_instance.masters.*.private_ip)}"
  }
}

resource "null_resource" "master_inventory" {
  triggers {
    masters = "${join(",", aws_instance.masters.*.private_ip)}"
  }

  provisioner "local-exec" {
    command = "echo '${data.template_file.inventory.rendered}' > ${path.module}/../../inventories/masters"
  }
}
