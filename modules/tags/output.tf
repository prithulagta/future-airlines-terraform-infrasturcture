output "tag_technical" {
  description = "Tags map merged with standard tags"
  value       = "${local.technical_tags}"
}

output "tag_business" {
  description = "Tags map merged with standard tags"
  value       = "${local.business_tags}"
}

output "asg_tags" {
  value = "${local.asg_tags}"
}

output "tags" {
  description = "Tags map merged with standard tags"
  value       = "${local.tags}"
}