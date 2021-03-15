# terraform-aws-transit-gateway-attachment

Terraform resource module that manages TGW (Transit Gateway) attachments in AWS, as well as associated subnets and route tables in any number of availability zones.

This module does NOT create transit gateways themselves, but instead creates transit gateway attachments to known transit gateways, enabling VPCs to be connected as "spokes" to a common BGP "hub".

- [terraform-aws-transit-gateway-attachment](#terraform-aws-transit-gateway-attachment)
  - [Resource Types](#resource-types)
  - [Features](#features)
  - [Usage](#usage)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
  - [Contributing](#contributing)
  - [Change Log](#change-log)
  - [Authors](#authors)


## Resource Types

 * aws\_transit\_gateway\_attachment
 * aws\_subnet
 * aws\_vpc\_route\_table
 * aws\_vpc\_toute\_table\_association
 * aws\_vpc\_route


## Features:

This module aims to enable inter-VPC communication using a pre-established Transit Gateway for a private routing mesh.

 - Automatic resilient network infrastructure integration
 - Network segregation - A secondary VPC CIDR block is required to provision TGW subnets, and these subnets host only TGW interface device addresses.
 - Transit Gateway subnets are automatically created in all available fault domains, unless overridden with a finite AZ list
 - Routes which involve the Transit Gateway are attached to all provided route tables statically.

## Usage:

See the [examples directory](examples) for complete example usage.

### Sourcing the module:

```hcl
module "tgw_attachment" {
  source = "git@github.com:ClusterDaemon/terraform-aws-transit-gateway-attachment.git?ref=v0.1.0"

  #
  # Input attributes
  #
}
```

## Providers

Name | Version
--- | ---
AWS | >= 2.44.0


## Inputs:

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| create\_resources | Controls whether any resource in-module is created. | bool | true | no |
| name | Pretty name for the TGW attachment resource | string | "Transit Gateway Attachment" | no |
| vpc\_id | ID of the VPC which will be attached to the transit gateway described in `tgw_id`. This VPC must already have a secondary CIDR block associated that is dedicated to TGW routing, described in `tgw_cidr`. | string | nil | yes |
| tgw\_id | ID of the transit gateway this module will be defining an attachment to. This transit gateway must either exist in the same account as the attachment, or it must be shared across accounts via RAM. | string | "" | no |
| tgw\_cidr | Dedicated CIDR block for automatic TGW subnet creation. All automatically generated TGW subnets will be allocated using this CIDR. Must be a secondary CIDR block within the associated VPC. Mandatoryfor automatic subnet creation. Overridden by the `subnets` variable. | string | nil | no |
| azs | List of availability zone names to associate automatically created TGW subnets with. Defaults to all available zones in the region. Overridden by the `subnets` variable. | list(string) | [] | no |
| subnet\_newbits | Determines the netmask of each automatically created subnet by adding N amount of netmask bits to the CIDR address defined via `tgw_cidr`. Defaults to 3, which allows a maximum of eight subnets to be created (more subnets than any region has zones). Typically, the only reason this value would be changed is if the `tgw_cidr` variable has an overly restrictive netmask, or there is somehow effectively more than eight available zones (via Outposts, for example). | number | 3 | no |
| subnets | Overriding list of subnets to associate with the TGW route table. Disables automatic subnet creation. If no value is provided, the subnets will be automatically created within the `tgw_cidr` subnet block, with subnet count defined by the `azs` variable, and a subnet mask defined by the `subnet_newbits` variable. If this variable recieves input, those other automatic creation variables are ignored. Do not use TGW subnets for anything other than TGW routing. | list(string) | [] | no |
route\_destination\_cidr\_blocks | List of destination CIDR addresses that will be routed through the TGW. While these are not required, the TGW attachment isn't very useful without them. | list(string) | [] | no |
route\_table\_ids | AWS resource IDs of any route tables that require inter-VPC private routing. Each of those tables will be filled with the destination routes as described in `route_destination_cidr_blocks`. | list(string) | [] | no |
route\_table\_count | The amount of route tables defined in `route_table_ids`. Take care to provide a value here that is known during the planning stage, as resource IDs cannot be used to establish counts. Must not be higher than the amount of provided `route_table_ids`. | number | 0 | no |


## Outputs:

| Name | Description | Type |
| --- | --- | --- |
| attachment\_id | EC2 transit gateway VPC attachment. | string |
| route\_table\_id | Route table used to associate TGW subnets. This route table describes and controls which availability zones can route via the TGW attachment. | string |
| azs | List of availibility zone names that have associated TGW subnets. | list(string) |
| subnet\_ids | List of dedicated TGW subnets. | list(string) |
| route\_table\_association\_ids | List of subnet associations with the dedicated TGW route table. | list(string) |



## Contributing

Report issues/questions/feature requests on in the [issues](https://github.com/ClusterDaemon/terraform-aws-transit-gateway-attachment/issues/new) section.

Full contributing [guidelines are covered here](https://github.com/ClusterDaemon/terraform-aws-transit-gateway-attachment/blob/master/CONTRIBUTING.md).


## Change Log

The [changelog](https://github.com/ClusterDaemon/terraform-aws-transit-gateway-attachment/tree/master/CHANGELOG.md) captures all important release notes.


## Authors

Created and maintained by [David Hay](https://github.com/ClusterDaemon) - david.hay@nebulate.tech
