resource "aws_iam_instance_profile" "masters" {

  name = "${var.project_name}-masters-instance-profile"
  role = "${aws_iam_role.masters.name}"
}

resource "aws_iam_role" "masters" {
  name = "${var.project_name}-masters-role"
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


resource "aws_iam_role_policy" "masters" {
  name_prefix = "${var.project_name}_masters"

  role = "${aws_iam_role.masters.id}"

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
