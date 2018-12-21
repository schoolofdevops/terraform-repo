output "hostnames" {
  description = "public dns of instances created"
  value = "${aws_instance.frontend.*.public_dns}"
}


output "ips" {
  description = "public ips of instances created"
  value = "${aws_instance.frontend.*.public_ip}"
}

output "ssh_key" {
  description = "ssh key pair name to connect with"
  value = "${aws_instance.frontend.*.key_name}"
}

output "rds_endpoint" {
  value = "${data.aws_db_instance.database.endpoint}"
}

output "rds_user" {
  value = "${data.aws_db_instance.database.master_username}"
}

output "rds_database" {
  value = "${data.aws_db_instance.database.db_name}"
}
