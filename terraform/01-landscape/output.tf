# =============================================================================

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "public_subnet_list" {
  value = [
    "${module.zone_a.public_subnet_id}",
    "${module.zone_b.public_subnet_id}",
    "${module.zone_c.public_subnet_id}"
  ]
}

output "private_subnet_list" {
  value = [
    "${module.zone_a.private_subnet_id}",
    "${module.zone_b.private_subnet_id}",
    "${module.zone_c.private_subnet_id}"
  ]
}

output "bastion_realm_sg" {
  value = "${aws_security_group.bastion_realm.id}"
}

# =============================================================================

data "template_file" "inventory" {
  template = "${file("${path.module}/templates/inventory.tpl")}"

  vars {
    bastion_a = "${module.zone_a.bastion_ip}"
    bastion_b = "${module.zone_b.bastion_ip}"
    bastion_c = "${module.zone_c.bastion_ip}"
  }
}

resource "null_resource" "inventories" {

  triggers {
    bastion_a = "${module.zone_a.bastion_ip}"
    bastion_b = "${module.zone_b.bastion_ip}"
    bastion_c = "${module.zone_c.bastion_ip}"
  }

  provisioner "local-exec" {
    command = "echo '${data.template_file.inventory.rendered}' > ${path.module}/../../inventories/bastions"
  }

}
