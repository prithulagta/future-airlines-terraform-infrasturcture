resource "aws_launch_configuration" "jenkins" {
  name_prefix                 = "${var.name}-${var.account_name}-lc-"
  image_id                    = "${data.aws_ami.jenkins-master.image_id}"
  instance_type               = "${var.instance_type}"
  security_groups             = ["${aws_security_group.jenkins.id}", "${aws_security_group.efs.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.jenkins.name}"
  user_data                   = "${data.template_file.user-data.rendered}"
  enable_monitoring           = true
  associate_public_ip_address = false

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "${var.volume_size}"
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "jenkins" {
  name                 = "jenkins-${var.account_name}-asg"
  vpc_zone_identifier  = "${locals.subnets}"
  launch_configuration = "${aws_launch_configuration.jenkins.name}"
  load_balancers       = ["${aws_elb.jenkins.name}"]
  min_size             = "1"
  max_size             = "1"
  desired_capacity     = "1"
  metrics_granularity  = "1Minute"
  health_check_type    = "ELB"

  tag {
    key                 = "costcenter"
    value               = "${var.cost_centre}"
    propagate_at_launch = true
  }

  tag {
    key                 = "brand"
    value               = "${var.brand}"
    propagate_at_launch = true
  }

  tag {
    key                 = "project"
    value               = "${var.project}"
    propagate_at_launch = true
  }

  tag {
    key                 = "team"
    value               = "${var.team}"
    propagate_at_launch = true
  }

  tag {
    key                 = "terraform"
    value               = "yes"
    propagate_at_launch = true
  }

  tag {
    key                 = "account"
    value               = "${data.aws_caller_identity.current.name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "application"
    value               = "${var.application}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_elb" "jenkins" {
  name = "jenkins-${var.account_name}-elb"

  subnets         = ["${locals.subnets}"]
  security_groups = ["${aws_security_group.elb.id}"]
  
  listener {
    instance_port      = 8080
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:server-certificate/jenkins-master-cert"
  }

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 8081
    lb_protocol       = "http"
  }

  listener {
    instance_port     = 50000
    instance_protocol = "tcp"
    lb_port           = 50000
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/"
    interval            = 30
  }

  internal                    = true
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    key                 = "Name"
    value               = "${var.name}-${var.account_name}"
    propagate_at_launch = true
  }
}

resource "aws_route53_record" "jenkins_master_r53" {
  zone_id = "${var.hosted_zone_id}"
  name    = "jenkins.future.airlines.com"
  type    = "A"

  alias {
    name                   = "${aws_elb.jenkins_elb.dns_name}"
    zone_id                = "${aws_elb.jenkins_elb.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_cloudwatch_metric_alarm" "HTTPCode_ELB_5XX" {
  alarm_name          = "awseb-jenkins-master${var.account_name}-ApplicationRequests5xx-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_ELB_5XX"
  namespace           = "AWS/ELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  tags                = "${module.cw_tags.tags}"

  dimensions = {
    LoadBalancerName = "${aws_elb.jenkins.name}"
  }

  alarm_description = "The alarm monitors HTTPCode_ELB_5XX count for Jenkins Master"
  alarm_actions     = ["${data.terraform_remote_state.sns_topic.environment_alert_notifications_arn}"]
}

module "cw_tags" {
  source        = "../tags"
  application   = "${var.application}"
  environment   = "${var.environment}"
} 