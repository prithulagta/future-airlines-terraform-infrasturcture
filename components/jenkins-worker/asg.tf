## Launch configuration used by autoscaling group
resource "aws_launch_configuration" "jenkins-worker" {
  name_prefix                 = "jenkins-worker-lc-"
  image_id                    = "${data.aws_ami.jenkins-worker.id}"
  instance_type               = "${var.jenkins_worker_instance_type}"
  key_name                    = "${var.jenkins_worker_key_name}"
  security_groups             = ["${aws_security_group.jenkins.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.jenkins-worker.name}"
  user_data                   = "${data.template_file.user-data.rendered}"
  associate_public_ip_address = false

  root_block_device {
    volume_size = "${var.jenkins_worker_volume_size}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

## Autoscaling group.
resource "aws_autoscaling_group" "jenkins-worker" {
  name                 = "${aws_launch_configuration.jenkins-worker.name}-asg"
  vpc_zone_identifier  = "${locals.subnets}"
  launch_configuration = "${aws_launch_configuration.jenkins-worker.name}"
  min_size             = "${var.jenkins_worker_asg_min}"
  max_size             = "${var.jenkins_worker_asg_max}"
  termination_policies = ["OldestInstance"]
  metrics_granularity  = "1Minute"
  health_check_type    = "EC2"

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

resource "aws_autoscaling_policy" "scale-out" {
  name                   = "scale-out-jenkins-workers"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.jenkins-worker.name}"
}

resource "aws_autoscaling_policy" "scale-in" {
  name                   = "scale-in-jenkins-workers"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.jenkins-workers.name}"
}
