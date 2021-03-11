output "attachment_id" {
  description = "AWS ID of the EC2 transit gateway VPC attachment."
  value = join("", aws_ec2_transit_gateway_vpc_attachment.tgw[*].id)
}

output "route_table_id" {
  description = "AWS ID of the route table used to associate TGW subnets. This route table describes and controls which availability zones can route via the TGW attachment."
  value = join("", aws_route_table.tgw[*].id)
}

output "route_table_association_ids" {
  description = "List of subnet associations with the dedicated TGW route table."
  value = var.create_resources == true ? [ for v in aws_route_table_association.tgw : v.id ] : []
}

output "azs" {
  description = "List of availibility zone names that have associated TGW subnets. This also serves as a list of availability zones that may route via the attached TGW."
  value = var.create_resources == true && tolist(var.subnets) == tolist([]) ? local.azs : []
}

output "subnet_ids" {
  description = "List of dedicated TGW subnet IDs."
  value = var.create_resources == true && tolist(var.subnets) == tolist([]) ? [ for v in aws_subnet.tgw : v.id ] :(
    var.create_resources == true && tolist(var.subnets) != tolist([]) ? var.subnets : []
  )
}
