output "jenkins_master_elb_dns_name" {
  value = "${aws_elb.jenkins.dns_name}"
}

output "jenkins_master_url" {
  value = "${aws_route53_record.jenkins_master_r53.name}"
}