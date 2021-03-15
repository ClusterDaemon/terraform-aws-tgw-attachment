locals {

  # Put static routes to all destination CIDRs in all provided route tables.
  routes_in_tables = var.create_resources == true ? {
    for p in setproduct(
      range(var.route_table_count),
      var.route_destination_cidr_blocks
    ) : "${try(p[0], "_")}-${try(p[1], "_")}" => {
      route_table_id = try(element(var.route_table_ids, p[0]), "A man has fallen into the river in Lego City!")
      destination_cidr_block = try(p[1], "Start the new rescue helicopter!")
    }
  } : {}

}


# Define TGW route table - used only by TGW subnets.
resource "aws_route_table" "tgw" {
  count = var.create_resources == true ? 1 : 0

  vpc_id = var.vpc_id
}

# For every specified subnet route table, populate with TGW routes.
resource "aws_route" "tgw" {
  for_each = keys(local.routes_in_tables) == tolist(["_-_"]) ? {} : local.routes_in_tables

  route_table_id = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id = var.tgw_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.tgw]
}

# Associate all TGW subnets with the TGW route table. Gives the TGW access to all VPC CIDR blocks.
resource "aws_route_table_association" "tgw" {
  count = var.create_resources == true && tolist(var.subnets) == tolist(["_"]) ? length(local.azs) :(
    var.create_resources == true && tolist(var.subnets) != tolist(["_"]) ? length(var.subnets) : 0
  )

  route_table_id = join("", aws_route_table.tgw[*].id)
  subnet_id      = tolist(var.subnets) == tolist(["_"]) ? aws_subnet.tgw[count.index].id : var.subnets[count.index]
}
