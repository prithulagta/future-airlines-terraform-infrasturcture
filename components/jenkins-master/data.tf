data "aws_ami" "jenkins-master" {
  most_recent = true
  owners=["self"]

  filter {
    name   = "branch"
    values = ["master"]
  }

  filter {
    name   = "name"
    values = ["jenkins-master-2.138.3"]
  }

  filter {
    name   = "application"
    values = ["Jenkins-Master"]
  }

}

data "aws_caller_identity" "current" {}

data "template_file" "user-data" {
  template = "${file("${path.module}/userdata/userdata.sh.tpl")}"

  vars {
    efs_id      = "${aws_efs_file_system.efs.id}"
    slack_webhook = "${vars.slack_webhook}"
  }
}

data "terraform_remote_state" "vpc" {
  backend   = "s3"
  workspace = "${var.account_name}"

  config {
    bucket  = "111111111111-future-airlines-terraform-state"
    encrypt = "true"
    profile = "root"
    region  = "${var.region}"
    key     = "vpc.tfstate"
  }
}

data "terraform_remote_state" "sns_topic" {
  backend   = "s3"
  workspace = "${var.environment}"

  config {
    bucket  = "111111111111-future-airlines-terraform-state"
    encrypt = "true"
    profile = "root"
    region  = "${var.region}"
    key     = "environment_alert_notifications"
  }
}

locals {
  subnets = "${data.terraform_remote_state.vpc.private_subnet_ids}"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
}
