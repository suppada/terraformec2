// Provider specific configs
provider "aws" {
  region = var.aws_region
}


// EC2 Instance Resource for Module

/*
 resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ec2_instance.id
  instance_id = join("", aws_instance.ec2_instance.*.id)
}
*/
resource "aws_instance" "ec2_instance" {
  count                  = var.ec2_count
  instance_type          = var.instance_type
  ami                    = var.ami_id
  vpc_security_group_ids = [aws_security_group.instance.id]
  iam_instance_profile   = aws_iam_instance_profile.test_profile.name
  subnet_id              = var.subnet_id
  user_data              = file(var.user_data)

  root_block_device {
    volume_type           = var.volume_type
    volume_size           = var.volume_size
    iops                  = var.iops
    delete_on_termination = var.termination

    tags = {
      Name        = var.instance_name
      Environment = "Test"
      Owner       = "Suresh"
      Project     = "Test"
    }
  }

  tags = {
    Name        = var.instance_name
    Environment = "Test"
    Owner       = "Suresh"
    Project     = "Test"
  }
}

/*
resource "aws_ebs_volume" "ec2_instance" {
  availability_zone = "us-east-2c"
  size              = 30

  tags = {
    Name        = var.instance_name
    Environment = "Test"
    Owner       = "Suresh"
    Project     = "Test"
  }
}
*/

#--------- Security Groups -------------#

resource "aws_security_group" "instance" {
  name        = "instance"
  description = "used for access to the dev instance"


  #SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Custom TCP
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Custom TCP
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Custom TCP For mysql database
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = var.instance_name
    Environment = "Test"
    Owner       = "Suresh"
    Project     = "Test"
  }
}

#-------------IAM-------------#
resource "aws_iam_role" "ssm_role" {
  name = "ssm_role"

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
    Name        = var.instance_name
    Environment = "Test"
    Owner       = "Suresh"
    Project     = "Test"
  }
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_iam_role_policy_attachment" "test_attach1" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "test_attach2" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = aws_iam_role.ssm_role.id

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
