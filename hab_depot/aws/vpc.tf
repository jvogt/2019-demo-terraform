resource "aws_vpc" "habitat_depot-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags {
    Name          = "${var.tag_name}_vpc"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Contact     = "${var.tag_contact}"
    X-Application = "${var.tag_application}"
    X-TTL         = "${var.tag_ttl}"
  }
}

resource "aws_internet_gateway" "habitat_depot-gateway" {
  vpc_id = "${aws_vpc.habitat_depot-vpc.id}"

  tags {
    Name = "habitat_depot-gateway"
  }
}

resource "aws_route" "habitat_depot-internet-access" {
  route_table_id         = "${aws_vpc.habitat_depot-vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.habitat_depot-gateway.id}"
}

resource "aws_subnet" "habitat_depot-subnet-a" {
  vpc_id                  = "${aws_vpc.habitat_depot-vpc.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${var.aws_region}a"

  tags {
    Name = "habitat_depot-subnet-a"
  }
}

resource "aws_subnet" "habitat_depot-subnet-b" {
  vpc_id                  = "${aws_vpc.habitat_depot-vpc.id}"
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${var.aws_region}b"

  tags {
    Name = "habitat_depot-subnet-b"
  }
}

output "vpc_id" {
  value = "${aws_vpc.habitat_depot-vpc.id}"
}

output "subnet_id" {
  value = "${aws_subnet.habitat_depot-subnet-a.id}"
}
