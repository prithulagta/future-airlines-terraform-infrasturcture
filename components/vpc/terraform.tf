terraform {
  required_version = ">= 0.11.13"

  backend "s3" {
    bucket         = "111111111111-future-airlines-terraform-state"
    key            = "vpc.tfstate"
    region         = "eu-west-1"
    encrypt        = "true"
    profile        = "mgmt-account"
    dynamodb_table = "terraform_lock"
  }
}
