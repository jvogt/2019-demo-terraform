resource "aws_vpc" "chef-server-vpc" {
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

resource "aws_internet_gateway" "chef-server-gateway" {
  vpc_id = "${aws_vpc.chef-server-vpc.id}"

  tags {
    Name = "chef-server-gateway"
  }
}

resource "aws_route" "chef-server-internet-access" {
  route_table_id         = "${aws_vpc.chef-server-vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.chef-server-gateway.id}"
}

resource "aws_subnet" "chef-server-subnet-a" {
  vpc_id                  = "${aws_vpc.chef-server-vpc.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${var.aws_region}a"

  tags {
    Name = "chef-server-subnet-a"
  }
}

resource "aws_subnet" "chef-server-subnet-b" {
  vpc_id                  = "${aws_vpc.chef-server-vpc.id}"
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${var.aws_region}b"

  tags {
    Name = "chef-server-subnet-b"
  }
}

output "vpc_id" {
  value = "${aws_vpc.chef-server-vpc.id}"
}

output "subnet_id" {
  value = "${aws_subnet.chef-server-subnet-a.id}"
}
