variable "office_ip_cidr" {}

variable "region" {}

variable "account_name" {}

variable "jenkins_worker_key_name" {}

variable "jenkins_worker_asg_min" {
  default = 2
}

variable "jenkins_worker_asg_max" {
  default = 2
}

variable "jenkins_worker_instance_type" {
  default = "t2.medium"
}

variable "jenkins_worker_volume_size" {
  default = 25
}

variable "application" {}

variable "cost_centre" {
    default = 99
}

variable "brand" {
  default   = "future-airlines"
}

variable "project" {}

variable "team" {
  default     = "devops"
}
variable "slack_webhook" {}