resource "aws_vpc" "habichef-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags {
    Name          = "${var.tag_name}-vpc"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Contact     = "${var.tag_contact}"
    X-Application = "${var.tag_application}"
    X-TTL         = "${var.tag_ttl}"
  }
}

resource "aws_internet_gateway" "habichef-gateway" {
  vpc_id = "${aws_vpc.habichef-vpc.id}"

  tags {
    Name = "habichef-gateway"
  }
}

resource "aws_route" "habichef-internet-access" {
  route_table_id         = "${aws_vpc.habichef-vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.habichef-gateway.id}"
}

resource "aws_subnet" "habichef-subnet-a" {
  vpc_id                  = "${aws_vpc.habichef-vpc.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${var.aws_region}a"

  tags {
    Name = "habichef-subnet-a"
  }
}

resource "aws_subnet" "habichef-subnet-b" {
  vpc_id                  = "${aws_vpc.habichef-vpc.id}"
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${var.aws_region}b"

  tags {
    Name = "habichef-subnet-b"
  }
}

output "vpc_id" {
  value = "${aws_vpc.habichef-vpc.id}"
}

output "subnet_id" {
  value = "${aws_subnet.habichef-subnet-a.id}"
}
