provider "aws" {
  region  = "us-east-1"
}

data "aws_availability_zones" "available" {}

# As we want to use the private subnet list more than once, define it as a local variable that may be referenced
locals {
  vpc_private_subnets = [ "10.100.100.0/26", "10.100.100.64/26", ]
}

# This VPC module is very complete, and is considered a standard by other modules in this org.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name                   = "tgw_attachment_example"
  cidr                   = "10.100.100.0/24"

  # We must provide a secondary CIDR block to use with the TGW.
  secondary_cidr_blocks  = [ "10.200.100.0/26" ]

  # We give the VPC module all available zones to use.
  # It will allocate each private/public subnet pair into a new zone.
  azs                    = data.aws_availability_zones.available.zone_ids

  # Here we provide two subnet blocks each for private and public use.
  # This means we're using two availability zones, "a" and "b", as those are the first in the AZ list.
  # Note that private subnets are sourced from th above variable.
  private_subnets        = local.vpc_private_subnets
  public_subnets         = [ "10.100.100.128/26", "10.100.100.192/26", ]

  # The VPC module will create a route table for each NAT gateway, to make NAT networking resilient.
  enable_nat_gateway     = true

  # As such, we don't want a single NAT gateway. We want one per private/public subnet pair.
  single_nat_gateway     = false

  # If we want multiple private subnets in a single AZ, we only need one route table in that AZ.
  # If we make a route table and NAT gateway per subnet with many subnets in the same AZ,
  # Then EIP addresses will be quickly exhauisted, of which there is a limit of 5 by default.
  one_nat_gateway_per_az = true

  enable_dns_hostnames   = true
}

module "tgw_attachment" {
  source = "git@github.com:ClusterDaemon/terraform-aws-transit-gateway-attachment.git?ref=v2.0.0"

  # Mandatory args

  # Obtain the VPC ID from the VPC module. This guarantees the correct ID is obtained.
  # It also guarantees that the VPC exists before attempting to use it in this module.
  vpc_id = module.vpc.vpc_id

  # This resource must exist ahead of time.
  # Must be shared via RAM to enable cross-account attachment (if that applies).
  tgw_id = "REPLACE ME WITH THE TGW ID"

  # We already know what the secondary CIDR will be, because we fed that data into the VPC module.
  # If we obtain it from the VPC module we can guarantee that the secondary CIDR exists before attempting to use it.
  # We specified only one secondary CIDR block, so it's the first (and only) element of that list.
  tgw_cidr = element(module.vpc.vpc_secondary_cidr_blocks, 0)

  # Optional args

  # Some private networks which may be accessed via the transit gateway attachment.
  # The TGW will be tried "first" when evaluating routes.
  route_destination_cidr_blocks = [ "10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16", ]

  # The route table count will be the number of allocated primary VPC CIDR private subnets
  # or the number of availability zones that have been provided to the VPC module to use, whichever is smaller.
  route_table_count = min(length(local.vpc_private_subnets), length(data.aws_availability_zones.available.zone_ids))

  # Obtain route table IDs from the VPC module.
  route_table_ids = module.vpc.private_route_table_ids
}
