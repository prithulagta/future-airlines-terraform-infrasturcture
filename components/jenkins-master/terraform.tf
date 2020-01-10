terraform {
  required_version = ">= 0.11.13"

  backend "s3" {
    key            = "jenkins-master"
    region         = "eu-west-1"
    encrypt        = "true"
    profile        = "mgmt-account"
    dynamodb_table = "terraform_lock"
  }
}