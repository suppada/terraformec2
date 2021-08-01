// Provider specific configs
provider "aws" {
  region = var.aws_region
}

// EC2 Instance Resource for Module
resource "aws_instance" "ec2_instance" {
  count         = var.ec2_count
  instance_type = var.instance_type
  ami           = var.ami_id
  key_name      = var.key_name
  iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"
  subnet_id     = var.subnet_id
  user_data     = file(var.user_data)


  tags = {
    Name = var.instance_name
  }
}

#-------------IAM-------------#
resource "aws_iam_role" "test_role" {
  name = "test_role"

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

  tags = {
      tag-key = "tag-value"
  }
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = "${aws_iam_role.test_role.name}"
}

resource "aws_iam_role_policy_attachment" "test_attach1" {
role       = aws_iam_role.test_role.name
policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "test_attach2" {
role       = aws_iam_role.test_role.name
policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = "${aws_iam_role.test_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}