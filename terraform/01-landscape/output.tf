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

output bastions_ip_list {
  value = [
    "${module.zone_a.bastion_ip}",
    "${module.zone_b.bastion_ip}",
    "${module.zone_c.bastion_ip}"
  ]
}

output "public_subnet_cidr_a" {
  value = "${var.public_subnet_cidr_a}"
}

output "private_subnet_cidr_a" {
  value = "${var.private_subnet_cidr_a}"
}

output "bastion_a" {
  value = "${module.zone_a.bastion_ip}"
}

output "public_subnet_cidr_b" {
  value = "${var.public_subnet_cidr_b}"
}

output "private_subnet_cidr_b" {
  value = "${var.private_subnet_cidr_b}"
}

output "bastion_b" {
  value = "${module.zone_b.bastion_ip}"
}

output "public_subnet_cidr_c" {
  value = "${var.public_subnet_cidr_c}"
}

output "private_subnet_cidr_c" {
  value = "${var.private_subnet_cidr_c}"
}

output "bastion_c" {
  value = "${module.zone_c.bastion_ip}"
}

output "landscape_az_list" {
  value = ["eu-west-1a","eu-west-1b","eu-west-1c"]
}