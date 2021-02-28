/*==== The Route Table Configuration ======*/

##########################
# Route tables
##########################
resource "aws_route_table" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0

  depends_on = [
    local.vpc_id,
    aws_internet_gateway.igw
  ]
  vpc_id = local.vpc_id

  tags = merge(
    {
      "Name" = format("%s-${var.public_subnets_suffix}", var.name)
    },
    var.tags,
    var.public_route_table_tags,
  )

}

resource "aws_route_table" "private" {
  count = var.create_vpc && length(var.private_subnets) > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    {
      "Name" = format("%s-${var.private_subnets_suffix}", var.name)
    },
    var.tags,
    var.private_route_table_tags,
  )

}

##########################
# Route mapping
##########################
resource "aws_route" "public_internet_gateway" {
  count = var.create_vpc && var.create_igw && length(var.public_subnets) > 0 ? 1 : 0

  depends_on = [
    local.vpc_id,
    aws_route_table.public,
    aws_internet_gateway.igw
  ]
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id

  timeouts {
    create = "5m"
  }

}

resource "aws_route" "private_nat_gateway" {
  count = var.create_vpc && var.private_nat_gateway && length(var.private_subnets) > 0 ? 1 : 0

  depends_on = [
    local.vpc_id,
    aws_route_table.private,
    aws_nat_gateway.private_nat_gateway
  ]
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id             = element(aws_nat_gateway.private_nat_gateway.*.id, count.index)

  timeouts {
    create = "5m"
  }

}
##########################
# Route table association
##########################
resource "aws_route_table_association" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  depends_on = [
    local.vpc_id,
    aws_subnet.public,
    aws_route_table.public
  ]
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
  count = var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  depends_on = [
    local.vpc_id,
    aws_subnet.private,
    aws_route_table.private
  ]
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private[0].id
}
