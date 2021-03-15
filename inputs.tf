# Conditional resource creation
variable "create_resources" {
  description = "Whether to create any resources in this module."
  type = bool
  default = true
}

# Mandatory input variables

variable "vpc_id" {
  description = "ID of the VPC which will be attached to the transit gateway described in 'tgw_id'. This VPC must already have a secondary CIDR block associated that is dedicated to TGW routing, described in 'tgw_cidr'."
  type = string
}

variable "tgw_id" {
  description = "ID of the transit gateway this module will be defining an attachment to. This transit gateway must either exist in the same account as the attachment, or it must be shared across accounts via RAM."
  type = string
}

variable "tgw_cidr" {
  description = "Dedicated CIDR block for automatic TGW subnet creation. All automatically generated TGW subnets will be allocated using this CIDR. Must be a secondary CIDR block within the associated VPC. Mandatory for automatic subnet creation. Overridden by the 'subnets' variable."
  type = string
  default = ""
}

variable "name" {
  description = "Name to tag all resources with, when applicable."
  type = string
  default = "Transit Gateway Attachment"
}

variable "azs" {
  description = "List of availability zone names to associate automatically created TGW subnets with. Defaults to all available zones in the region. Overridden by the 'subnets' variable."
  type = list(string)
  default = ["_"]
}

variable "subnets" {
  description = "Overriding list of subnets to associate with the TGW route table. Disables automatic subnet creation. If no value is provided, the subnets will be automatically created within the 'tgw_cidr' subnet block, with subnet count defined by the 'azs' variable, and a subnet mask defined by the 'subnet_newbits' variable. If this variable recieves input, those other automatic creation variables are ignored. Do not use TGW subnets for anything other than TGW routing."
  type = list(string)
  default = ["_"]
}

variable "subnet_newbits" {
  description = "Determines the netmask of each automatically created subnet by adding N amount of netmask bits to the CIDR address defined via 'tgw_cidr'. Defaults to 3, which allows a maximum of eight subnets to be created (more subnets than any region has zones). Typically, the only reason this value would be changed is if the 'tgw_cidr' variable has an overly restrictive netmask, or there is somehow effectively more than eight available zones (via Outposts, for example)."
  type = number
  default = 3
}

variable "route_destination_cidr_blocks" {
  description = "List of CIDR addresses that may be reached via the TGW attachment. This list yields one route entry per route table defined in 'route_table_ids'."
  type = list(string)
  default = []
}

variable "tags" {
  description = "Map of additional tags which are applied to all created resources."
  type = map(string)
  default = {}
}

variable "route_table_ids" {
  description = "List of route tables to add TGW routes as defined in 'route_destination_cidr_blocks'."
  type = list(string)
  default = ["_"]
}

# Route table IDs are only known after apply, unless they already exist before planning.
# This means that we can't make descisions regarding the number of route tables to use if they don't already exist.
# Because of this, we must accurately inform the module of how many route tables there will be.
# If the specified route tables actually do already exist, use the length() function on that already existing route table ID list to fill this variable.
variable "route_table_count" {
  description = "The amount of route tables defined in 'route_table_ids'. Take care to provide a value here that is known during the planning stage, as resource IDs cannot be used to establish counts. Must not be higher than the actual amount of provided 'route_table_ids'."
  type = number
  default = 0
}
