terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = {
      version = ">= 2.41"
    }
  }
}

# VPC attachment actual
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw" {
  count = var.create_resources == true ? 1 : 0

  subnet_ids         = tolist(var.subnets) == tolist(["_"]) ? aws_subnet.tgw[*].id : var.subnets
  transit_gateway_id = var.tgw_id
  vpc_id             = var.vpc_id
  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}
