module "vpc_tags" {
  source        = "../tags"
  application   = "${var.application}"
  environment   = "${var.environment}"
 }

module "subnet_tags" {
  source        = "../tags"
  application   = "${var.application}"
  environment   = "${var.environment}"
  
 }

 module "route_tags" {
  source        = "../tags"
  application   = "${var.application}"
  environment   = "${var.environment}"
  
 }

 module "gateway_tags" {
  source        = "../tags"
  application   = "${var.application}"
  environment   = "${var.environment}"
  
 }
