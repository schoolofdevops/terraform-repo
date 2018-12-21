variable "count" {
  default = "1"
  description = "number of instances to create"
}

variable "ami" {
  default = {
    paris = "ami-08182c55a1c188dee"
  }
  description = "ami id for the region"
}


variable "instance_type" {
  default = "t2.micro"
  description = ""
}


variable "ssh_user" {
  default = "ubuntu"
  description = ""
}

variable "rds_pass" {
  default = "password"
  description = ""
}


variable "tags" {
  default = {
    name = "tr-01-frontend"
    owner = "Gourav Shah"
    env = "dev"
    role = "frontend"
  }
  description = "instance tags"
}


variable "key" {
  description = "ssh keypair details"

  default = {
    name = "tr-01-tf"
    pub  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC09K+FpiHFHYtgB9YY2qWXtvzSCJqBKeFRYdsQUTvzZ2cWYEv1c1J6fc/1b4MWFzBIvGoIxwaLo6NaYf825VviSfYyrHkXai6vPu9ZnXmhPsbr0jiMUmwRCxMVgBwl0+Z/bnPSuChNPymycb/Bus9q5TnMV3FPOTkkj66f/6y1FangeJTz98ufIzpBSZSBjLvvbzUCJl8qApNqZ+KqKsttIajz+JbicRtSNE1OwpnHgX5xVbHecirmYW/uWKeo9DpI09v7urlIzE0LORpfcMjFcftnvFnJJA6q2G3Vevh6q88kKy6owoUaRDQCGGUYHTRl1huMJrAhXV6J1S5sk/kD gouravshah@Apples-MacBook-Pro-2.local"
  }
}
