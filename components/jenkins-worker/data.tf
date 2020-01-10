data "aws_ami" "jenkins-worker" {
  most_recent = true
  owners=["self"]

  filter {
    name   = "branch"
    values = ["master"]
  }

  filter {
    name   = "name"
    values = ["jenkins-worker-2.138.3"]
  }

  filter {
    name   = "application"
    values = ["Jenkins-Worker"]
  }

}

data "aws_caller_identity" "current" {}

data "template_file" "user-data" {
  template = "${file("${path.module}/userdata/userdata.sh.tpl")}"
  vars {
       master        = "${data.terraform_remote_state.master.jenkins_master_url}"
       region        = "${var.region}"
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

data "terraform_remote_state" "jenkins-master" {
  backend   = "s3"
  workspace = "${var.account_name}"

  config {
    bucket  = "111111111111-future-airlines-terraform-state"
    encrypt = "true"
    profile = "root"
    region  = "${var.region}"
    key     = "jenkins-master.tfstate"
  }
}

locals {
  subnets = "${data.terraform_remote_state.vpc.private_subnet_ids}"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
}
