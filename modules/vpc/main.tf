data "aws_caller_identity" "current" {}

resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = "true"
  tags = "${merge(
                              module.vpc_tags.tags, map(
                                "Name", "${var.application}-${var.environment}-vpc"
                              )
                            )}"
}

resource "aws_subnet" "private" {
  count                   = "${length(var.subnets_private)}"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${element(var.subnets_private, count.index)}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  map_public_ip_on_launch = false

  tags = "${merge(
                              module.subnet_tags.tags, map(
                                "Availability_zone", var.availability_zones[count.index], 
                                "SubnetType", "private", 
                                "Name", "subnet-private-${var.availability_zones[count.index]}"
                              )
                            )}"
}

resource "aws_route_table" "private" {
  count  = "${length(var.subnets_private)}"
  vpc_id = "${aws_vpc.main.id}"

 tags = "${merge(
              module.route_tags.tags,
              map(
                "Availability_zone", var.availability_zones[count.index], 
                "RouteType", "private", 
                "Name", "route-table-private-${var.availability_zones[count.index]}"
              )
            )}"
}

resource "aws_internet_gateway" "main" {
  count  = "${length(var.subnets_public) > 0 ? 1 : 0}"
  vpc_id = "${aws_vpc.main.id}"

  tags = "${module.gateway_tags.tags}"
}

resource "aws_eip" "nat_gateway_epi" {
  count = "${(length(var.subnets_public) > 0 && length(var.subnets_private) > 0) ? length(var.subnets_public) : 0}"
  vpc   = true

  depends_on = [
    "aws_internet_gateway.main",
  ]

  tags = "${merge(module.gateway_tags.tags, map("Availability_zone", var.availability_zones[count.index]))}"
}

resource "aws_nat_gateway" "main" {
  count         = "${(length(var.subnets_public) > 0 && length(var.subnets_private) > 0) ? length(var.subnets_public) : 0}"
  allocation_id = "${element(aws_eip.nat_gateway_eip.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"

  depends_on = [
    "aws_internet_gateway.main",
  ]

  tags = "${merge(
                    module.gateway_tags.tags, 
                    map(
                      "Availability_zone", var.availability_zones[count.index], 
                      "Name", "Gateway-${var.availability_zones[count.index]}"
                    )
                  )}"
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.subnets_private)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
resource "aws_route" "private_nat_gateway" {
  count                  = "${(length(var.subnets_public) > 0 && length(var.subnets_private) > 0) ? length(var.subnets_private) : 0}"
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.main.*.id, count.index)}"
}

resource "aws_subnet" "public" {
  count                   = "${length(var.subnets_public)}"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${element(var.subnets_public, count.index)}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  map_public_ip_on_launch = false

  tags = "${merge(
                              module.subnet_tags.tags, map(
                                "Availability_zone", var.availability_zones[count.index], 
                                "SubnetType", "public", 
                                "Name", "subnet-public-${var.availability_zones[count.index]}"
                              )
                            )}"
}

resource "aws_route_table" "public" {
  count  = "${length(var.subnets_public) > 0 ? 1 : 0}"
  vpc_id = "${aws_vpc.main.id}"

  tags = "${merge(
              module.route_tags.tags,
              map(
                "Availability_zone", var.availability_zones[count.index], 
                "RouteType", "public", 
                "Name", "route-table-public-${var.availability_zones[count.index]}"
              )
            )}"
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.subnets_public)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route" "public_internet_gateway" {
  count                  = "${(length(var.subnets_public) > 0) ? 1 : 0}"
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main.id}"

  depends_on = [
    "aws_internet_gateway.main",
  ]
}