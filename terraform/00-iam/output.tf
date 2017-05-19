output "kube_masters_profile" {
  value = "${aws_iam_instance_profile.kube_masters.id}"
}