module "cw_tags" {
  source        = "../tags"
  application   = "${var.application}"
  environment   = "${var.environment}"
} 

resource "aws_cloudwatch_log_metric_filter" "jenkins-worker-error-metric-filter" {
  name           = "JenkinsWorkerUserDataErrorCount"
  pattern        = "ERROR"
  log_group_name = "${aws_cloudwatch_log_group.jenkins-worker.name}"

  metric_transformation {
    name          = "JenkinsWorkerUserDataErrorCount"
    namespace     = "FutureAirlines/Live"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_group" "jenkins-worker" {
  name              = "/aws/ec2/jenkins-worker"
  retention_in_days = "14"
}

resource "aws_cloudwatch_metric_alarm" "user-data-error" {
  alarm_name          = "awsec2-JenkinsWorkerUserDataErrorCount"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "JenkinsWorkerUserDataErrorCount"
  namespace           = "FutureAirlines/Live"
  period              = "120"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "Severity=Critical:ComponentType=Jenkins:ComponentName=jenkins-worker:Description=This metric monitors the jenkins worker user data for Errors."
  treat_missing_data  = "notBreaching"
  alarm_actions       = ["${data.terraform_remote_state.sns_topic.environment_alert_notifications_arn}"]
  tags                = "${module.cw_tags.tags}"
}

resource "aws_cloudwatch_metric_alarm" "high-cpu-jenkins-worker-alarm" {
  alarm_name          = "high-cpu-jenkins-worker-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.jenkins-worker.name}"
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.scale-out.arn}"]
  tags = "${module.cw_tags.tags}"
}

resource "aws_cloudwatch_metric_alarm" "low-cpu-jenkins-worker-alarm" {
  alarm_name          = "low-cpu-jenkins-worker-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.jenkins_worker.name}"
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.scale-in.arn}"]
  tags              = "${module.cw_tags.tags}"
}