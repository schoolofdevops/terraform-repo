provider "aws" {
  region = "us-east-1"
  alias = "virginia"
}

provider "aws" {
  region = "eu-west-3"
  alias = "paris"
}

resource "aws_instance" "frontend" {
  provider       = "aws.paris"
  count          = "${var.count}"
  ami            = "${var.ami["paris"]}"
  instance_type  = "${var.instance_type}"
  key_name       = "${aws_key_pair.terraform.key_name}"
  vpc_security_group_ids = ["${aws_security_group.frontend.id}"]

#  depends_on = ["aws_key_pair.terraform"]
  disable_api_termination = false

  lifecycle {
    create_before_destroy = true
    prevent_destroy = false
  }

  timeouts {
     create = "7m"
     delete = "1h"
  }

  tags = {
    Name  = "${var.tags["name"]}"
    owner = "${var.tags["owner"]}"
    env   = "${var.tags["env"]}"
    role  = "${var.tags["role"]}"
  }
}

resource "aws_key_pair" "terraform" {
  provider       = "aws.paris"
  key_name    = "${var.key["name"]}"
  public_key  = "${var.key["pub"]}"
}

resource "aws_security_group" "frontend" {
  name = "tr-01-frontend"
  provider       = "aws.paris"

  ingress {
    from_port    = 22
    to_port      = 22
    protocol     = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]

  }



}
