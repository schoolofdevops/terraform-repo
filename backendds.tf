terraform {
  backend "s3" {
    bucket  = "terraform-state-3453"
    key     = "dev/team-00.tfstate"
    region  = "ap-southeast-1"
    dynamodb_table = "team-00"
  }
}
