# Terraform AWS Networking Configuration Module

## Module Overview

This Terraform module is designed to set up a comprehensive VPC environment, including public and private subnets, NAT and Internet Gateways, and detailed route and security configurations to support both application and database operations in a secure and efficient manner.

## Resources

### `aws_vpc`
- **Purpose**: Establishes the VPC with DNS support and a specific CIDR block.
- **Features**:
  - DNS hostname and support enabled.

### Data Source: `aws_availability_zones`
- **Purpose**: Fetches the list of available availability zones in the region to ensure resilient infrastructure deployment.

### `aws_subnet` (Public, App, DB)
- **Purpose**: Configures public and private subnets for different purposes:
  - Public subnets for NAT Gateways.
  - Application subnets for backend services.
  - Database subnets for RDS instances.
- **Dynamic CIDR Assignment**: Each subnet is assigned a CIDR block dynamically based on the VPC CIDR.

### `aws_network_acl` and Associations
- **Purpose**: Manages network ACLs for app and database subnets, providing rules for traffic filtering.
- **Configuration**:
  - Separate ACLs for application and database traffic.

### `aws_network_acl_rule`
- **Purpose**: Defines specific ingress and egress rules for application and database subnets to secure and streamline traffic flow.

### `aws_internet_gateway`
- **Purpose**: Provides internet access to the VPC, facilitating outbound and inbound communication for resources in public subnets.

### `aws_nat_gateway` and `aws_eip`
- **Purpose**: Ensures that instances in private subnets can initiate outbound traffic to the internet while remaining unreachable from the internet.
- **Elastic IP**: Each NAT Gateway is associated with an Elastic IP.

### `aws_route_table` and Associations
- **Purpose**: Manages routing tables for public, app, and DB subnets:
  - Public route tables direct traffic through the Internet Gateway.
  - Private route tables route through NAT Gateways.

### `aws_security_group` and `aws_security_group_rule`
- **Purpose**: Provides fine-grained control over inbound and outbound traffic to and from AWS resources.
- **Configuration**:
  - Custom ingress and egress rules based on operational requirements.

### `aws_vpc_endpoint`
- **Purpose**: Sets up VPC endpoints for AWS services to enable private connections between the VPC and AWS services, enhancing security by not exposing traffic to the public internet.
- **Services**: Includes endpoints for SSM, SSM Messages, and EC2 Messages.

## Usage

To deploy this module in your Terraform environment, define the required variables and module configuration as below:

```hcl
module "network_module" {
  source = "../../modules/network"

  region               = var.region
  availability_zones   = var.availability_zones
  vpc_cidr             = var.vpc_cidr
  inbound_ports        = var.inbound_ports
  rds_egress_from_port = var.rds_egress_from_port
  rds_egress_to_port   = var.rds_egress_to_port
}
```