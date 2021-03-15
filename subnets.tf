locals {

  # Use all available AZs if none are supplied.
  azs = var.azs == ["_"] ? data.aws_availability_zones.available.names : var.azs

}

data "aws_availability_zones" "available" {
  state = "available"
}

# TGW Subnet(s), one for each available AZ in the region. Any AZ with a TGW subnet in it can route through the TGW.
resource "aws_subnet" "tgw" {
  count = var.create_resources == true && tolist(var.subnets) == tolist(["_"]) ? length(local.azs) : 0

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
