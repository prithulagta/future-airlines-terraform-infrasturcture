output "vpc_id" {
  value = "${module.vpc.id}"
}

output "route_table_ids" {
  value = ["${module.vpc.public_route_table_ids}", "${module.vpc.private_route_table_ids}"]
}

output "public_subnet_ids" {
  value = "${module.vpc.public_subnet_ids}"
}

output "private_subnet_ids" {
  value = "${module.vpc.private_subnet_ids}"
}