data "aws_caller_identity" "current" {}

module "vpc" {
  source                       = "../../modules/vpc"
  environment                  = "${terraform.workspace}"
  account                      = "${data.aws_caller_identity.current.account_id}"
  name                         = "${var.account_name}"
  cidr                         = "${var.mgmt_vpc_cidr}"
  availability_zones           = "${var.mgmt_vpc_availability_zones}"
  subnets_private              = "${var.mgmt_vpc_subnets_public}"
  subnets_public               = "${var.mgmt_vpc_subnets_private}"
}