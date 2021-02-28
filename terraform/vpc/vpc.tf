locals {
  vpc_id = element(aws_vpc.this.*.id, 0)
}

/*==== The VPC configuration ======*/

#################
# VPC Definition
#################
resource "aws_vpc" "this" {
  count = var.create_vpc ? 1 : 0

  cidr_block                       = var.cidr
  instance_tenancy                 = var.instance_tenancy
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags
  )
}
