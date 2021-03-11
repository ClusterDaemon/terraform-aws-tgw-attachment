data "aws_availability_zones" "available" {
  state = "available"
}

# TGW Subnet(s), one for each available AZ in the region. Any AZ with a TGW subnet in it can route through the TGW.
resource "aws_subnet" "tgw" {
  count = var.create_resources == true && tolist(var.subnets) == tolist([ "_", ]) ? length(local.azs) : 0

  vpc_id            = var.vpc_id
  cidr_block        = cidrsubnet(var.tgw_cidr, var.subnet_newbits, count.index)
  availability_zone = local.azs[count.index]

  tags = merge(
    {
      Name = "tgw-${var.name}-${local.azs[count.index]}",
    },
    var.tags
  )
}

# VPC attachment actual
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw" {
  count = var.create_resources == true ? 1 : 0

  subnet_ids         = tolist(var.subnets) == tolist([ "_", ]) ? aws_subnet.tgw[*].id : var.subnets
  transit_gateway_id = var.tgw_id
  vpc_id             = var.vpc_id
  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

# Define TGW route table - used only by TGW subnets.
resource "aws_route_table" "tgw" {
  count = var.create_resources == true ? 1 : 0

  vpc_id = var.vpc_id
}

# For every specified subnet route table, populate with TGW routes.
resource "aws_route" "tgw" {
  for_each = keys(local.routes_in_tables) == tolist([ "_-_", ]) ? {} : local.routes_in_tables

  route_table_id = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id = var.tgw_id

  depends_on = [ aws_ec2_transit_gateway_vpc_attachment.tgw ]
}

# Associate all TGW subnets with the TGW route table. Gives the TGW access to all VPC CIDR blocks.
resource "aws_route_table_association" "tgw" {
  count = var.create_resources == true && tolist(var.subnets) == tolist([ "_", ]) ? length(local.azs) :(
    var.create_resources == true && tolist(var.subnets) != tolist([ "_", ]) ? length(var.subnets) : 0
  )

  route_table_id = join("", aws_route_table.tgw[*].id)
  subnet_id      = tolist(var.subnets) == tolist([ "_", ]) ? aws_subnet.tgw[count.index].id : var.subnets[count.index]
}
