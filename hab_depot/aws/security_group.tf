resource "aws_security_group" "habitat_depot" {
  name        = "habitat_depot_${random_id.instance_id.hex}"
  description = "Habitat Depot Server"
  vpc_id      = "${aws_vpc.habitat_depot-vpc.id}"

  tags {
    Name          = "${var.tag_customer}-${var.tag_project}_${random_id.instance_id.hex}_${var.tag_application}_hab_depot_security_group"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

//////////////////////////
// Base Linux Rules
resource "aws_security_group_rule" "hd_ingress_allow_22_tcp_all" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.habitat_depot.id}"
}

////////////////////////////////
// Habitat Depot Rules
# HTTP (nginx)
resource "aws_security_group_rule" "ingress_habitat_depot_allow_80_tcp" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.habitat_depot.id}"
}

# HTTPS (nginx)
resource "aws_security_group_rule" "ingress_habitat_depot_allow_443_tcp" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.habitat_depot.id}"
}

# Allow leaderel connections
resource "aws_security_group_rule" "ingress_habitat_depot_allow_7331_tcp" {
  type                     = "ingress"
  from_port                = 7331
  to_port                  = 7331
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.habitat_depot.id}"
  source_security_group_id = "${aws_security_group.habitat_depot.id}"
}

# Egress: ALL
resource "aws_security_group_rule" "hd_linux_egress_allow_0-65535_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.habitat_depot.id}"
}
