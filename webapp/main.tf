provider "aws" {
  region = "${var.region}"
}

data "aws_vpc" "targetVPC" {
  filter = {
    name = "tag:Name"
    values = ["mVpc"]
  }
}


data "aws_subnet_ids" "targetSubnetIds" {
  vpc_id = "${data.aws_vpc.targetVPC.id}"
  filter = {
    name = "tag:Name"
    values = ["mSn"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "userData" {
  template = "${file("userdata.tpl")}"

  vars = {
    username = "charlelie"
  }
}

resource "aws_security_group" "sgUbuntu" {
  name        = "sgEc2"
  description = "Allow all http trafic"
  vpc_id      = "${data.aws_vpc.targetVPC.id}"

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "sgUbuntu"
  }
}

resource "aws_instance" "web" {
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t2.micro"
  subnet_id                   = "${element(data.aws_subnet_ids.targetSubnetIds.ids,count.index)}"
  user_data                   = "${data.template_file.userData.rendered}"
  security_groups             = ["${aws_security_group.sgUbuntu.id}"]
  associate_public_ip_address = "true"
  count = 2

  tags {
    Name = "Ubuntu"
  }
}
