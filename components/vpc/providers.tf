provider "aws" {
  region                  = "eu-west-1"
  profile                 = "${var.account_name}"
  skip_metadata_api_check = true
  version = "2.18.0"
}
