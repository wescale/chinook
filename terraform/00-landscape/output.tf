
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

output "vpc" {
  value = "${var.vpc_name}"
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}