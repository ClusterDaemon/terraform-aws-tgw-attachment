## v2.0.0

* Updated examples and documentation
* Moved to new repository, bumped major version.

## v1.1.0 

### NEW FEATURES

* Subnet creation override: Module now accepts a `subnets` attribute, allowing TGW subnet creation to occur outside of the module. Usage of this new variable disables automatic subnet creation.

* Improved conditional creation behavior: When providing an overriding subnet, or when diabling resource creation altogether, no errors will be produced. Conditional creation can now also be used to destroy already existing resources, enabling "forward destruction".

* Input variable documentation is now available inline when using the module.

### BUG FIXES, CORRECTIONS

* Removed the tgw data source from main. This prevents some unlikely errors when planning, as TF 12.x does not honor data sources when planning.

* Updated the `route_table_association_ids` output variable to provide route table to subnet association IDs. The previous content was not useful in any scenario, so it definitely was not in use.

* Changed the way resources are addressed among each other to prevent errors when handling empty tuples (when resources are not being created, or when resources that already exist are being destroyed by disabling resource creation).

## v1.0.0

This version represents the first release of this module. It is dubbed production-ready, but not feature-complete.

### QUIRKS

* While conditional resource creation is possible, errors will be generated during the apply phase. These errors will not affect rendered resources, but they may affect the reliability of external automation.

* This module automatically creates subnets in a VPC. This may not fit into all desired usage patterns, as there are implementations that require all subnets to be created before moving on to any other stage (for example a highly segregated infrastruture module anatnomy, or permissions-restricted manifests).
