# Our default security group to access
# the instances over SSH and HTTP
module "sg_tags" {
  source        = "../tags"
  application   = "${var.application}"
  environment   = "${var.environment}"
 }

resource "aws_security_group" "jenkins-worker" {
  name   = "jenkins-worker-sg"
  vpc_id = "${locals.vpc_id}"

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.office_ip_cidr}"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    self      = true
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = "${module.sg_tags.tags}"
}
