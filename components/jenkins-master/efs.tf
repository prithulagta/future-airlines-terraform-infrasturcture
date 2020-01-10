module "efs_tags" {
  source        = "../tags"
  application   = "${var.application}"
  environment   = "${var.environment}"
 }

resource "aws_efs_file_system" "efs" {
  creation_token   = "${var.name}-${var.account_name}-efs"
  encrypted        = true
  performance_mode = "generalPurpose"

  tags = "${merge(module.efs_tags.tags, map(
                                "Name", "${var.application}-${var.environment}-efs"))}"
}

resource "aws_efs_mount_target" "efs-mount" {
  count           = "${length(locals.subnets)}"
  file_system_id  = "${aws_efs_file_system.efs.id}"
  subnet_id       = "${element(locals.subnets, count.index)}"
  security_groups = ["${aws_security_group.efs.id}"]
}