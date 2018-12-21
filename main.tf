provider "aws" {
  region = "us-east-1"
  alias = "virginia"
}

provider "aws" {
  region = "eu-west-3"
  alias = "paris"
}


data "aws_db_instance" "database" {
  provider = "aws.virginia"
  db_instance_identifier = "devopsdemo-db"
}

data "template_file" "dbconfig" {
   #template = "$file(config.ini.tpl)"
   template = "${file("${path.module}/config.ini.tpl")}"


   vars{
     dbport = "${data.aws_db_instance.database.port}"
     dbhost = "${data.aws_db_instance.database.address}"
     dbuser = "${data.aws_db_instance.database.master_username}"
     dbpass = "${var.rds_pass}"
     dbname = "${data.aws_db_instance.database.db_name}"
   }

}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.49.0"

   providers = {
    aws = "aws.paris"
  }

  name = "tr-01"
  cidr = "10.0.0.0/16"
  azs             = ["eu-west-3a", "eu-west-3b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = false
  enable_vpn_gateway = false


  tags = {
    Terraform = "true"
    Environment = "dev"
    Name = "tr-01"
    Owner = "Gourav Shah"
  }
}



resource "aws_instance" "frontend" {
  provider       = "aws.paris"
  count          = "${var.count}"
  ami            = "${var.ami["paris"]}"
  instance_type  = "${var.instance_type}"
  key_name       = "${aws_key_pair.terraform.key_name}"
  vpc_security_group_ids = ["${aws_security_group.frontend.id}"]
  subnet_id      = "${module.vpc.public_subnets[0]}"

#  depends_on = ["aws_key_pair.terraform"]
  disable_api_termination = false

  provisioner "file" {
    source = "user-data.sh"
    destination = "/tmp/user-data.sh"

    connection {
      type = "ssh"
      user = "${var.ssh_user}"
      private_key = "${file("~/.ssh/terraform")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
       "chmod +x /tmp/user-data.sh",
       "/tmp/user-data.sh",
     ]

    connection {
      type = "ssh"
      user = "${var.ssh_user}"
      private_key = "${file("~/.ssh/terraform")}"
    }
  }

  provisioner "file" {
    content = "${data.template_file.dbconfig.rendered}"
    destination = "/var/www/html/config.ini"

    connection {
      type = "ssh"
      user = "${var.ssh_user}"
      private_key = "${file("~/.ssh/terraform")}"
    }
  }

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
  vpc_id   = "${module.vpc.vpc_id}"

  ingress {
    description     = "allow ssh port acceess"
    from_port    = 22
    to_port      = 22
    protocol     = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  ingress {
    description     = "allow http port acceess"
    from_port    = 80
    to_port      = 80
    protocol     = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  egress {
    description     = "allow all outgoing communication"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }


}



resource "null_resource" "dbconfig" {


  triggers {
  template_rendered = "${data.template_file.dbconfig.rendered}"
  }

  connection {
    host = "${element(aws_instance.frontend.*.public_ip, 0)}"
  }

  provisioner "file" {
    content = "${data.template_file.dbconfig.rendered}"
    destination = "/var/www/html/config.ini"

    connection {
      type = "ssh"
      user = "${var.ssh_user}"
      private_key = "${file("~/.ssh/terraform")}"
    }
  }

}
