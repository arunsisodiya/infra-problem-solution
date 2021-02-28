/*==== The NAT Gateway configuration ======*/

##################################
# NAT Gateway for private subnets
##################################
resource "aws_nat_gateway" "private_nat_gateway" {
  count = var.private_nat_gateway && length(var.private_subnets) > 0 ? 1 : 0

  allocation_id = element(aws_eip.nat_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = merge(
    {
      "Name" = format("nat-gateway-%s", var.environment)
    },
    var.tags
  )
}


##################################
# Elastic IP for nat gateway
##################################
resource "aws_eip" "nat_eip" {
  count = var.private_nat_gateway && length(var.private_subnets) > 0 ? 1 : 0

  vpc = true
}