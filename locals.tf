locals {
  azs = var.azs == [ "_", ] ? data.aws_availability_zones.available.names : var.azs

  # Calculate the cartesian product of an index of route tables against available destination CIDRs
  # Build an object to pass to an "aws_route" who's keys are route table count index and destination CIDR.
  # And who's values are the route table ID as selected by the route table count index, and the destination CIDR.
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
