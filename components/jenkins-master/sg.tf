
 module "sg_tags" {
  source        = "../tags"
  application   = "${var.application}"
  environment   = "${var.environment}"
 }
resource "aws_security_group" "jenkins" {
  name   = "${var.name}-${var.account_name}-jenkins-master"
  vpc_id = "${locals.vpc_id}"

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = "${module.sg_tags.tags}"
}

resource "aws_security_group_rule" "elb-ec2" {
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  source_security_group_id = "${aws_security_group.elb.id}"
  description = "Access the Jenkins EC2 instance from ELB"
  security_group_id = "${aws_security_group.jenkins.id}"
}

resource "aws_security_group_rule" "jenkins-ec2-office" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = "${var.office_ip_cidr}"
  description = "Access the Jenkins EC2 instance from office network"
  security_group_id = "${aws_security_group.jenkins.id}"
}

resource "aws_security_group" "elb" {
  name   = "${var.name}-${var.account_name}-elb"
  vpc_id = "${locals.vpc_id}"

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = "${module.sg_tags.tags}"
}

resource "aws_security_group_rule" "officeip-jenkins-elb" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "https"
  cidr_blocks = "${var.office_ip_cidr}"
  description = "Access the Jenkins ELB from office network"
  security_group_id = "${aws_security_group.elb.id}"
}

resource "aws_security_group_rule" "jenkins-elb-jenkins-worker" {
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  self      = true
  security_group_id = "${aws_security_group.elb.id}"
}

resource "aws_security_group" "efs" {
  name   = "${var.name}-${var.account_name}-efs"
  vpc_id = "${locals.vpc_id}"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = "${merge(module.sg_tags.tags)}"
}