/**
 * jenkins instance iam role and policy
 */

 module "role_tags" {
  source        = "../tags"
  application   = "${var.application}"
  environment   = "${var.environment}"
 }
resource "aws_iam_role" "jenkins_role" {
  name               = "jenkins_role_${var.account_name}"
  assume_role_policy = "${file("${path.module}/policies/jenkins-role.json")}"
  tags = "${module.role_tags.tags}"
}

resource "aws_iam_role_policy" "jenkins_instance_role_policy" {
  name   = "jenkins_instance_role_policy_${var.account_name}"
  policy = "${file("${path.module}/policies/jenkins-instance-role-policy.json")}"
  role   = "${aws_iam_role.jenkins_role.id}"
}

resource "aws_iam_instance_profile" "jenkins" {
  name = "${var.name}-${var.account_name}"
  path = "/"
  role = "${aws_iam_role.jenkins_role.name}"
}

