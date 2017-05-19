resource "aws_iam_instance_profile" "kube_masters" {

  name = "${var.vpc_name}-kube-masters-instance-profile"
  role = "${aws_iam_role.kube_masters.name}"
}

resource "aws_iam_role" "kube_masters" {
  name = "${var.vpc_name}-kube-masters-role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}


resource "aws_iam_role_policy" "kube_masters" {
  name_prefix = "${var.vpc_name}_kube_masters"

  role = "${aws_iam_role.kube_masters.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*",
        "autoscaling:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}