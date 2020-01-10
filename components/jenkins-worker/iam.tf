/**
 * jenkins instance iam role and policy
 */
module "role_tags" {
  source        = "../tags"
  application   = "${var.application}"
  environment   = "${var.environment}"
 }

resource "aws_iam_role" "jenkins_worker_role" {
  name               = "jenkins-worker-role"
  assume_role_policy = "${file("${path.module}/policies/role.json")}"
  tags = "${module.role_tags.tags}"
}

resource "aws_iam_role_policy" "jenkins_worker_instance_role_policy" {
  name   = "jenkins-worker-policy"
  policy = "${file("${path.module}/policies/policy.json")}"
  role   = "${aws_iam_role.jenkins_worker_role.id}"
}

resource "aws_iam_instance_profile" "jenkins-worker" {
  name = "jenkins-worker-profile"
  path = "/"
  role = "${aws_iam_role.jenkins_worker_role.name}"
}

resource "aws_iam_role_policy_attachment" "jenkins_worker_policy" {
  role       = "${aws_iam_role.jenkins_worker_role.name}"
  policy_arn = "${data.aws_iam_policy.worker.arn}"
}
