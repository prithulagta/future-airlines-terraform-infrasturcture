variable "region" {
  description = "AWS Region"
  type        = "string"
  default     = "eu-west-1"
}

variable "environment" {
  type        = "string"
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


