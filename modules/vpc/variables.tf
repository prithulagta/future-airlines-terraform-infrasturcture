variable "availability_zones" {
  type = "list"
}

variable "subnets_private" {
  type    = "list"
  default = []
}

variable "subnets_public" {
  type    = "list"
  default = []
}

variable "cidr" {}

variable "name" {
  description = "Base name for resources"
  type        = "string"
}

variable "account_name" {
  description = "Name of the account where the resource is hosted"
  type        = "string"
}

variable "application" {
  type        = "string"
}

variable "environment" {
  type        = "string"
}



