resource "aws_cloudwatch_dashboard" "jenkins-master-dashboard" {
  dashboard_name = "jenkins-master-dashboard"

  dashboard_body = <<EOF
 {
   "widgets": [
       {
          "type":"metric",
          "x":0,
          "y":0,
          "width":12,
          "height":6,
          "properties":{
             "metrics":[
                [
                   "AWS/AutoScaling",
                   "CPUUtilization",
                   "AutoScalingGroupName",
                   "${var.aws_autoscaling_group.name}"
                ]
             ],
             "period":300,
             "stat":"Average",
             "region":"${var.region}",
             "title":"Jenkins Master Instance CPU"
          }
       }
   ]
 }
 EOF
}